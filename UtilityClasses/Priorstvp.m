classdef Priorstvp 
    % Priorstvp - A class to define individual prior settings for time varying
    % parameter models. Used in PriorSetting and Batch classes 
    %
    % Assume: 
    %
    %   a(t) = Ta(t-1) + s ~ N(0, S)
    %
    % where a is (n x 1), T is (n * n) and an identity matrix, and S is (n x n)
    %
    % Priorstvp Properties:
    %         v         - Numeric
    %         S         - Numeric
    %         a0        - Numeric
    %         p0        - Numeric   
    %         type      - CellObj
    %         tag       - CellObj
    %         draws     - Numeric
    %         SS        - Numeric    
    %         state     - Logical
    %
    % Priorstvp Methods:
    %         Priorstvp - Constructor     
    %
    % See also PRIORSETTING, PRIORS
    %
    % Note: These Priorstvp are used in a Gibbs sampling framework.
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
        v  % Degress of freedom. Scalar
        S  % Mean covariance errors. (n x n) matrix 
        a0 % Initial state (parameters) (n x 1) vector
        p0 % Initial covariance (parameters) (n x n) matrix       
        % type - CellObj defining the type. Default = normal_whishart
        type = CellObj({'normal_whishart'}, 'type', 1, 'restrictions', {'normal_whishart'});
        % tag - CellObj defining for which part of the time varying model
        % the priors are to be used. Default = tg
        %
        % See also <a href="./help/helpFiles/htmlexamples/html/estimationNamingConventionsExample.HTML">this description</a>
        tag  = CellObj({'tg'}, 'type', 1, 'restrictions', {'zw','etav','tg','a0s','sigmab'}); % string indicating for which part of state space this prior applies                        
        % draws - Numeric. Used to generate simulations from the prior
        % distribution, see properties Priorstvp.SS
        draws = 5000;                         
    end
    
    properties(Dependent = true)
        SS % Simulated values (covariance of errors matrix) from the prior. Dependent
        % state - Logical. True if all Prior properties are set correctly
        % and consistently (in size and dimensions across properties)        
        state 
    end        
    
    methods
        
        function obj = Priorstvp( tag )                        
            % Priorstvp - Class constructor method          
            %
            % Input: 
            % 
            %   tag         [Cell]
            %
            % Output:
            % 
            %   obj         [Priorstvp]
            %
            % Usage:
            %
            %   obj = Priorstvp( tag )            
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
        function obj = set.p0(obj, value)
            if isnumeric(value)
                [r, c] = size(value);
                if r ~= c
                    error([mfilename ':setp0'],'Number of rows and cols in p0 must be equal')
                else
                    obj.p0 = value;
                end;
            else
                error([mfilename ':setp0'],'p0 must be a numeric')
            end;        
        end                
        function obj = set.S(obj, value)
            if isnumeric(value)
                [r, c] = size(value);
                if r ~= c
                    error([mfilename ':setS'],'Number of rows and cols in S must be equal')
                else
                    obj.S = value;
                end;
            else
                error([mfilename ':setS'],'S must be a numeric')
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
        function obj = set.a0(obj, value)
            if isnumeric(value)                
                if size(value,2)>1
                    error([mfilename ':seta0'],'a0 must be a (n x 1) vector')
                else
                    obj.a0 = value;
                end;
            else
                error([mfilename ':seta0'],'a0 must be a numeric')
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
        function x = get.SS(obj)
            
            if obj.state
                [r, c] = size(obj.S);

                x = zeros(r, c, obj.draws);
                switch (obj.type.x{:})
                    case{'normal_gamma'}
                        for d = 1:obj.draws                        
                            %v1=vpriorn+nobsn;    
                            %v0s02=vpriorn*Spriorn;                                                
                            %s12=((yn-xn*bdraw)'*(yn-xn*bdraw)+v0s02)/v1;
                            %hdraw=gamm_rnd(1,1,.5*v1,.5*v1*s12);    
                            %sigmann=1/hdraw;                                                                                           
                            x(:,:,d) = inv(gamm_rnd(r, c, .5*obj.v,.5*obj.v*obj.S));
                        end                                                                   
                    case{'normal_whishart'}                
                        for d = 1:obj.draws
                            % v           = nobs + vprior;
                            % u           = reshape(ys - zs*beta,[nobs nvary]);            
                            % H           = inv(vprior*Sprior + u'*u);    
                            % Q           = inv(wish_rnd(H, v));                                                        
                            x(:,:,d) = inv(wish_rnd(inv(obj.v*obj.S), obj.v));
                        end                                           
                end
            else
                x = [];                
            end
        end                 
        

        function x = get.state(obj)            
            
            x = false;            
            if ~isempty(obj.v) && ~isempty(obj.S) && ~isempty(obj.a0) && ~isempty(obj.p0)
                if numel(obj.a0) ~= size(obj.p0, 1)
                    warning([mfilename ':getstate'],'size of a0 and p0 are not consistent')
                    return
                end;
                if size(obj.S, 1) ~= size(obj.a0, 1) 
                    warning([mfilename ':getstate'],'size of S and a0 are not consistent')
                    return
                end;
                
                idx     = eye(size(obj.S));
                zeroel  = obj.S(idx == 0);                
                switch lower(obj.tag.x{:})
                    case{'zw','etav','sigmab','tg','a0s'}
                        if any(zeroel)
                            warning([mfilename ':getstate'],'The off-diagonal elements of S contains non-zero elements. Not allowed for tag: %s',obj.tag.x{:})
                            return
                        end;                        
                end                
                x = true;
            elseif strcmpi(obj.tag.x{:},'a0s')
                if isnan(obj.v) && isnan(obj.S) && isnan(obj.a0) && isnan(obj.p0)  
                    % we do not need the a0s prior (AR model)
                    x = true;
                end
            end
        end        
        
    end
           
end

