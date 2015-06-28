classdef BrierScoreSetting
    % BrierScoreSetting - A class to define settings for using the Brier scoring
    % metric. 
    %
    % BrierScoreSetting Properties:
    %     eventThresholdValue - Numeric
    %     eventType           - CellObj
    %     nBins               - Numeric
    %
    % See also BATCHCOMBINATION
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
        eventThresholdValue = NaN; % Scalar, defining the threshold value
        % eventType - CellObj, cellstr defining the eventType. 
        % Either leftHandSide or rightHandSide. Default = leftHandSide
        eventType           = CellObj( {'leftHandSide'}, 'type', 1,...
                              'restrictions', {'leftHandSide', 'rightHandSide'});        
        nBins               = 10;  % Scalar. Default = 10                              
    end
    
    methods
       
        function obj = BrierScoreSetting()
        end
                
        function obj = set.eventThresholdValue(obj, value)            
           if ~isnumeric(value)
               error([mfilename ':seteventThresholdValue'],'The eventThresholdValue property must be a numeric (vector)')
           else
               obj.eventThresholdValue = value;
           end           
        end
        
        function obj = set.eventType(obj, value)
            obj.eventType = Batch.setCellObj(obj.eventType, value);                                               
        end
        
        function obj = set.nBins(obj, value)
            if ~isscalar(value)
                error([mfilename ':setnBins'],'The nBins property must be scalar')
            else
                if value < 1
                    error([mfilename ':setnBins'],'The nBins property must be larger than 1')
                else
                    obj.nBins = value;
                end                
            end            
        end
        
    end
    
    
    
end
