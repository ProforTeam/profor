function intPolData(obj)
% intPolData    - Interpolates data based on obj.missingValues property.
%
% Usage: 
%
%   d.intPolData
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

for j = 1 : numel(obj)
    if obj(j).getMissingValues
        y           = fixgaps( obj(j).getData );        
        obj(j).ts   = Tsdata.setTs(obj(j).getDates, y);
        % Notify change
        notify(obj(j), 'usedMethod', TsdataEventData('intPolData'));
    end
end
end