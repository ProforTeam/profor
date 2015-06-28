function DieboldMariano = getPointForecastTestStats( resultTable, rawDataTable, ...
    forecastHorizon, defaultModelName, evaluationVintage, vblName )
% getDensityTestGoodnessOfFit  Returns point forecast test statistics.
%   Currently only Diebold-Mariano.
%
%
% Input:
%   resultTable         [Table]         
%   rawDataTable        [Table]
%   forecastHorizon     [int]
%   defaultModelName    [str]
%   evaluationVintage   [str]       Currently only supports 'last'
%
% Output:
%   DieboldMariano      [struct]    Structure with fieldnames as model names.
%       modelNames                      
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

errType     = ['tableFns:', mfilename ];

%% Check that the default model is included in model space.

% Construct a list of all the model names used in the PROFOR combination, if
% categorical convert to cell.
modelNames          = unique( resultTable.modelName );
modelNames          = ifCategoricalConvertToString( modelNames );
nModelNames         = numel( modelNames );

% Check that the default model is included in the list and is unique.
nDefaultModels      = sum( strcmpi( defaultModelName, modelNames ) );

if nDefaultModels == 1
    existDefaultModel   = true;
    
elseif nDefaultModels == 0
    msg = ['Model %s was not included in the Profor experiment, please re-run', ...
        'including the default model, or change your default model'];
    error(errType, msg, defaultModelName)
    
else
    error(errType, 'Multiple default models named %s', defaultModelName)
end

%% 3. Extract actual data from rawDataTable - last vintage of the date.

% Find all the aviable vintages for the given variable.
idx                 = rawDataTable.VariableName == vblName;
availableVintages   = unique( rawDataTable(idx, :).Vintage );

% Select the vintage accordingly
switch lower( evaluationVintage )
    case 'last'
        vintageDate     = availableVintages(end, 1);
        
    otherwise
        error(errType, 'Not Imlemented evaluation vintage selection')
end

% Select the vintage requested.
idx                 = rawDataTable.VariableName == vblName & ...
    rawDataTable.Vintage == vintageDate;
rawDataTable        = rawDataTable(idx, :);

% Ensure that the returned table has unique date / data pairs.
nUniqueRawData      = numel( unique( rawDataTable.Date ) );
nRawData            = numel( rawDataTable.Date );

assert( nUniqueRawData == nRawData, errType, 'Multiple entries for vintage / date pairs');

%% Extract point forecasts from all models.

for ii = 1 : nModelNames
    
    % Select the point forecasts and store for each model.
    idx     = resultTable.modelName == modelNames(ii) & ...
        ~isnan( resultTable.PointForecast );
    
    pointForecastTable ...
        = resultTable(idx, {'ForecastEvaluationPeriod', 'PointForecast'});
    
    % TODO: Check that dates from point forecast correspond with those of raw data by
    % comparing start and end dates.    
    Actual.startDate        = rawDataTable.Date(1);
    Actual.endDate          = rawDataTable.Date(end);
    
    PtForecast.startDate    = pointForecastTable.ForecastEvaluationPeriod(1);
    PtForecast.endDate      = pointForecastTable.ForecastEvaluationPeriod(end);
    
    % As date timing convention likely to change - get tidied up going to do
    % this dirty and just manually adjust input vectors so dates of forecasts
    % and actual coincide.
        
    % Basically, this means that for the raw data is taken from
    % (1 + forecastHorizon : end) and the point forecasts from
    % (1:end - forecastHorizon).
    
    InputPointForecasts.( modelNames{ii} ) ...
        = pointForecastTable.PointForecast(1 : end - forecastHorizon);
    
end

%% Compute test stat for each combination of models with the default

% Take the raw data from the table adjusting for the misaligned indicies as
% noted above.
idxRawData  = 1 + forecastHorizon;
inRawData   = rawDataTable( idxRawData : end, :).Data;

% Calculate the Diebold Mariano test stat for all models available.
for ii = 1 : nModelNames
    
    isDefaultModel  = strcmpi( defaultModelName, modelNames{ii} );
    
    if ~isDefaultModel        
        % Calculate the Diebold-Mariano Test Stat.
        DieboldMariano.( modelNames{ii} ) ...
            = statTestFns.dieboldMarianoTestStat(...
            InputPointForecasts.( defaultModelName ), ...
            InputPointForecasts.( modelNames{ii} ), ...
            inRawData);        
    end    
end

end

