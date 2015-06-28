function [transfState] = checkInput(forecastPoint, forecastSimulations, forecastDates,...
    history, historyDates, historyLevel, transfState)
% checkInput - 
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

    if size(forecastSimulations,1) ~= size(forecastPoint,1)
        error([mfilename ':input'],'forecastPoint and forecastSimulations should have equal number of rows')
    end                        
    if numel(forecastDates) ~= numel(forecastPoint)
        error([mfilename ':input'],'forecastDates or forecasts vestors not correct size')                
    end       
    
    if ~isempty(history) 
        if isempty(historyDates)
            error([mfilename ':input'],'history provided but not historyDates')                
        else            
            if numel(historyDates) ~= numel(history)
                error([mfilename ':input'],'historyDates or history vectors not correct size')                
            end                                                        
        end
        if ~isempty(historyLevel)        
            if size(history,1) ~= size(historyLevel,1)
                error([mfilename ':input'],'history and historyLevel should have equal number of rows')            
            end                    
        end
    end
    
    transformationMapObj = TransformationMapping();
    if isnumeric(transfState)
        values  = cell2mat(transformationMapObj.tm.values);
        idx     = transfState == values;
        if any(idx)
            keys = transformationMapObj.tm.keys;
            transfState = keys{idx};
        else
            error([mfilename ':input'],'transfState not recognised')
        end
    elseif ischar(transfState)                
        if ~transformationMapObj.tm.isKey(transfState)
            error([mfilename ':input'],'transfState not recognised')
        end
    end
        

    
  

end