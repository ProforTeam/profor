classdef Batchexternalanalytic < Batch
    % Batchexternalanalytic Keep as similar as possible to batchvar as basis to
    % construct estimation and forecast objects. Change afterwards.
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
    
    properties
        nlag                = 1; % TODO: Kept to avoid errors thrown later - need to remove.
        forecastSettings    = ForecastSetting();
        generalSettings     = GeneralSetting();
    end
    
    properties(Abstract = false, SetAccess = protected)
        method = 'externalanalytic';
    end
    
    properties(Abstract = false)
        freq = '';
    end
    
    methods
        function obj = Batchexternalanalytic()
        end
        
        % Get / Set Methods.
        function set.freq(obj, value)
            if isnumeric(value)
                value = convertFreqN(value);
            end
            obj.freq = value;
        end
        
        function set.forecastSettings(obj, value)
            if ~isa(value, 'ForecastSetting')
                error([mfilename ':setforecastSettings'],'The forecastSettings property must be a ForecastSetting class')
            else
                obj.forecastSettings = value;
            end
        end
        
        function set.generalSettings(obj, value)
            if ~isa(value, 'GeneralSetting')
                error([mfilename ':setgeneralSettings'],'The generalSettings property must be a GeneralSetting class')
            else
                obj.generalSettings = value;
            end
        end
        
        %% General methods.
        x = checkBatchSettings(obj)
        xx = checkInitialization(obj, obje)
    end
    
end