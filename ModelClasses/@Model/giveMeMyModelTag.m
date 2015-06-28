function giveMeMyModelTag( obj )
% giveMeMyModelTag

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

list        = dir([proforStartup.pfRoot '/temp']);

% Select only directories.
list        = list([list.isdir]);

numList     = numel(list);
newList     = [];
myName      = 1;
for i = 1 : numList
    
    if ~any( strcmpi(list(i).name, {'.','..','.svn'}) )
        newList     = cat(1,newList,{list(i).name});
        [~, tok, ~] = regexp(newList{end}, 'M(\d*)', 'match', 'tokens');
        
        if ~isempty( tok{:} )
            myName  = myName + 1;
        end
    end
end

link.tag            = ['M' num2str(myName)];
link.filePath       = [proforStartup.pfRoot '/temp/' link.tag];

[status, message]   = mkdir( link.filePath );

if status == 0
    disp( message );
    error('Model:giveMeMyModelTag', ...
        'Could not create model folder in temp dir')
end

% Output
obj.links           = link;

end
