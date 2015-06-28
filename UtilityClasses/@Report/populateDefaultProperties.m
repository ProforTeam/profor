function populateDefaultProperties( obj )
% populateDefaultProperties Populates the defaultProperties structure
%                         based on the settings in the allowableProperties
%                         structure.
%
% Inputs:
%   obj                     [Report]
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty( obj.proforObj )
    mb          = true;
else
    mb           = false;
    batchFile    = load( fullfile(obj.proforObj.pathA,'Combo.mat') );
    batchFile    = batchFile.b;
end



fnames = fieldnames( obj.allowableProperties );
for i = 1 : numel(fnames)
    
    fieldi = obj.defaultProperties.(fnames{i});
    % Populate the fields that are empty
    if isempty(fieldi)
        
        switch fnames{i}
            
            case{'forecastHorizon'}
                obj.defaultProperties.forecastHorizon   = min(obj.allowableProperties(1).forecastHorizon);
            case{'defaultModelName'}
                obj.defaultProperties.defaultModelName  = obj.allowableProperties(1).defaultModelName{1};
            case{'scoreMethod'}
                if ~mb
                    obj.defaultProperties.scoreMethod       = obj.allowableProperties(1).scoreMethod{1};
                end
            case{'requestedVintage'}
                if ~mb
                    obj.defaultProperties.requestedVintage  = obj.allowableProperties(1).requestedVintage(end);
                end
            case{'startPeriod'}
                if ~mb
                    obj.defaultProperties.startPeriod       = obj.allowableProperties(1).startPeriod(1);
                end
            case{'endPeriod'}
                if ~mb
                    obj.defaultProperties.endPeriod         = obj.allowableProperties(1).endPeriod(end);
                end
            case{'eventThreshold'}
                if ~mb
                    obj.defaultProperties.eventThreshold    = obj.allowableProperties(1).eventThreshold(1);
                end
            case{'eventType'}
                if ~mb
                    obj.defaultProperties.eventType    = batchFile.brierScoreSettings.eventType.xNonEmpty;
                end
                
                
                % Finally all the other fields that we can just copy over
            case{'vblNames','modelNames'}
                obj.defaultProperties.(fnames{i})       = obj.allowableProperties(1).(fnames{i});
                
                
        end
        
    end
    
end
