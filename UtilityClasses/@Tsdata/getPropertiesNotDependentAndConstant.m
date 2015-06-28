function outAttributes = getPropertiesNotDependentAndConstant
% getPropertiesNotDependentAndConstant - Returns obj properties that not
% dependent or constant, as well as the originalStruct and changeLog.
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

% Get the meta data from the class Tsdata and obtain a cell list of properties.
objMetaInfo             = ?Tsdata;                                
listMetaProperties      = objMetaInfo.Properties;
nProperties             = numel(listMetaProperties);

% The types of property to exclude.
propertiesToExclude     = {'Constant', true, '-or', 'Dependent', true};

% Loop through all properties and only store the non-excluded and non
% originalStruct or changeLog attributes.
outAttributes           = [];
for i = 1 : nProperties    
    objectWithExcludedProperties   = findobj(listMetaProperties{i}, propertiesToExclude);
          
    if isempty(objectWithExcludedProperties)         
        if ~any(strcmpi( listMetaProperties{i}.Name, {'originalStruct','changeLog'} ))
            % Store only the attributes that are required.
            outAttributes     = cat(2, outAttributes, {listMetaProperties{i}.Name} );        
        end        
    end    
end

end