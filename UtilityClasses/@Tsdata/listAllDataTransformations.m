function listAllDataTransformations( obj )
% listAllDataTransformations - Lists all of the data transformations available.
%
% Input:
%
%   obj         [Tsdata]    
%   varargin    [string, input]         string followed by input
%
% Usage:
%   obj.listAllDataTransformations
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

% Set up the output cell to print to screen. 
transformationDisplay = cell(14, 3);

% Populate the cell with the info from the container maps.
transformationDisplay(:, 1) = obj.transformationMapObj.dm.values';
transformationDisplay(:, 2) = obj.transformationMapObj.dm.keys';

% Select the appropriate values using the keys. 
transformationDisplay(:, 3) = obj.transformationMapObj.tm.values( ...
    transformationDisplay(:, 2) )';

% Rearrange the map into ascending order.
[sortedKeys, idxSorted] = sortrows(obj.transformationMapObj.tm.values');

% Reorder the cells.
transformationDisplay(idxSorted, :);

% Only output first two columns,
transformationDisplay(idxSorted, 1:2)
end
