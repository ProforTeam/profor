function cellNonEmptyTest = isCellNonEmpty( value, errType )
% isCellNonEmpty - Returns an index of non-empty locations of a cell array.
% 
% Input:
%   value               [cell]
%   errType             [str]
%
% Output:
%   cellNonEmptyTest     [logical]   

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

% Error handling
narginchk(1, 2);

if nargin < 2
    errType = [mfilename, ': '];
end

if ~iscell( value )
    error( errType, 'Input value is not a cell array - test for cell arrays.')
end

% Return an index of the non empty locations.
cellNonEmptyTest    = ~cellfun(@isempty, value);

end