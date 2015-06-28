function getVariablesFromStruct( s )
% getVariablesFromStruct - Pass in a structure s and return the fieldnames with 
%                          their values.
% A convenient way to extract parameters being passed in functions.
%
% Input: 
%   s   [struct]
%
% Output:
%   (fieldname = value)     Fieldname and value pairs are returned to fn 
%                           workspace.
%
% NB. Use with care, will overwrite variables with the same name in the current
% workspace. 
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

% Loop over all field names and extract the name and value to be passed back to
% the function calling. 
for n = fieldnames(s)'
    name    = n{1};
    value   = s.( name );
    
    % Return the (name, value) pair back to the fn. 
    assignin('caller', name, value);
end

end
