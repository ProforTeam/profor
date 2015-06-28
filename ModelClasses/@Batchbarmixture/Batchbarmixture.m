classdef Batchbarmixture < Batchvar
    % Batchbarmixture - A class to define run settings for Bayesian AR
    % mixture models
    %
    % Batchbarmixture is a child of Batchvar
    %
    % Batchbarmixture Properties:
    %   priorSettings       - PriorSetting
    %   mixtureNormalOnly   - Logical
    %
    % See also BATCHVAR, BATCH, PRIORSETTING 
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/runArMixtureModelExample.m,1)">this example file</a>
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
        % priorSettings - PriorSetting object. Defines the prior settings
        %
        % See also PRIORSETTING
        priorSettings       = PriorSetting({'tr','mix'},{'normal_whishart',''});
        % mixtureNormalOnly - Logical, if true, no RHS variables will be
        % included in the model estimation (irrespective of the nlag
        % setting). Default = false.
        mixtureNormalOnly = false;
    end       
    
    methods
        
        function obj = Batchbarmixture()                                    
            obj.method = 'barmixture';
        end        
               
        function set.mixtureNormalOnly(obj, value)
           if ~islogical(value)
               error([mfilename ':setmixtureNormalOnly'],'mixtureNormalOnly must be a logical')
           else
               obj.mixtureNormalOnly = value;
           end
            
        end
        
        function x = checkBatchSettings(obj)        

            % call parent object 
            x = checkBatchSettings@Batchvar(obj);            
            
            % Check prior settings
            x = checkSettings(obj.priorSettings, obj);                                                 
            
            if ~obj.priorSettings.doMinnesota
                
                if ~obj.mixtureNormalOnly
                    % Check that the priors are externally correct size (internal
                    % consistency is ensrued by the Prior object itself)            
                    if size(obj.priorSettings.tr.T,1) ~= obj.selectionA.numc || size(obj.priorSettings.tr.T,2) ~= obj.selectionA.numc*obj.nlag +1 % + constanta and exogenous
                        error([mfilename ':checkBatchSettings'],'The size of the prior specification is not consistent with selectionA and nlag')                
                    end
                end
                
            else
                
                error([mfilename ':input'],'The Batcharmixture model does not support Minnesota style priors')
                
            end

            if obj.selectionA.numc > 1
                
                error([mfilename ':input'],'The Batcharmixture model does not support vector input for LHS variables')
                
            end
            
        end                   
        
        function xx = checkInitialization(obj, obje)                            
            xx = checkInitialization@Batchvar(obj,obje);
        end

    end
    
end