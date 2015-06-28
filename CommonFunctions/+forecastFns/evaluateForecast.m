function output = evaluateForecast(model, forecastDates, actual, ...
    variableNames, brierScoreSettings, densityScoreSettings)
% evaluateForecast
%
% Input:
%   model               [Model]
%   forecastDates       [double]        YYYY.DD, (nForecastDates x 1)
%   actual              [double]        (nForecastDates x 1) - outturn
%   variableNames       [str]
%
% Output:
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Copyright (C) 2014  PROFOR Team
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

errType     = [mfilename ':input'];

densityIdx  = false;
% First some error checking
if ~isa(model.forecast, 'Forecasting')
    error(errType, 'The model object do not contain a forecast object of Forecast class')
end

[T, N]      = size(actual);
if T ~= numel( forecastDates ) || N ~= numel( variableNames )
    error(errType,'The input actual, forecastDates and or variableNames do not have correct matching size')
end

if ~ densityScoreSettings.xDomain.default
    densityIdx  = true;    
%     if size( densityScoreSettings.xDomain.x, 2 ) ~= N
%         error([mfilename ':input'],'The optional input xDomain has worng size, needs to be the same columns as actual')
%         
%     else
%         densityIdx  = true;
%     end
end

%%
% Extract from model object
predictions0Transf  = [model.forecast.predictionsY.getForecast];
predictionsSTransf  = [];
predictionsDTransf  = [];
xDomainTransf       = [];
datesY              = [];
selectionY          = [];

for i = 1 : numel( model.forecast.predictionsY )
    % TODO
    predictionsSTransf  = cat(2, predictionsSTransf, ...
        permute( model.forecast.predictionsY(i).getForecastSimulations, [1 3 2] ));
    % Forecast evaluation dates
    datesY              = cat(2, datesY, ...
        model.forecast.predictionsY(i).getForecastDates);
    % Name of the variable.
    selectionY          = cat(2, selectionY, ...
        {model.forecast.predictionsY(i).mnemonic});
    
    % Do not need to extract these if xDomain is supplied in the
    % densityScoreSettings. Then we compute the density using a common
    % xDomain across models
    if ~densityIdx            
        % First, update the TsdataForecast object for the model and
        % variable with the xDomainLength specified in DensityScoreSettings.
        % This might be used in evaluateForecast if no prespeficied xDomain has
        % been set in densityScoreSettings
        model.forecast.predictionsY(i).xDomainLength ...
                                    = densityScoreSettings.xDomainLength;                            
        % Then, get the density forecast...
        predictionsDTransf  = cat( 2, predictionsDTransf, ...
            model.forecast.predictionsY(i).getForecastDensity );
        % ...and the implied xDomain
        xDomainTransf       = cat(2, xDomainTransf, ...
            model.forecast.predictionsY(i).getForecastxDomain);    
    end
end

%% Get and sort input

% Make new index such that the output is sorted according to the ordering in
% variableNames ( output.selection )
mappedForecastIndex     = nan(1, N);
for i = 1 : N
    if any( strcmpi(variableNames{i}, selectionY));
        %[~,~,ib]=intersect(lower(variableNames{i}),lower(model.forecast.selection.x));
        mappedForecastIndex(i)  = i;
    end
end

if all( isnan( mappedForecastIndex ) )
    output              = struct();
    return
    
else
    mappedForecastIndex = mappedForecastIndex( isnan(mappedForecastIndex) == 0);
end

% OUTPUT
output.selection        = variableNames( mappedForecastIndex );

% Get matching variables from model and make index
mappedModelIndex        = nan(1, numel(output.selection));
cnt                     = 1;
for i = 1 : numel(selectionY)
    
    if any( strcmpi( selectionY{i}, output.selection ) );
        mappedModelIndex(cnt)   = i;
        cnt                     = cnt + 1;
    end
end

% Loop through matrix
horizons        = [];
dates           = [];
actuala         = [];
predictions     = [];
simulations     = [];
densities       = [];
xDomain         = [];
draws           = model.estimation.simulationSettings.nsave;

for a = 1 : numel( mappedForecastIndex )
    
    % Get matching dates and adjust input and output accordingly
    [datesOut, mappedModelDates, mappedForecastDates] = ...
        intersect( datesY(:, mappedForecastIndex(a)), forecastDates);
    
    % Return if no matching dates or names
    if isempty( datesOut )
        output      = struct();
        return
        
    else
        % Get first output (to be used below)
        horizons    = cat(2, horizons, mappedModelDates);
        dates       = cat(2, dates, datesOut);
        actuala     = cat(2, actuala,...
            actual(mappedForecastDates, mappedForecastIndex(a)));
        
        % Extract usefull stuff: Here forecasts, densities etc. will match dates
        % and the selection ordering.
        predictions = cat(2, predictions, ...
            predictions0Transf( mappedModelDates(:, a), mappedModelIndex(a) )); % (nfor x n)
        
        if draws > 1
            simulations     = cat(3, simulations, predictionsSTransf( ...
                mappedModelDates(:, a), mappedModelIndex(a), :)); % (nfor x 1 x d)
            
            if densityIdx
                xDomain     = cat(3, xDomain, ...
                    densityScoreSettings.xDomain.x{:,mappedForecastIndex(a)}); % (nfor x n x xDom)
                densities   = cat(3, densities, ...
                    forecastFns.kernelDensityEstimate(simulations(:,end,:),xDomain(:,end,:)));
                
            else
                densities   = cat(3, densities, predictionsDTransf( ...
                    mappedModelDates(:,a),mappedModelIndex(a),:));
                xDomain     = cat(3, xDomain, ...
                    xDomainTransf(:,mappedModelIndex(a)));
            end
        end
    end
end

output.horizons     = horizons;
output.dates        = dates;
output.actual       = actuala;
output.xDomain      = xDomain;
output.densities    = densities;
output.predictions  = predictions;
output.simulations  = simulations;

[T, N]              = size( output.predictions );

%% Compute your different scores

% Mean squared prediction error.
output.sqprederror  = ( output.actual - output.predictions ) .^2;

% Evaluate the forecasts using various scoring methods - either with the
% empirical simulation representing the pdf in simulation, or a smoothed version
% of it using a KDE in (xDomain, densities).
if draws > 1
    
    DensityScores       =  forecastFns.getDensityScores(output.actual, simulations, ...
        output.xDomain, output.densities, brierScoreSettings, densityScoreSettings);
    
    % Store the computed densities into the output structure.
    output.crpsD                    = DensityScores.crpsD;
    output.logScoreD                = DensityScores.logScoreD;
    output.logScoreWarning          = DensityScores.logScoreWarning;
    output.brierScoreThresholdMap   = DensityScores.brierScoreThresholdMap;
    output.brierScoreWarning        = DensityScores.brierScoreWarning;
    output.cdfEventThresholdMap     = DensityScores.cdfEventThresholdMap;
end











