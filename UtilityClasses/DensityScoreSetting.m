classdef DensityScoreSetting
    % DensityScoreSetting - A class to define settings for using the different
    % density scoring methods
    %
    % DensityScoreSetting Properties:
    %     logScoreMethod        - CellObj
    %     crpScoreMethod        - CellObj
    %     scoringMethods        - CellObj
    %     xDomain               - CellObj
    %     optimize              - Logical    
    %     combinationMethod     - CellObj
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
        % logScoreMethod - CellObj, cellstr defining the method used to compute 
        % log score.                 
        logScoreMethod =      CellObj( {'ksdensity'}, 'type', 1,...
                              'restrictions', {'normal', 'ksdensity'});
        % crpScoreMethod - CellObj, cellstr defining the method used to compute 
        % Continuous-Ranked Probability Score
        crpScoreMethod =      CellObj( {'method1'}, 'type', 1,...
                              'restrictions', {'method1', 'method2'});
        % scoringMethods - CellObj containing the scoring metrix that
        % should be used to combine the individual model forecasts. 
        % Default = logScore. Once initialized, type b.scoringMethods.restrictions
        % to see the different options
        scoringMethods          = CellObj( {'logScore'}, 'type', 1, 'restrictions', ...
            {'equal', 'mse', 'logScore', 'crpsD', 'logScoreD', 'mvnLogScore', ...
            'brierScoreThresholdMap', 'cdfEventThresholdMap'});
        % xDomain - CellObj with contains xDomains for the different
        % variables that are being combined. Input should be a cell, where
        % the xDomain for each variable is placed in the respective
        % locations. Must match the size of selectionY in the Batch file that 
        % utilizes the DensityScoreSetting object - where selectionY
        % are the variables that are being combined. Default = empty, i.e.,
        % program desides the xDomain. Under the default the program
        % computes the xDomain automatically for each model and variable
        % based on the algorithm in TsdataForecast. When the densities are
        % combined one common xDomain is constructed based on the
        % individual xDomains, new densities (from the individual models)
        % are constructed based on this common xDomain, and then finally
        % combined. That is: Under the Default option, no common xDomain is
        % used in evaluation, but common (possibly different) xDomain is
        % used to construct the combined density forecast. If the user
        % specifies a xDomain here, in DensityScoreSetting, this will be
        % used throughout the analysis. That is, all models are scored
        % using the same xDomain, all densities are generated using the
        % same xDomain etc. 
        xDomain                 = CellObj([],'type',2);                      
        % xDomainLength - scalar. If xDomain is empty, program uses
        % xDomainLenght when constructing the xDomain for the individual
        % models. See also description for xDomain. Typically a longer xDomain
        % will give more accurate results, but also use more memory which
        % makes program executin more slow
        xDomainLength           = 500;            
        % optimize - Logical. If true, optimal weighs are computed.
        % ...Default = false
        optimize                = false;                 
        % combinationMethod - CellObj, cellstr defining how to combine the
        % models using either linear opinion pool or log opinion pool.
        % Default = 'linear'
        combinationMethod       =      CellObj( {'linear'}, 'type', 1,...
                                       'restrictions', {'linear', 'log'});        
                          
    end
    
    methods
       
        function obj = DensityScoreSetting()
        end
                
        function obj = set.logScoreMethod(obj, value)
            obj.logScoreMethod = Batch.setCellObj(obj.logScoreMethod, value);                                               
        end
        
        function obj = set.crpScoreMethod(obj, value)
            obj.crpScoreMethod = Batch.setCellObj(obj.crpScoreMethod, value);                                               
        end                
        
        function obj = set.scoringMethods(obj,value)
            obj.scoringMethods = Batch.setCellObj( obj.scoringMethods, value );
        end
        
        function obj = set.xDomain(obj, value)
            obj.xDomain = Batch.setCellObj(obj.xDomain,value);
        end        
        
        function obj = set.xDomainLength(obj,value)
            if isscalar(value)
                if value > 100 
                    obj.xDomainLength = value;
                else
                    error([mfilename ':setxDomainLength'],'The xDomainLength property must be larger than 100')
                end
            else
                error([mfilename ':setxDomainLength'],'The xDomainLength property must be a scalar')
            end
            
        end
        
        function obj = set.optimize(obj, value)
            if ~islogical(value)
                error([mfilename ':setoptimize'],'The optimize property must be a logical')
            end
            obj.optimize = value;
        end        
        
        function obj = set.combinationMethod(obj, value)
            obj.combinationMethod = Batch.setCellObj(obj.combinationMethod, value);                                               
        end                        
        
    end
    
    
    
end
