classdef DataSetting
% DataSetting -  Class to define variable transformations for Tsdata and 
% TsdataForecastobjects
%
% DataSetting Properties:
%   doSesAdj            - String. y or n
%   doTrendAdj          - String. y or n
%   doConversionTo      - String 
%   doTransfTo          - String 
%   doOutlierCorr       - String. y or n
%   outlierMethod       - Cell
%   setOutliersAs       - Numeric
%   trendAdjMethod      - Cell
%   setLambdaAs         - Numeric
%   conversionMethod    - Cell         
%   sesAdjMethod        - Cell
%
% Tsdata Methods:
%   DataSetting         - Constructor
%
% See also TSDATA, TSDATAFORECAST
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

    properties(AbortSet = true)
        % doSesAdj - If y the data will be ses. adj. when using sesAdjData
        % method in Tsdata. Default = 'n', i.e., no seasonal adjustment        
        doSesAdj        = 'n';      
        % doTrendAdj - If y the data will be trend. adj. when using trendAdjData
        % method in Tsdata. Default = 'n', i.e., no trend adjustment. 
        % See also  TRENDADJMETHOD, SETLAMBDAAS
        doTrendAdj      = 'n';      
        % doConversionTo - If n no frequency conversion will be done. If not 
        % n (but 'm', 'q' or 'a'), data will be converted (to different freq) 
        % when using convertData method in Tsdata. Default = 'n'  
        % See also  CONVERSIONMETHOD
        doConversionTo  = 'n';       
        % doTransfTo - Defines which type of transformation that should be used 
        % when applying transformData method in Tsdata. Type: 
        % TransformationMapping.keySet for a list of the different
        % possibilities, and type TransformationMapping.description for the
        % associated descriptions. Default = 'n'                 
        doTransfTo      = 'n';      
        % doConversionTo - If y the data will be corrected for outliers. 
        % Default = 'n'.         
        % See also  OUTLIERMETHOD, SETOUTLIERAS
        doOutlierCorr   = 'n';                           
        % outlierMethod - Defines the outlier method. Type
        % obj.outlierMethod.restrictions for the different options
        outlierMethod   = CellObj({'interquartile'}, 'type', 1,....
            'restrictions', {'interquartile', 'sigma'}); 
        setOutliersAs   = 6;        % Defines the outlier limit
        % trendAdjMethod - Defines the trend adj. method. Type
        % obj.trendAdjMethod.restrictions for the different options        
        trendAdjMethod  = CellObj({'linear'}, 'type', 1,....
            'restrictions', {'linear','hp','bp'});      
        setLambdaAs     = 1600;   % Defines the HP filter lambda
        % conversionMethod - Defines the conversion method. Type
        % obj.conversionMethod.restrictions for the different options            
        conversionMethod = CellObj({'mean'}, 'type', 1,....
            'restrictions', {'mean','endOfPeriod','sum'}); 
        % sesAdjMethod - Defines the ses. adj method. Type
        % obj.sesAdjMethod.restrictions for the different options                    
        sesAdjMethod    = CellObj({'x11'}, 'type', 1,....
            'restrictions', {'x11'}); 
                
    end
    
    methods
        
        function obj = DataSetting(doTransfTo, doSesAdj, doTrendAdj, doConversionTo, conversionMethod)
            % DataSetting       Constructor method
            %
            % Input: 
            %
            %   doTransfTo          [char]
            %   doSesAdj            [char], y or n
            %   doTrendAdj          [char], y or n
            %   doConversionTo      [char]
            %   conversionMethod    [cell]
            %
            % Output: 
            %
            %   obj                 [DataSetting]   
            %
            % Usage:
            %
            % obj = DataSetting(doTransfTo, doSesAdj, doTrendAdj, doConversionTo, conversionMethod)
            %
            % Note: The input must be in the order specified above, but not
            % all inputs need to be defined, i.e.,:
            %
            % obj = DataSetting(doTransfTo)
            %
            % will also work
            %
            %
            
            allowableProperties     = {'doTransfTo', 'doSesAdj', 'doTrendAdj', ...
                'doConversionTo', 'conversionMethod'};
            
            for i = 1 : nargin
                
                % if the input variables are not empty, populate the field.
                if ~isempty( eval( allowableProperties{i} ) )
                    obj.( allowableProperties{i} )  = ...
                                        eval( allowableProperties{i} );
                end
                
            end            
            
        end
        
        function obj = set.doSesAdj(obj, value)
            if ~any(strcmpi( value, {'n', 'y'} ))
                error([mfilename ':setdoSesAdj'],'The doSesAdj property must be either n or y') 
            else
                obj.doSesAdj  = value;
            end
        end
        function obj = set.doTrendAdj(obj, value)
            if ~any(strcmpi( value, {'n', 'y'} ))
                error([mfilename ':setdoTrendAdj'],'The doTrendAdj property must be either n or y') 
            else
                obj.doTrendAdj  = value;
            end            
        end                
        function obj = set.doConversionTo(obj,value)
            if ~ischar(value)
               error([mfilename ':setdoConversionTo'],'The input must be a string') 
            else
                if ~any(strcmpi(value,{'n','m','q','a'}))
                    error([mfilename ':setdoConversionTo'],'The input must be a string among: n, m, q or a') 
                else
                    obj.doConversionTo = value;
                end
            end                        
        end            
        function obj = set.doOutlierCorr(obj, value)
            if ~any(strcmpi( value, {'n', 'y'} ))
                error([mfilename ':setdoOutlierCorr'],'The doOutlierCorr property must be either n or y') 
            else
                obj.doOutlierCorr  = value;
            end            
        end                                
        function obj = set.outlierMethod(obj, value)
            obj.outlierMethod = Batch.setCellObj(obj.outlierMethod, value);            
        end          
        function obj = set.trendAdjMethod(obj, value)
            obj.trendAdjMethod = Batch.setCellObj(obj.trendAdjMethod, value);            
        end        
        function obj = set.setOutliersAs(obj, value)
            if ~isscalar(value)
                error([mfilename ':setOutliersAs'], 'The setOutliersAs property must be scalar')
            else
                if value <= 0
                    error([mfilename ':setOutliersAs'], 'The setOutliersAs property must be larger than 0')
                else
                    obj.setOutliersAs = value;
                end
            end
        end
        function obj = set.setLambdaAs(obj, value)
            if ~isscalar(value)
                error([mfilename ':setLambdaAs'], 'The setLambdaAs property must be scalar')
            else
                if value <= 0
                    error([mfilename ':setLambdaAs'], 'The setLambdaAs property must be larger than 0')
                else
                    obj.setLambdaAs = value;
                end
            end
        end                
        function obj = set.doTransfTo(obj, value)      

            transformationMapObj = TransformationMapping();

            if isscalar(value)
                values  = cell2mat(transformationMapObj.tm.values);
                idx     = value == values;
                if any(idx)
                    keys = transformationMapObj.tm.keys;
                    obj.doTransfTo = keys{idx};
                else
                    error([mfilename ':setdoTransfTo'],'The doTransfTo property is not among the once pre-defined. See TransformationMapping.valueSet for allowed values')
                end
            elseif ischar(value)                
                if transformationMapObj.tm.isKey(value)
                    obj.doTransfTo = value;
                else
                    error([mfilename ':setdoTransfTo'],'The doTransfTo property is not among the once pre-defined. See TransformationMapping.keySet for allowed values')
                end
            else
                error([mfilename ':setdoTransfTo'],'The doTransfTo property must be set by either a char or a scalar. See TransformationMapping.valueSet or TransformationMapping.keySet for allowed values')
            end                            
        end        
        function obj = set.conversionMethod(obj, value)
            obj.conversionMethod = Batch.setCellObj(obj.conversionMethod, value);            
        end                  
        function obj = set.sesAdjMethod(obj, value)
            obj.sesAdjMethod = Batch.setCellObj(obj.sesAdjMethod, value);            
        end                                  
        
    end
end