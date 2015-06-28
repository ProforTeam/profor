function checkPath(path,varargin)
% checkPath - Check if path exist, if not, create it
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

if nargin == 1
    mustExist = false;
else
    mustExist = true;
end
if ~(exist(path,'dir') == 7) && ~mustExist
    [a, b] = fileparts(path);
    [status, mess, messid] = mkdir(a, b);
%     if status~=1
%         disp(mess)
%         disp(messid)
%     end;
elseif ~(exist(path,'dir')==7) && mustExist
    error([mfilename ':output'], 'The path do not exist!')    
end
    