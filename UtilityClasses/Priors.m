classdef Priors 
    % Prior - A class to define individual prior settings. Used in
    % PriorSetting and Batch classes 
    %
    % Assume: 
    %
    %   y = T*x + e ~ N(0, Q)
    %
    % where y is (n x 1), T is (n * m), x is (m x 1) and Q is (n x n)
    %
    % Priors Properties:
    %         v         - Scalar
    %         Q         - Numeric
    %         T         - Numeric
    %         V         - Numeric   
    %         type      - CellObj
    %         tag       - CellObj
    %         draws     - Numeric
    %         TS        - Numeric
    %         QS        - Numeric
    %         state     - Logical
    %
    % Priorstvp Methods:
    %         Priors    - Constructor             
    %
    % See also PRIORSETTING
    %
    % Note: These Priors are used in a Gibbs sampling framework,
    % i.e., assumed non-conjugate. Depending on the context, multivariate
    % or univariate, the Priors can be either Independent Normal and inverse 
    % Whishart or Independent Normal and inverse Gamma.
    %
    % For some definition, see <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">this description</a>
    % For usage, see <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesExample.m,1)">this example file</a>
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
        v % Degress of freedom. Scalar
        Q % Mean covariance errors. (n x n) matrix 
        T % Mean (parameters). (n x m) matrix
        V % Covariance (parameters) (n*m x n*m) matrix       
        
        % type - CellObj defining the type, either normal_gamma (univariate
        % context) or normal_whishart (multivarite) context. 
        % Default = normal_whishart
        type = CellObj({'normal_whishart'}, 'type', 1, 'restrictions', {'normal_gamma', 'normal_whishart'});
        % tag - CellObj defining if the priors are used for the
        % observatoion equation of the state space system or the
        % observation equation of the state space system
        % Default = tr
        tag  = CellObj({'tr'}, 'type', 1, 'restrictions', {'tr','obs'}); % string indicating for which part of state space this prior applies                        
        % draws - Numeric. Used to generate simulations from the prior
        % distribution, see properties Priors.TS and Priors.QS
        draws = 5000;                         
    end
    
    properties(Dependent = true)
        TS      % Simulated values (parameter matrix) from the prior. Dependent
        QS      % Simulated values (covariance of errors) from the prior. Dependent  
        % state - Logical. True if all Prior properties are set correctly
        % and consistently (in size and dimensions across properties)
        state    
    end    
    
    methods
        
        function obj = Priors( tag )        
            % Priors - Class constructor method          
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
            %   obj = Priors( tag )            
            %

            if nargin ~= 0            
                obj.tag = tag;                
            end                            
        end
        
        %% Set functions
        function obj = set.type(obj, value)
            obj.type = Batch.setCellObj(obj.type, value);            
        end                         
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
                end;
            else
                error([mfilename ':setV'],'V must be a numeric')
            end;        
        end                
        function obj = set.Q(obj, value)
            if isnumeric(value)
                [r, c] = size(value);
                if r ~= c
                    error([mfilename ':setS'],'Number of rows and cols in Q must be equal')
                else
                    obj.Q = value;
                end;
            else
                error([mfilename ':setS'],'Q must be a numeric')
            end;        
        end                        
        function obj = set.v(obj, value)
            if ~isempty(value)
                if isscalar(value)
                    obj.v = value;
                else
                    error([mfilename ':setv'],'v must be a scalar')
                end;        
            end;
        end                        
        function obj = set.T(obj, value)
            if isnumeric(value)                
                obj.T = value;
            else
                error([mfilename ':seta'],'T must be a numeric')
            end;        
        end                          
        function obj = set.draws(obj, value)
            if isnumeric(value)                
                obj.draws = value;
            else
                error([mfilename ':setdraws'],'draws must be a numeric')
            end;                    
        end
        
        %% Get dependent properties        
        function x = get.TS(obj)
            
            if obj.state
                [r, c] = size(obj.T);

                x = zeros(r, c, obj.draws);
                switch (obj.type.x{:})
                    case{'normal_gamma'}
                        for d = 1:obj.draws
                            t = tdis_rnd(r*c,obj.v);                                     
                            x(:,:,d) = reshape(vec(obj.T) + chol(obj.Q*obj.V)'*t,[r c]);                        
                        end                                                                   
                    case{'normal_whishart'}                
                        for d = 1:obj.draws
                            x(:,:,d) = reshape(vec(obj.T) + chol(obj.V)'*randn(r*c,1),[r c]);
                        end                                           
                end  
            else
                x = [];
            end
        end 
        
        function x = get.QS(obj)
            
            if obj.state
                [r, c] = size(obj.Q);

                x = zeros(r, c, obj.draws);
                switch (obj.type.x{:})
                    case{'normal_gamma'}
                        for d = 1:obj.draws                        
                            x(:,:,d) = inv(gamm_rnd(r, c, .5*obj.v,.5*obj.v*obj.Q));
                        end                                                                   
                    case{'normal_whishart'}                
                        for d = 1:obj.draws
                            x(:,:,d) = inv(wish_rnd(inv(obj.v*obj.Q), obj.v));
                        end                                           
                end
            else
                x = [];                
            end
        end         
        
        function x = get.state(obj)            
            
            x = false;            
            if ~isempty(obj.v) && ~isempty(obj.Q) && ~isempty(obj.T) && ~isempty(obj.V)
                if numel(obj.T) ~= size(obj.V, 1)
                    warning([mfilename ':getstate'],'size of T and V are not consistent')
                    return
                end;
                if size(obj.Q, 1) ~= size(obj.T, 1)
                    warning([mfilename ':getstate'],'size of T and Q are not consistent')
                    return
                end;
                if strcmpi(obj.type.x{:}, 'normal_gamma')
                    if numel(obj.Q) > 1 || size(obj.T, 1) > 1
                        warning([mfilename ':getstate'],'Can not have T normal_gamma prior for multivariate priors')
                        return
                    end;
                end;
                
                x = true;
                
            end
        end        
        
    end
    
       
end

