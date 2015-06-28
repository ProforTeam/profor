classdef Priorsmixture 
    % Priorsmixture - A class to define individual prior settings for mixture
    % models. Used in PriorSetting and Batch classes 
    %
    % Assume: 
    %
    %   y = T*x + e 
    %
    % where y is (1 x 1), T is (1 * n), x is (n x 1), and 
    % e = e_{j} ( a_{j} + h_{j}^{0.5}eta_{j} ) for j = 1,...,m and m is the
    % number of distributions, eta ~ i.i.d.N(0,1). Accordingly, 
    % ( a_{j} + h_{j}^{-0.5}eta_{j} ) is Normal with mean a_{j}, and
    % precision h_{t}
    %
    % The priors asscoated with T and h are set using the Priors and tr
    % option. Here we set the priors for p and a, see Koop 2003.
    %
    % Priorsmixture Properties:
    %         p         - Scalar
    %         a         - Numeric
    %         V         - Numeric   
    %         tag       - CellObj
    %         draws     - Numeric
    %         aS        - Numeric
    %         pS        - Numeric
    %         state     - Logical
    %
    % Priorsmixture Methods:
    %         Priorsmixture    - Constructor             
    %
    % See also PRIORSETTING
    %
    % Note: These priors are used in a Gibbs sampling framework,  
    %
    % For usage, see <a href="matlab: opentoline(./help/helpFiles/htmlexamples/runArMixtureModelExample.m,1)">this example file</a>
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
        
        p % probability that errors are drawn form mth component. (m x 1) vector
        a % Mean of component m distribution. (m x 1) vector
        % Covariance of mean across components (m x m) matrix. We impose
        % the same restrictions as in Koop 2003, i.e., a is drawn from a
        % Normal with restrictions: 
        % p(a) == f_{N}(a|a_, V_)I(a_{1} < a_{2}... < a_{m})
        V         
        % tag - CellObj defining if the priors are used for the
        % observatoion equation of the state space system or the
        % observation equation of the state space system
        % Default = tr
        tag  = CellObj({'mix'}, 'type', 1, 'restrictions', {'mix'}); % string indicating for which part of state space this prior applies                        
        % draws - Numeric. Used to generate simulations from the prior
        % distribution, see properties Priors.TS and Priors.QS
        draws = 5000;                         
    end
    
    properties(Dependent = true)
        aS      % Simulated values (parameter matrix) from the prior. Dependent
        pS      % Simulated values (covariance of errors) from the prior. Dependent  
        % state - Logical. True if all Prior properties are set correctly
        % and consistently (in size and dimensions across properties)
        state    
    end    
    
    methods
        
        function obj = Priorsmixture( tag )        
            % Priorsmixture - Class constructor method          
            %
            % Input: 
            % 
            %   tag         [Cell]
            %
            % Output:
            % 
            %   obj         [Priors]
            %
            % Usage:
            %
            %   obj = Priorsmixture( tag )            
            %

            if nargin ~= 0            
                obj.tag = tag;                
            end                            
        end
        
        %% Set functions
        function obj = set.tag(obj, value)
            obj.tag  = Batch.setCellObj(obj.tag, value);            
        end                                 
        function obj = set.V(obj, value)
            if isnumeric(value)
                [r, c] = size(value);
                if r ~= c
                    error([mfilename ':setV'],'Number of rows and cols in V must be equal')
                else
                    obj.V = value;
                end
            else
                error([mfilename ':setV'],'V must be a numeric')
            end        
        end                

        function obj = set.p(obj, value)
            if isnumeric(value)                
                obj.p = value(:);
            else
                error([mfilename ':setp'],'p must be a numeric')
            end
        end                                  
        
        function obj = set.a(obj, value)
            if isnumeric(value)                
                obj.a = value(:);
            else
                error([mfilename ':seta'],'a must be a numeric')
            end
        end                          
        
        function obj = set.draws(obj, value)
            if isnumeric(value)                
                obj.draws = value;
            else
                error([mfilename ':setdraws'],'draws must be a numeric')
            end;                    
        end
        
        %% Get dependent properties        
%         function x = get.TS(obj)
%             
%             if obj.state
%                 [r, c] = size(obj.T);
% 
%                 x = zeros(r, c, obj.draws);
%                 switch (obj.type.x{:})
%                     case{'normal_gamma'}
%                         for d = 1:obj.draws
%                             t = tdis_rnd(r*c,obj.v);                                     
%                             x(:,:,d) = reshape(vec(obj.T) + chol(obj.Q*obj.V)'*t,[r c]);                        
%                         end                                                                   
%                     case{'normal_whishart'}                
%                         for d = 1:obj.draws
%                             x(:,:,d) = reshape(vec(obj.T) + chol(obj.V)'*randn(r*c,1),[r c]);
%                         end                                           
%                 end  
%             else
%                 x = [];
%             end
%         end 
%         
%         function x = get.QS(obj)
%             
%             if obj.state
%                 [r, c] = size(obj.Q);
% 
%                 x = zeros(r, c, obj.draws);
%                 switch (obj.type.x{:})
%                     case{'normal_gamma'}
%                         for d = 1:obj.draws                        
%                             x(:,:,d) = inv(gamm_rnd(r, c, .5*obj.v,.5*obj.v*obj.Q));
%                         end                                                                   
%                     case{'normal_whishart'}                
%                         for d = 1:obj.draws
%                             x(:,:,d) = inv(wish_rnd(inv(obj.v*obj.Q), obj.v));
%                         end                                           
%                 end
%             else
%                 x = [];                
%             end
%         end         
        
        function x = get.state(obj)            
            
            x = false;            
            if ~isempty(obj.p) && ~isempty(obj.a) && ~isempty(obj.V) 
                if size(obj.p, 1) ~= size(obj.a, 1)
                    warning([mfilename ':getstate'],'size of p and a are not consistent')
                    return
                end;
                if size(obj.V, 1) ~= size(obj.a, 1) 
                    warning([mfilename ':getstate'],'size of V and a are not consistent')
                    return
                end;
                
                x = true;
                
            end
        end        
        
    end
    
       
end

