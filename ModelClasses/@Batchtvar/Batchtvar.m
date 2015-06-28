classdef Batchtvar < Batchvar
    % Batchtvar - A class to define run settings for TVAR models    
    %
    % Batchtvar is a child of Batchvar    
    %
    % Batchtvar Properties:
    %   thresholdVariableIndex  - Numeric
    %   maxDecay                - Numeric
    %   thresholdQuantile       - Numeric
    %
    % See also BATCHVAR 
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesExample.m,1)">this example file</a>
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
        % thresholdVariableIndex - Index for which among the n variables in
        % selectionY that should be used as threshold indicator variable.
        % Default = 1
        thresholdVariableIndex = 1; 
        % maxDecay - Number used for setting the maximum number of decay facotrs
        % to search among. Can at maximum be as large as nlag (See
        % BATCHVAR). Default = 1
        maxDecay = 1                  
        % thresholdQuantile - quantile to be used to truncate the order
        % statistic of the threshold variable. Default = 0.15
        thresholdQuantile = 0.15;
    end
    
    
    methods
        function obj = Batchtvar()
            obj.method = 'tvar';
        end
        
        % Get / Set Methods.
        function set.thresholdVariableIndex(obj, value)
            if ~isnumeric(value)
                error([mfilename ':setthresholdVariableIndex'],'thresholdVariableIndex must be a numeric')
            else
                if value < 1
                    error([mfilename ':setthresholdVariableIndex'],'thresholdVariableIndex must be larger than or equal to 1')
                else
                    obj.thresholdVariableIndex = value;
                end
            end
        end
        function set.maxDecay(obj, value)            
            if ~isnumeric(value)
                error([mfilename ':setmaxDecay'],'maxDecay must be a numeric')
            else
                if value < 1
                    error([mfilename ':setmaxDecay'],'maxDecay must be larger than or equal to 1')
                else
                    obj.maxDecay = value;
                end
            end            
        end
        function set.thresholdQuantile(obj, value)            
            if ~isnumeric(value)
                error([mfilename ':setthresholdQuantile'],'thresholdQuantile must be a numeric')
            else
                if value >= 1 || value <= 0
                    error([mfilename ':setmaxDecay'],'thresholdQuantile must be larger than 0 and less than 1')
                else
                    obj.thresholdQuantile = value;
                end
            end            
        end        
                                
        %% General methods.
        x  = checkBatchSettings(obj)
        xx = checkInitialization(obj, obje)
    end
    
end