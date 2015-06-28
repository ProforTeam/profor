function transformData(obj)
% transformData    -     Transforms data
%
% See also DATASETTING, TSDATA.TRANSFORMDATA
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

nObj    = numel( obj );
for j = 1 : nObj
        
    if obj(j).isHistoryLevel
    
        transfNumeric   = obj(j).transformationMapObj.tm( obj(j).dataSettings.doTransfTo );
        transfState     = obj(j).transformationMapObj.tm( obj(j).transfState );

        % get some preliminaries for computation and output    
        [dataPoint, dataDates, dataHistoryLevel, ~,...
            forecastSimulations, ~] = extractNeededInformation(obj(j));

        draws               = obj(j).getDraws;
        numberOfForecast    = obj(j).getNfor;
        freq                = obj(j).freq;

        % First create level, and then the desired transformation                
        forecastLevel       = reDoDataTransUtil(dataPoint(obj(j).forecastStartIdx:end), dataHistoryLevel,...
                                    'freq', freq,...
                                    'forecastFreq', transfState);                                                                
        forecastLevelSim    = reDoDataTransUtil(forecastSimulations(obj(j).forecastStartIdx:end,:), dataHistoryLevel,...
                                    'freq', freq,...
                                    'forecastFreq', transfState);                                                                    

        data    = [dataHistoryLevel; forecastLevel];
        dataS   = [repmat(dataHistoryLevel, [1 draws]); forecastLevelSim];                                                    

        % Convert forecasts from level into desired transformation
        forecastPoint               = doDataTransformation(...
                                        data,...
                                        transfNumeric,...
                                        obj(j).freq,...
                                        'initialValues', 0 ...  % Need this to ensure that the ts property does not change length
                                         );
        xS                          = doDataTransformation(...
                                        dataS,...
                                        repmat(transfNumeric, [1 draws]),...
                                        obj(j).freq...
                                         );                                

        forecastSimulations     = xS(end - numberOfForecast + 1:end,:);     
        forecastDates           = dataDates(end - numberOfForecast + 1:end,:);                            

        obj(j).ts               = TsdataForecast.setTs(dataDates, forecastPoint);                
        obj(j).tsSimulations    = TsdataForecast.setTs(forecastDates, forecastSimulations);                                

        notify(obj(j), 'usedMethod', TsdataEventData('transformData'));
        
    else
       warning([mfilename ':isHistoryLevel'],'There is no history level in the object, Can not do transformation') 
    end
        
    
end

end