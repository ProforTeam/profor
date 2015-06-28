function x = checkBatchSettings( obj )
% checkBatchSettings    Set all the properties once more to check if they are 
%                       correct.

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

props   = properties(obj);
metaC   = metaclass(obj);

for i = 1 : numel( props )
    metaCi  = findobj( [metaC.Properties{:}], 'Name', props{i} );
    
    if ~metaCi.Constant && ~metaCi.Dependent && ...
            ~any(strcmpi(props{i},{'state','links'}))
        x       = obj.( props{i} );
        
        if isa(x, 'CellObj')
            if ~isempty( x.sameSizeAs )
                if ~x.default
                    if obj.( x.sameSizeAs ).numc ~= x.numc;
                        error([mfilename ':checkBatchSettings'], ...
                            ['Batch setting: ' props{i} ' has wrong size'])
                    end
                end
            end
            %obj.(props{i}).x=x.x;
        else
            obj.(props{i})  = x;
        end
    end
end

x       = true;

% Set selectionA equal to selectionY if selectionY is not set
if obj.selectionA.default
    obj.selectionA  = obj.selectionY;
end
end
