classdef MixedNormal < handle
    % MixedNormal - Reads in mixed-normal specifications and provides
    %               methods for random number generation.
    %
    % Data generated from a mixture of normals according to:
    %
    %   y = e
    %
    % where y is (1 x 1) and e = e_{j} ( a_{j} + h_{j}^{0.5} eta_{j} ) for j = 1,
    % ...,m and m is the number of distributions, eta ~ i.i.d.N(0,1).
    % Accordingly, ( a_{j} + h_{j}^{-0.5}eta_{j} ) is Normal with mean a_{j}, and
    % precision h_{t}.
    %
    % References:
    %   Koop. (2003), 'Bayesian Ecnometrics'
    %
    % MixedNormal Properties:
    %
    %   alfa                    - Numeric
    %   h                       - Numeric
    %   prob_error              - Numeric
    %   h                       - Numeric    
    %   n_mixture_components    - Numeric
    %
    % Tsdata Methods:
    %
    % Usage:
    %   obj = MixedNormal( muMode, sigma1Sq, sigma2Sq)
    
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
        alfa                    % constant of the normal comoponent (a_{j})
        h                       % precision of the normal component (h_{j})
        prob_error              % Switching probabilities between components.
        n_mixture_components    % Number of mixture components
    end
    
    
    
    methods
        function obj = MixedNormal( alfa, h, prob_error )
            % MixedNormal
            %
            % Inputs:
            %   alfa            [double]    - constant of the normal comoponent (a_{j})
            %   h               [double]    - precision of the normal component (h_{j})
            %   prob_error      [double]    - Switching probabilities between components.
            %
            % References:
            %   Koop 2003, Bayesian Econometrics.
                        
            errType     = [mfilename, ':'];
            
            % Check that constant and precision have same dimensions.
            assert(all(size(alfa) == size(h)), errType, ...
                'The constant and Precision must have equal dimensions')

            % Set the paramaters 
            obj.alfa        = alfa;
            obj.h           = h;
            obj.prob_error  = prob_error;

            % Infer tthe number of mixture components.
            obj.n_mixture_components = size(alfa, 1);
            
            
        end
        
        %% Get / Set Methods
        function set.alfa(obj, value)
            if ~isnumeric(value)
                error([mfilename ':set-alfa'],'Alfa must be numeric')
            end
            obj.alfa = value;                        
        end
        
        function set.h(obj, value)
            if ~isnumeric(value)
                error([mfilename ':set-h'],'Precision (h) must be numeric')
            end
            obj.h = value;
        end
        
        function set.prob_error(obj, value)
            if ~isnumeric(value)
                error([mfilename ':set-prob_error'],'Probabilities must be numeric')
            end
            obj.prob_error = value;
        end

        %% General Mehods
        R   = randMixedNormal(obj, outDim, draw_type)
        
    end
    
end

