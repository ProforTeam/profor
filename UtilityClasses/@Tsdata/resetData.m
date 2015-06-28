function resetData(obj)
% resetData   -  Resets Tsdata obj to original settings.
%   i.e. the form and settings that they had when constructing or loading.
%
% Usage: 
%
%   d.resetData
%
% Note: 
%   All functions applied to the data will change the content of the Tsdata 
%   object. Using resetData brings the data as well as settings back to original 
%   form
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

% Return all property names that are not dependent or constant, as well as the
% original data and the change log.
propertyNames   = Tsdata.getPropertiesNotDependentAndConstant;

nObj            = numel(obj);
for i = 1 : nObj
    
    % Notify change: Do this before any changes!
    notify(obj(i), 'usedMethod', TsdataEventData('resetData'));
    
    % For each of the propeties reset to their original values via accessing the
    % orignal structure attribute.
    for j = 1 : numel(propertyNames)
        try
            obj(i).( propertyNames{j} )     = obj(i).originalStruct.( propertyNames{j} );
        catch Me
            getReport(Me)
        end
    end
end

end