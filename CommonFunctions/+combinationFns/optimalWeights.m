function result = optimalWeights(scores,varargin)
% optimalWeights - 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


optimStart = tic;

defaults={...
    'TolX',         1e-10,              @isnumeric,...
    'TolFun',       1e-10,              @isnumeric,...
    'Maxiter',      25000,              @isnumeric,...
    'Display',      'notify',           @ischar,...
    'MaxFunEvals',  25000,              @isnumeric,...
    'Algorithm',    'interior-point',   @ischar...
    };

options = validateInput(defaults,varargin(1:nargin-1));            

[~, m, d] = size(scores);                        
if d ~= 1 
    error([mfilename ':input'],'The input scores to optimalWeights has wrong size')
end;

% empty output
fval        = [];
exitflag    = 2;
optOutput   = [];
lambda      = [];
grad        = [];
hessian     = [];            

if any(any(isnan(scores)))
    x1 = nan(m, 1);
else            
    % Make function to be maximized. Remember to transpose and
    % remove log from scores
    fun = @(x)func2max(x,exp(scores)');      

    x0  = repmat(1/m,[m 1]);
    % linear inequality restrictions: A*x<=b
    b   = zeros(m,1);
    A   = eye(m).*-1;
    % linear restrictions: Aeq*x = beq 
    Aeg = ones(1,m);
    beg = 1;

    optOptions = optimset('Algorithm',options.Algorithm,...
        'TolX',options.TolX,...
        'TolFun',options.TolFun,...
        'Maxiter',options.Maxiter,...
        'Display',options.Display,...
        'MaxFunEvals',options.MaxFunEvals);    
    
    [x1, fval, exitflag, optOutput, lambda, grad, hessian]...
        = fmincon(fun, x0, A, b, Aeg, beg, [], [], [], optOptions);    

end

% Final output
result.x1           = x1;
result.fval         = -fval; 
result.exitflag     = exitflag;
result.optOutput    = optOutput;
result.lambda       = lambda;
result.grad         = grad;
result.hessian      = hessian;
result.tElapsed     = toc(optimStart);

end                 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
function value = func2max(W, scores)

% W = weights (to be optimized) (m x 1)
% scores (m x t)
% W x scores = (1 x t)
value = -sum(log(W'*scores), 2);

end