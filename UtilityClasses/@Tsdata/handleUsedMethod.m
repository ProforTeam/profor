function handleUsedMethod(src, evnt)
% handleUsedMethod   -  Updates affected object to store the used method in 
%                       obj.changeLog.
%
%   Input:
%       src     [Tsdata]
%           Instance of the data class. 
%       evnt    [usedMethodEventData]
%           instance of the usedMethodEventData class. 
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

% Create a cell storing the event name and the usedMethod. 
change          = {evnt.EventName, evnt.usedMethod, ''};

% Update the changeLog to store the changes.
src.changeLog   = [src.changeLog change];


switch evnt.usedMethod
    
    case{'convertData'}
        src.conversionState     = src.dataSettings.doConversionTo;   
    case{'sesAdjData'}                
        src.sesAdjState         = 'y';   
    case{'trendAdjData'}
        src.trendAdjState       = 'y';
    case{'transformData'}        
        src.transfState         = src.dataSettings.doTransfTo;
    case{'outlierCorrData'}            
        src.outlierState        = 'y'; 
                        
end

