function argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs)
% argumentPassingScript - 
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

nIn = numel(inputNamesNeeded);

if numberOfInputArgs == 1
    for i = 1 : nIn
        value = obj.defaultProperties.( inputNamesNeeded{i} );
        assignin('caller', inputNamesNeeded{i}, value);
    end
else
    for i = 1:nIn
        
        valueIn = evalin('caller', inputNamesNeeded{i});
        
        if isempty(valueIn)
            value = obj.defaultProperties.( inputNamesNeeded{i} );
            assignin('caller', inputNamesNeeded{i}, value);
        else
            % Check the input against allowableProperties(2)
            if ~feval( obj.allowableProperties(2).( inputNamesNeeded{i} ), ...
                    valueIn, obj.allowableProperties(1).( inputNamesNeeded{i} ));
                error([mfilename ':usersuppliedInput'],'The input variable %s is not correctly specified',inputNamesNeeded{i})
            end
            
        end
        
    end
    
end