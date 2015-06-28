function [predictionsA, predictionsY] = combination(estimation, dataLevel)
% combination -	Forecast combination model
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% Get correct weight matrix
W       = forecastFns.getWeightMatrix( estimation );
nfor    = estimation.nfor;
nvary   = estimation.namesY.numc;
draws   = estimation.simulationSettings.nsave;

% Also extract dates: The actual forecasts from the models can be for a
% different hroizon than 1, 2, ... (starting from the the vintage: period - 1.
% I.e., if one or more periods are missing in the real time data.
% This can be the case if
%   1) The data is like that.
%   2) Ragged edge model,
%       where some variables are observed to time t-1, and others only to e.g.,
%       t-2) Thus, the one step horizon here (vintage period), might be forecast
%       horizon 2 or higher in the actual model evaluated.
dates   =  nan(nfor, nvary);

if draws > 1
    % Empirical Density forecast
    forcs = nan(nfor, nvary, draws);
else
    % Empirical Density forecast
    forcs = nan(nfor, nvary);
end
   
if ~ estimation.densityScoreSettings.xDomain.default
    densityIdx = true;
    % get xDomain from estimation.densitySettings since this has
    % been used by all models 
    xDomain             = estimation.densityScoreSettings.xDomain.x;      
else
    densityIdx = false;
end

% Construct combined simulation sample
for i = 1 : nfor
    for j = 1 : nvary
        
        if draws > 1             

            if densityIdx                        
                % Select the final element of the result cell and extract the
                % simulation for each forecast horizon and variable.
                a       = forecastFns.extractFieldFromResByForcHorizonAndVbl( ...
                            'densities', estimation.resultCell(end), i, j);   
                        
                xDomainIncrement = xDomain{j}(2) - xDomain{j}(1);                        
            else
                % Here we first need to extract the simulation smpl, then 
                % construct the densities over a common xDomain. Time
                % consuming - but do not need to use a pre-specified
                % xDomain
            
                % This will give the xDomain for each model, use the most
                % extremes and use this to construct a "combined" domain that
                % encompase all models.             
                xDomain = forecastFns.extractFieldFromResByForcHorizonAndVbl( ...
                            'xDomain', estimation.resultCell(end), i, j);                                                                                                                            

                xDmin   = min(xDomain(:,1));  
                xDmax   = max(xDomain(:,end));  
                % "Combined" xDomain
                xDomain             = linspace(xDmin, xDmax, size(xDomain,2));                        
                xDomainIncrement    = xDomain(2) - xDomain(1);                                        
                
                % Construct densities from simulationsSmpls
                % Select the final element of the result cell and extract the
                % simulation for each forecast horizon and variable.
                a       = forecastFns.extractFieldFromResByForcHorizonAndVbl( ...
                            'simulations', estimation.resultCell(end), i, j);                            
                
                ad      = zeros(nvary, size(xDomain,2));                
                for m = 1 : size(a,1)
                    ad(m, :) = ksdensity(a(m, :), xDomain(:));
                end
                a = ad;
                
            end
            
            % Then, finally, do the combination
            switch lower(estimation.densityScoreSettings.combinationMethod.x{:})

                case{ 'linear' }
                    % Combine the forecast at horizon i, and vbl j by multiplying the
                    % respective weights from the forecast horizon i for each model.                         
                        forcsd = W(end, :, i, j) * a;                                                

                case{ 'log' }
                    % Combine the forecast at horizon i, and vbl j by multiplying the
                    % respective weights from the forecast horizon i for each model
                    % using geometric average              
                    ap = zeros(size(a));
                    for m = 1 : size(ap,1)                        
                        ap(m,:) = a(m,:).^W(end, m, i, j)';                       
                    end
                    forcsd_tmp          = prod(ap,1);            
                    nomarlizingConstant = sum(forcsd_tmp)*xDomainIncrement;                    
                    forcsd              = forcsd_tmp/nomarlizingConstant;                                        

                otherwise

                    msg = ['The supplied combination method is not supported'];
                    error([mfilename ':combinationMethod'], msg)

            end

            % This is "stupid" but have to work for now 
            %(need to generate a simulationSmpl from the density since most other 
            % stuff is based on the simulationSmpl. That is, the density is just 
            % an approximation, but need it for scoring and pooling (above))
            if densityIdx
                 forcs(i, j, :) = forecastFns.density2Simulation(...
                                                forcsd(:),...
                                                draws,...
                                                vec(xDomain{j})...
                                                );                 
            else
                forcs(i, j, :) = forecastFns.density2Simulation(...
                                                forcsd(:),...
                                                draws,...
                                                xDomain(:)...
                                                );                      
            end
        
        else

                % Select the final element of the result cell and extract the
                % simulation for each forecast horizon and variable.
                a       = forecastFns.extractFieldFromResByForcHorizonAndVbl( ...
                            'predictions', estimation.resultCell(end), i, j);                        
                
                forcs(i, j) = W(end, :, i, j) * a;   

        end

        %%

        % Select the final element of the result cell and extract the
        % date for each forecast horizon and variable.            
        a = forecastFns.extractFieldFromResByForcHorizonAndVbl( ...
            'dates', estimation.resultCell(end), i, j);

        if numel( unique(a) ) > 1
            msg = ['For some reason the forecast dates for the different', ...
                'models do not match. Critical error. Bug in the code.'];
            error([mfilename ':dates'], msg)

        else
            dates(i, j) = a(1);
        end

    end
end
    
% Put into time series object for forecasts
[~, ~, forecastSample]  = adjSample(estimation.estimationSample, ...
    estimation.freq, 'nfor', nfor);

% Indicator of whether to store the forecast or not.
if nargin == 2
    isStoreDataLevel = true;
else
    isStoreDataLevel = false;
    dataLevel        = [];
end;

% Return the forecast predictions and history if provided.
[predictionsA, predictionsY] = ...
    forecastFns.storeForecastAndHistory(forcs, dates, forecastSample, dataLevel, ...
    estimation, isStoreDataLevel);

end


