function nLines = returnNumberOfLines( fileName, errType )
% returnNumberOfLines - Returns the number of lines in a file.
%   Might be better ways to do this that are operating system specific. 
%   See http://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-
%   to-determine-the-number-of-lines-in-a-file-without-loop.
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

% Error handling
narginchk(1, 2);

if nargin < 2
    errType = [mfilename, ': '];
end

% Open the file
fid = fopen(fileName);

% Count the number of lines - currently using same method across operating
% systems - keep for general structure.

if (isunix) %# Linux, mac
    allText     = textscan(fid,'%s','delimiter','\n');
    nLines      = length(allText{1});
    fclose(fid);
    
elseif (ispc) %# Windows
    allText     = textscan(fid,'%s','delimiter','\n');
    nLines      = length(allText{1});
    fclose(fid);
        
else
    error(errType, 'Operating system not recognised');
    
end