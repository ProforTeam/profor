function plotDensityForecastHistorical(obj, vblNames, modelNames, forecastHorizon, realTimeTableExtractionType)
% plotDensityForecastHistorical - 
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

%% TODO: Refactor

freq = 'q';

%% Validation

if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the plotPointForecastHistorical method unless Report contains a Profor class'])
    return
    
else
    
    errType = ['Report:', mfilename];
    
    
    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'modelNames', 'forecastHorizon', 'realTimeTableExtractionType'};
    numberOfInputArgs   = nargin;
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs);
    
end


vblNames        = ifStringConvertToCellstr( vblNames );
modelNames      = ifStringConvertToCellstr( modelNames );
% Just used as input - has no effect
scoreMethod     = ifStringConvertToCellstr( obj.defaultProperties.scoreMethod );
%%

nVariableNames  = numel( vblNames );
nModels         = numel(modelNames);
nHorizons       = numel(forecastHorizon);

if nHorizons > 1
    error(errType, 'For this function it is not allowed to plot more than one horion! Reduce the number of elements in forecastHorizon to one')
end

%%

rawDataTable = obj.rawDataTable;
obj.populateResultTable( scoreMethod );


for hh = 1 : nVariableNames
    
    [actual, dates]                     = getDataFromRawDataTable( rawDataTable, vblNames{hh}, realTimeTableExtractionType);
    
    nPeriods        = numel(actual);
    predictionsSim  = cell(nPeriods,nModels,nHorizons);
    
    for i = 1:nModels
        for j = 1:nHorizons
            
            [~, simForecastij] = getForecastFromResultTable(obj.resultTable, vblNames{hh}, modelNames{i},forecastHorizon(j),realTimeTableExtractionType);
            
            if ~isempty( simForecastij )
                predictionsSim(:,i,j)       = simForecastij;
            end
            
        end
    end
    
    for i = 1:nModels
        
        simulationSmpl = cell2mat(predictionsSim(:,i)');
        
        if ~isempty( simulationSmpl )
            %
            % adjust actual so that there are nans at the end: I.e., the
            % density forecasts will be conditional h-periods ahead from dates
            %
            actualTruncated                            = nan(size(actual));
            actualTruncated(1:end - forecastHorizon)   = actual(1 + forecastHorizon:end);
            
            % Change the dates so that they correspond with the outturns, which
            % have been truncated from below by #forecastHorizon.
            sample = getSample( dates );
            
            % Push the sample forward forecastHorizon and create newDates from
            % this sample
            sample = adjSample(sample, 'q', 'nfor', forecastHorizon);
            newDates = sample2ttt( sample, freq);
            
            % Start the new dates from the forecastHorizons periods into the
            % sample such that the truncated outturns correspond to the dates.
            fanchart            = figureFns.fanChartFigure(simulationSmpl, ...
                newDates(1 + forecastHorizon: end), obj,...
                'forecast',             actualTruncated,...
                'quantiles',            obj.plotOptions.quantiles, ...
                'color',                obj.plotOptions.densityColor.x{:}, ...
                'titleFontSize',        obj.plotOptions.titleFontSize, ...
                'ynames',               vblNames{hh}, ...
                'titleNames',           modelNames(i) ...
                );
            
        end
        
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [actual, dates] = getDataFromRawDataTable( rawDataTable, vblName, realTimeTableExtractType)

varibleNameIdx  = rawDataTable.VariableName == vblName;
tdhh            = rawDataTable(varibleNameIdx == 1,:);

switch lower( realTimeTableExtractType )
    case lower( 'lastRealTime' )
        
        [~,ia,~] = unique(tdhh.Date);
        % C = A(ia) and A = C(ic).
        
    case lower( 'last' )
        
        ia      = find(tdhh.Vintage == tdhh.Vintage(end) == 1);
        
end

actual = tdhh.Data(ia);
dates  = tdhh.Date(ia);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pointForecast, simForecast, dates] = getForecastFromResultTable(resultTable, vblName, modelName, forecastHorizon, realTimeTableExtractionType)

varibleNameIdx  = resultTable.Variable == vblName;
modelNameIdx    = resultTable.ModelName == modelName;
horizonIdx      = resultTable.Horizon   == categorical( forecastHorizon );

tdhh            = resultTable( (varibleNameIdx == 1 & modelNameIdx == 1 & horizonIdx == 1), :);


switch lower( realTimeTableExtractionType )
    case lower( 'lastRealTime' )
        
        [~,ia,~] = unique(tdhh.Periods);
        % C = A(ia) and A = C(ic).
        
    case lower( 'last' )
        
        ia      = find(tdhh.Vintage == tdhh.Vintage(end) == 1);
        
end

pointForecast = tdhh.PointForecast(ia);
simForecast   = tdhh.SimForecast(ia);
dates         = tdhh.Periods(ia);

end


