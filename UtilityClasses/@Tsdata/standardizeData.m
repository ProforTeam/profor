function standardizeData(obj)
% standardizeData - 
%
% Usage:
%
%   d.standardizeData
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

nObj    = numel(obj);
for j = 1 : nObj
    
    % Obtain the dimension of the data set.
    data            = obj(j).getData;
    t               = size(data);    
    
    % Standardise the data by de-meaning and normalising by its standard
    % deviation.
    x           = ( data - obj(j).getMean )...
                        ./ repmat( obj(j).getStd, t);
    
    obj(j).ts   = Tsdata.setTs(obj(j).getDates, x);                     
                    
    % Trigger event notification for the method standardizeData. 
    notify(obj(j), 'usedMethod', TsdataEventData('standardizeData'));

end
end