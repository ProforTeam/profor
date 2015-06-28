classdef ForecastSetting 
    % ForecastSetting - A class to define forecasting settings. Used in
    % Batch classes 
    %
    % ForecastSetting Properties:
    %   nfor            - Numeric
    %   forecastMethod  - ForecastSetting
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
        % nfor - Number of forecast horizons. If nfor = 0, no forecasts will be 
        % made. If nfor = h > 0, 1,2,...,h step ahead forecasts will be made
        % starting from the last available observation point. Default = 0        
        nfor = 0; 
        % forecastMethod - Either norm (draws from normal or bootstrap, 
        % depending on bootstrapmathod) or kfmse - defines the way forecast are 
        % made. kfmse can make conditional forecasts                      
        forecastMethod = CellObj({'norm'},'type',1,'restrictions',{'norm','kfmse'}); % % 
    end
    
    methods
    
        function obj=ForecastSetting()
        end        
        
        function obj=set.nfor(obj,value)                    
            if ~isscalar(value) || ~isnumeric(value)                
                error([mfilename ':setnfor'],'The nfor property must be scalar')
            end
            if value<0
                error([mfilename ':setnfor'],'The nfor property must be zero or positive')                
            end
            obj.nfor=value;
        end                
        function obj=set.forecastMethod(obj,value)
            obj.forecastMethod=Batch.setCellObj(obj.forecastMethod,value);            
        end         
        
        function x=checkSettings(obj,batchObj)            
            % Set all the properties once more to check if they are
            % correct.
            props=properties(obj);
            metaC=metaclass(obj);
            for i=1:numel(props)                
                metaCi=findobj([metaC.Properties{:}],'Name',props{i});
                if ~metaCi.Constant && ~metaCi.Dependent && ~any(strcmpi(props{i},{'state','links'}))                    
                    x=obj.(props{i});
                    if isa(x,'CellObj')
                        if ~isempty(x.sameSizeAs)
                            if ~x.default
                                if isprop(obj,x.sameSizeAs)
                                    if obj.(x.sameSizeAs).numc~=x.numc;                                    
                                        error([mfilename ':checkBatchSettings'],[mfilename ' setting: ' props{i} ' has wrong size'])
                                    end                                
                                else
                                    if batchObj.(x.sameSizeAs).numc~=x.numc;                                    
                                        error([mfilename ':checkBatchSettings'],[mfilename ' setting: ' props{i} ' has wrong size'])
                                    end                                                                    
                                end
                            end
                        end
                    end
                    obj.(props{i})=x;                    
                end
            end   
            x=true;
        end                                                        
        
    end

end