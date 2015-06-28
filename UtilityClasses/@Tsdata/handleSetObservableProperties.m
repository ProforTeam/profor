function handleSetObservableProperties(src, evnt)
% handleSetObservableProperties     - Updates affected object to store the
% changes in obj.changeLog.
%
%   Input:
%       src     [meta.property]
%           Meta property data for the property being tracked.
%       evnt    [event.PropertyEvent]
%           The property of the event being passed from addlistener.
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

% Extract the new property value that has been changed.
newPropertyValue                = evnt.AffectedObject.(src.Name);

% Create a cell storing the event name, the property name, and the change that
% was made to the property. 
change                          = {evnt.EventName, src.Name, newPropertyValue};
                                
% Update the changeLog to store the changes in the affected object. 
evnt.AffectedObject.changeLog   = [evnt.AffectedObject.changeLog change];

end
