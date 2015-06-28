function TotalEconomicLoss = getTotalEconomicLoss( resultTable, rawDataTable, ...
    forecastHorizon, defaultModelName, evaluationVintage, vblName, eventThreshold, ...
    eventType)
% getTotalEconomicLoss  - Calculates total economic loss.
%
% Input:
%   resultTable         [Table]
%   rawDataTable        [Table]
%   forecastHorizon     [int]
%   defaultModelName    [str]
%   evaluationVintage   [str]       Currently only supports 'last'
%
% Output:
%   TotalEconomicLoss      [struct]    Structure with fieldnames as model names.
%       modelNames
%
% Reference: TODO.
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

errType     = ['tableFns:', mfilename];

%% Check that the default model is included in model space.

% Construct a list of all the model names, if categorical convert to cell.
modelNames          = unique( resultTable.modelName );
modelNames          = ifCategoricalConvertToString( modelNames );
nModelNames         = numel( modelNames );

% Check that the default model is included in the list and is unique.
nDefaultModels      = sum( strcmpi( defaultModelName, modelNames ) );

if nDefaultModels == 1
    existDefaultModel   = true;
    
elseif nDefaultModels == 0
    msg = ['Either Model "%s" was not included in the Profor experiment, or, ', ...
        'variable "%s" is not included in Model "%s", please re-run', ...
        ' including the default model or variable, or change your default model.'];
    error(errType, msg, defaultModelName, vblName, defaultModelName)
    
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
    
    % Select the requested field and store for each model.
    idx     = resultTable.modelName == modelNames(ii) & ...
        ~isnan( resultTable.Scores );
    
    requestedFieldTable ...
        = resultTable(idx, {'ForecastEvaluationPeriod', 'Scores'});
    
    % As date timing convention likely to change - get tidied up going to do
    % this dirty and just manually adjust input vectors so dates of forecasts
    % and actual coincide.
    
    % Basically, this means that for the raw data is taken from
    % (1 + forecastHorizon : end) and the field data is from
    % (1:end - forecastHorizon).
    
    RequestedFieldData.( modelNames{ii} ) ...
        = requestedFieldTable.Scores(1 : end - forecastHorizon);
    
end

%% Compute test stat for each combination of models with the default

% Take the raw data from the table adjusting for the misaligned indicies as
% noted above.
idxRawData  = 1 + forecastHorizon;
inRawData   = rawDataTable( idxRawData : end, :).Data;

% Calculate the Total Economic Loss test stat for all models available.
for ii = 1 : nModelNames
    
    isDefaultModel  = strcmpi( defaultModelName, modelNames{ii} );
    
    % Calculate the Total Economic Loss.
    TotalEconomicLoss.( modelNames{ii} ) ...
        = statTestFns.hit(...
        RequestedFieldData.( defaultModelName ), ...
        RequestedFieldData.( modelNames{ii} ), ...
        inRawData, eventThreshold, eventType);
end

end

