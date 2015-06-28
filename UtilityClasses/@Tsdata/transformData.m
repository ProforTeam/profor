function transformData(obj)
% transformData     -    Transforms data
%
% Usage:
%
%   d.transformData
%
% Note: 
%   Function uses information in the obj.dataSettings property. For
%   information about current transformation type d.transfState. For
%   information about different transformation possibilities type 
%   TransformationMapping.keySet
%
% See also DATASETTING
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
        
    transfNumeric   = obj(j).transformationMapObj.tm( obj(j).dataSettings.doTransfTo );
    x               = doDataTransformation(...
                                            obj(j).getData,...
                                            transfNumeric,...
                                            obj(j).freq...
                                            );
                                
    obj(j).ts        = Tsdata.setTs(obj(j).getDates, x);                                        
                            
    notify(obj(j), 'usedMethod', TsdataEventData('transformData'));
    
end

end