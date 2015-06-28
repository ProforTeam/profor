function obj = loado( path )
% loado         Loads model object from disk into MATLAB workspace
%
% USAGE: m = Model.loado( <path with name of .mat file> )
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

% First, load using regular function. This will bring obj into
% work space
load(path)

% Get the path from where you are loading from. If errors during
% load, you will not be able to evaluate these codes anyway, so if
% here, the fileexists
[pathStr]   = fileparts( path );

% If not changes, do nothing but return the object, else change paths
if ~strcmpi(pathStr, obj.savePath)
    % Update the links and savePath properties
    obj.savePath            = pathStr;
    obj.links.filePath      = pathStr;
end
end
