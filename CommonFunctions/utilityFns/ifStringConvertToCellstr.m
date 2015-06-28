function inVbl = ifStringConvertToCellstr( inVbl )
% ifStringConvertToCellstr - Helper fn that converts to cellstr if str, 
%                            return error if neither.
%
% Input:
%   InVbl               [Any]    
%
% Output:
%   inVbl               [cell]
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


% If categorical convert to cell, otherwise return original.
if ischar( inVbl )
    inVbl   = cellstr( inVbl );   

elseif iscellstr( inVbl )
    return
    
else
    error(mfilename, 'Input neither a str or cellstr, please check input args')
end

end

