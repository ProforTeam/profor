function setAll(obj,fieldname,value)
% setAll  - For given input (fieldname,value) pair set across an array of
%           objects.
%
% Input:
%   fieldname 	[string]        
%       Must be a porperty of the object. Only properties with public SetAccess 
%       can be set. 
%       The value (see below) must be in accordance with property attributes, 
%       if not there will be error.
%   value       [numeric/string/etc]
%       Depending on which field you are setting.
%
% USAGE: d.setAll(obj, 'doSesAdj','y') 
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

%% Get meta object and find the properties that can be set for Tsdata
objMetaInfo         = ?TsdataForecast;
listMetaProperties  = objMetaInfo.Properties;

% Set the Tsdata property
idx = getIdx(listMetaProperties, fieldname);
% If the property found and setable then populate all objects with that value,
% otherwise throw error.
if idx == 0
    % Get meta object and find the properties that can be set for Datasetting
    objMetaInfo         = ?DataSetting;
    listMetaProperties  = objMetaInfo.Properties;        
    
    idx                 = getIdx(listMetaProperties, fieldname);
    
    if idx == 0        
        msg = 'The property you have asked to set do not exist or can not be set';
        error([mfilename ':input'], msg)
    else
        for j = 1 : numel(obj)

            obj(j).dataSettings.( fieldname )    = value;

        end        
    end
    
else    
    for j = 1 : numel(obj)

        obj(j).( fieldname )    = value;

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = getIdx(listMetaProperties, fieldname)
    % Find all the settable propeties for the class Tsdata.
    settableProperties  = [];
    nProperties         = numel(listMetaProperties);
    for i = 1 : nProperties

        h   = findobj(listMetaProperties{i}, 'SetAccess', 'public');

        if ~isempty( h )
            settableProperties  = cat(2, settableProperties, {h.Name});
        end

    end

    % Find the location of the input property to set within the list of settable
    % properties.
    idx     = sum( strcmpi( fieldname, settableProperties ) );


end

end