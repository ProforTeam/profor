function [T, Gdraw] = drawTTVP(y, x, Omega, Gdraw,...
                                    T0_mean, T0_cov, vprior, Gprior)
% PURPOSE: Draw time varying T matrix from state equation (VAR) in state
% space system, conditional on knowing varainces and covariances that 
% might be time varying. Note: No T restrictions allowed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input: 
%   y = (t x n) matrix of LHS observables.
%   x = (t x m) matrix of RHS variables.
%   Omega = (n x n x t) tvp covariance matrix of VAR
%   Gdraw = draw for covariance matrix for RW parameters
%   T0_mean = initial state vector for RW parameters (T)
%   T0_cov  = initial cov of state vector 
%   vprior  = scalar
%   Gprior  = prior (mean) of covaraince matrix for RW's (diagonal)
%
% Output: 
%   T = (n x m x t) matrix with tvp for VAR
%   Gdraw = new draw for covariance matrix for RW parameters
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

% Get some sizes
[Tt, n]     = size(y);
nn          = size(x, 2);

% Re-formaulate ordering of RHS matrix
z   = zeros(n,nn*n,Tt);      
cnt = 1;
for i = 1:n
    z(i, cnt:cnt+nn-1, :) = x';                      
    cnt = cnt + nn;
end;     

% Set up KF matrices. Note: This is a VAR put into state space form, but here
% the parameters follow independent RW's, and the VAR part is the observation 
% equation, and the time varying parameters are the state equation
%
% y(t) = T(t)x  + e     ~ N(0,h(t))
% T(t) = T(t-1) + u(t)  ~ N(0,Q)
%

d   = zeros(n,1,Tt);
h   = Omega;  
t   = repmat(eye(nn*n),[1 1 Tt]);
c   = zeros(nn*n,1,Tt);
r   = repmat(eye(nn*n),[1 1 Tt]);     
q   = repmat(Gdraw,[1 1 Tt]);  

% Prior for initial state
a0  = T0_mean;
p0  = T0_cov;

% Do KF filter
[state, varCov] = kalmanFilterFns.KalmanFilterOrigFastNoNanTVP(y', z, d, h, t, c,...
                                                              r, q, a0, p0);                                                

% Do backwards recursion to generate state                 
J       = (1:nn*n);
obsIdx  = false(nn*n,1);
state   = kalmanFilterFns.kalmanFilterBackwardStateRecursion(state,varCov,J,...
                                                      t(:,:,1),q(:,:,1),obsIdx);                               

% Transform state to T format
T   = nan(n, nn, Tt);
cnt = 0;
for i = 1:n
    T(i,:,:) = permute(state(:, 1+cnt:nn+cnt), [2 1]);
    cnt = cnt + nn;
end;

% Draw Q, the covariance of T (from iWishart)
emat    = state(2:end,:) - state(1:end-1,:);
v       = Tt + vprior;
H       = inv(vprior*Gprior + emat'*emat);        
Gdraw   = inv(wish_rnd(H, v));                   





