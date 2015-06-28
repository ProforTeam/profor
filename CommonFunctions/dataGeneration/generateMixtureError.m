function y = generateMixtureError(alfa, h, prob_error, n_simulations, draw_type)
% generateMixtureError Returns arbitrary error terms for a mixture of normals.
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
% Inputs:
%   alfa            [double]    - constant of the normal comoponent (a_{j})
%   h               [double]    - precision of the normal component (h_{j})
%   prob_error      [double]    - Switching probabilities between components.
%   n_simulations   [double]    - Number of simulations returned.
%   draw_type       [str]       - {'uniform', 'multinomal'}
% 
% Outputs:
%   y
% 
% References:
%   Koop 2003, Bayesian Econometrics.

%% Validation
errType = ['data:', mfilename];

% Check that constant and precision have same dimensions.
assert(all(size(alfa) == size(h)), errType, ...
    'The constant and Precision must have equal dimensions')

%% Initiliase outputs
y                       = zeros(n_simulations, 1);
draw_randn              = randn(n_simulations, 1);
n_mixture_components    = size(alfa, 1);

%% Generate data 

switch lower(draw_type)
    case 'uniform'
        % Generate data according to code in Koop (2003) online examples
        for ii = 1 : n_simulations

            % Select the component of the mixture to draw from 
            idx = sum(rand >= cumsum([0; prob_error]));

            % Generate the data from the appropriate part of mixture of normals.
            y(ii, 1) = alfa(idx, 1) + prob_error(idx, 1) * draw_randn(ii, 1);
        end
        
    case 'multinomal'
        % Generate data with multinomal sampling for selection of error component

        % Draw from a multinomial distribution according to prob_error.
        idx = mnrnd(1, prob_error, n_simulations)';

        % Convert draws from multinomial distribution into a logical index to select
        % parts of component normal.
        idx = logical(idx);

        for ii = 1 : n_simulations        
            % Generate the data from the appropriate part of mixture of normals.
            y(ii, 1) = alfa(idx(:, ii), 1) + prob_error(idx(:, ii), 1)*draw_randn(ii, 1);
        end
        
    otherwise
        error(errType, '"%s" draw type not supported', draw_type)
end

end
