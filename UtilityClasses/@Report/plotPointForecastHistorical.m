function plotPointForecastHistorical(obj, vblNames, modelNames, forecastHorizon, realTimeTableExtractionType) 
% plotPointForecastHistorical - 
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

%%

rawDataTable = obj.rawDataTable;
obj.populateResultTable( scoreMethod );


for hh = 1 : nVariableNames
    
    [actual, dates]                     = getDataFromRawDataTable( rawDataTable, vblNames{hh}, realTimeTableExtractionType);

    nPeriods      = numel(actual);
    predictions   = nan(nPeriods,nModels,nHorizons);    
    
    for i = 1:nModels        
        for j = 1:nHorizons

            pointForecastij     = getForecastFromResultTable(obj.resultTable, vblNames{hh}, modelNames{i},forecastHorizon(j),realTimeTableExtractionType);            
            
            if ~isempty(pointForecastij)
                predictions(:,i,j)  = pointForecastij;
            end
            
        end
    end

     % nfor nPeriods numModels from  nPeriods,numModels,nfor
     mat                = permute(predictions,[3 1 2]);            
     A                  = ones(nPeriods + nHorizons,nPeriods);
     B                  = full(logical(spdiags(A,0:-1:-nHorizons, nPeriods + nHorizons, nPeriods)));            
     hairyPlotMatrix    = nan(nPeriods + nHorizons, nPeriods, nModels);            
     
     ColorSet           = figureFns.varycolor(nPeriods);
     
     for i = 1:nModels
         matTmp                      = nan(nPeriods+nHorizons,nPeriods);
         matTmp(B)                   = [actual(:)';
                                        mat(:,:,i)];                                 
         hairyPlotMatrix(:,:,i)    = matTmp;
         
         
         figure('name',[vblNames{hh} ' - Model: ' modelNames{i}])
         
         legendToPlot = plot(actual,'k','lineWidth',obj.plotOptions.lineWidth);                 
         hold on
         set(gca, 'ColorOrder', ColorSet);       
         plot(hairyPlotMatrix(:,:,i),'lineStyle','--','lineWidth',(obj.plotOptions.lineWidth/2))                                        

        
        legendString     = [vblNames{hh} ' - Model: ' modelNames{i}];         
         
        % Squeeze the axis if asked for. 
        if obj.plotOptions.axisTight        
            axis tight
        end

        % Plot legend
        if obj.plotOptions.plotLegend
            lh = legend(legendToPlot, legendString, 'FontSize', obj.plotOptions.legendFontSize);
            set(lh,'box','off','location','best')
        end

        % Set axis.
        [~, ~]      = setXtickAndLabel(dates, 'handle', gca);
        % set(gca, 'fontsize', opt.fontSize);
        set(gca, 'box', 'off');
         
     end;
     
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




