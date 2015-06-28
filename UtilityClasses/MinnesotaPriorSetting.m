classdef MinnesotaPriorSetting       
    % MinnesotaPriorSetting - A small class to define the settings to be
    % used together with the Minnestoa Prior for estimation of e.g., BVARs
    %
    % MinnesotaPriorSetting Properties:
    %       vprior  - Numeric
    %       abar1   - Numeric
    %       abar2   - Numeric
    %       abar3   - Numeric
    %       type    = CellObj
    %
    % MinnesotaPriorSetting Methods:
    %         MinnesotaPriorSetting    - Constructor             
    %
    % See also PRIORSETTING
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
        % vprior - numeric. Defines the "weight" to be put on the prior
        % relative to the sample size, i.e., the number should reflect a
        % percentage. Default = 10 
        vprior  = 10;
        % abar1 - numeric. Defines the scaling of the prior for the covariance 
        % across the parameters, i.e., the Vprior. Default = 0.6
        % The Vprior is set according to this scheme:
        %    V_(i,jj) =  abar1/nlag^2 i==jj
        %    V_(i,jj) =  (abar2*sigma_(i,i))/(nlag^2*simga_(j,j)) i~jj
        %    V_(i,jj) =  abar3*sigma_(i,i) exogenous variables        
        % where sigma is the covariance matrix of a standard VAR estimation
        %
        % See also PRIORS                
        abar1   = 0.6;
        % abar2 - numeric. See help for abar1 above. Default = 0.5        
        abar2   = 0.5;
        % abar3 - numeric. See help for abar1 above. Default = 0.1                
        abar3   = 0.1;
        % type - Cellobj. Defines how to construct the prior for the
        % parameters, i.e. Tprior. Three options: ar, fix, rw:
        % ar: uses the univariate implied AR(1) estimate for the first lag of the
        % dependent variable in each equation of the system. All other 
        % coeffcients are set to zero. 
        % fix and rw: sets the first lag of the dependent variable in each equation 
        % of the system to 0.9 and 1, respectively. All other coeffcients are 
        % set to zero. Default = 'ar'
        type    = CellObj({'ar'},'type',1,'restrictions',{'ar','fix','rw'});                                
    end    
    
    methods
        
        function obj = MinnesotaPriorSetting()        
            % MinnesotaPriorSetting - Class constructor method          

        end
        
        %% Set functions
        function obj = set.vprior(obj, value)
            if value < 1
                error([mfilename ':setvprior'],'The vprior property should define a percentage weight put on the prior. I.e., must be a number larger than 1')
            else
               obj.vprior = value; 
            end            
        end        
        
        function obj = set.abar1(obj, value)
           if value <= 0 
                error([mfilename ':setabar1'],'The abar1 property can not be smaller than or equal to 0')               
           else
               obj.abar1 = value;
           end
        end
        
        function obj = set.abar2(obj, value)
           if value <= 0 
                error([mfilename ':setabar2'],'The abar2 property can not be smaller than or equal to 0')               
           else
               obj.abar2 = value;
           end
        end        
        
        function obj = set.abar3(obj, value)
           if value <= 0 
                error([mfilename ':setabar3'],'The abar3 property can not be smaller than or equal to 0')               
           else
               obj.abar3 = value;
           end
        end                
                
        function obj = set.type(obj, value)
            obj.type = Batch.setCellObj(obj.type, value);
        end                           
        
    end
    
       
end

    