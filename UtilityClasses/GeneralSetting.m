classdef GeneralSetting
    % GeneralSetting - A class to define general settings. Used in
    % Batch classes 
    %
    % GeneralSetting Properties:
    %   alphaSign            - Numeric
    %   confidenceIntMethod  - CellObj
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
        % confidenceIntMethod - Defines how to generate confidence bands
        % based on a given simulation sample with forecasts. Used together
        % with alphaSign.
        confidenceIntMethod = CellObj({'quantile'},'type',1,'restrictions',{'hallsquantile','quantile','norminv','quantilewithmean'});
        % alphaSign - Significance level for tests, and when constructing 
        % confidence bands. Must be between 0 and 1. Default = 0.05         
        alphaSign = 0.05; 
    end
    
    methods
        
        function obj=GeneralSetting()
        end
        
        function obj=set.alphaSign(obj,value)
            if ~isscalar(value) || ~isnumeric(value)
                error([mfilename ':setalfaSign'],'The alfaSign property must be scalar')                
            end            
            if value<0 || value>1
                error([mfilename ':setalfaSign'],'The alfaSign property must be between 0 and 1')                
            end
            obj.alphaSign=value;                        
        end                           
        function obj=set.confidenceIntMethod(obj,value)
            obj.confidenceIntMethod=Batch.setCellObj(obj.confidenceIntMethod,value);
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