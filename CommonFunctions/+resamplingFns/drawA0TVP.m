function [a0draw, sdrawNew, yhat] = drawA0TVP(y, x, T, Sigma2, sdraw,...
                                                a0_mean, a0_cov, vprior, Sprior)
% PURPOSE: Draw stochastic covariance states and the variance of the
% covarainces. See Primiceri 2005 for details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Model and assumptions:
%
% y(t)=X(t)T(t)+A0(t)^(-1)Sigma(t) e(t) 
% 
% when Sigma(t) and T(t) are known, we can write:
%
% A0(t)(y(t)-X(t)T(t))=Sigma(t) e(t) 
%
% where Sigma=diag[sigma(t)_1,sigma(t)_2,...,sigma(t)_n] and e(t)~i.i.d.N(0,1)
% A0(t)=A0(t-1) + c(t) ~ i.i.d.N(0,S) and 
% A0(t)^(-1) Sigma*Sigma' A0(t)^(-1)' = Omega, where Omega is the tvp
% covaraince matrix of the VAR
%
% Goal: To draw A0(t) and the covarainces of their inovations S. 
%
% Input: 
%
% y = (t x n) matrix of observables
%
% x = (t x m) matrix is explanatory variables
%
% T = (n x m x t) matrix of time varying coefficients 
%
% Sigma2 = (n x n x t) matrix with variances. I.e.:
% Sigma(t)=diag[sigma(t)_1,sigma(t)_2,...,sigma(t)_n] for t=1,2,...T
% and Sigma2 is the Sigma^2
%
% sdraw = (n(n-1)/2) x (n(n-1)/2))  block diagonal matrix with the
% covarainces of the disturbances to the covariances.
%
% a0_mean = (n(n-1)/2) matrix with a0 values. Should be ordered as: 
% [a_21 a_31 a_32 ... a_nn]' 
%
% a0_cov = (n(n-1)/2) x (n(n-1)/2) matrix. Block diagonal with
% covaraince of a0's. p0 to Kalman Filter. 
%
% vprior = scalar. Degrees of freedom parameter. Used for Wishart
% distribution. Must exceed the dimension of the S_(n) to make the prior
% proper, where S_(n) is the size of the nth bock of sdraw.  
%
% Sprior = (n(n-1)/2) x (n(n-1)/2) matrix with priors. Block diagonal
% matrix with the covarainces of the distrubances to the covariances.
%
% Output: 
%
% a0draw = (n x n x t) matrix with draws state variables, i.e., the time
% varying covariances. Note that ones are automatically put into the
% diagonal.
%
% sdrawnew = new draw of sdraw, see above.
%
% yhat = (n x t) matrix with y(t)-X(t)T(t). 
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

% Some sizes etc. 
[Tt, n] = size(y);
numres = (n*(n-1))/2;

% 1) Generate yhat: Conditional on b, we know this as:
yhat = nan(n, Tt);
for i = 1:Tt
    yhat(:,i) = y(i,:)' - T(:,:,i)*x(i,:)';
end;

if n == 1
    a0draw      = ones(1,1,Tt);
    sdrawNew    = zeros(1,1);
else
    
    if numel(Sprior) ~= numres^2 || numel(a0_cov) ~= numres^2 || numel(sdraw) ~= numres^2
        error([mfilename ':input'],'Wrong size on Sprior and or a0_cov and or sdraw')
    end;

    % 2) We are now left with A(t)yhat=Simga(t)e(t)
    % Under the assumption that Sigma=diag[sigma(t)_1,sigma(t)_2,...,sigma(t)_n] 
    % e(t)~i.i.d.N(0,1) and A(t)=a lower triangular matrix with ones on the
    % diagonal we can get the a's (covariances) by recursively employing the KF
    % procedures I.e., we write the modelas yhat=Z(t)a(t) + Sigma(t)e(t), where:
    % Z(t) is defined in Primiceri p.845 and a(t) is assumed to follow a RW:
    % a(t)=a(t-1)+cc(t) where cc is independent across equations (n)

    % Construct Z, a (n x n(n-1)/2 x t) matrix
    Z = resamplingFns.getTvpKfrecZ(yhat);

    % 3) Do KF iterations and Carter Kohn draws. We can skip the first
    % equation, since here Z=0 for all columns
    a0draw      = repmat(eye(n), [1 1 Tt]);
    sdrawNew    = zeros( size(sdraw) );
    counterMat  = [];
    for i = 1:n-1
        counterMat = blkdiag( counterMat, ones(i).*(i + 1) );    
    end;

    for i = 2:n

        [~,col]     = find( counterMat==i );
        colCounter  = unique(col);            

        state               = kalmanFilterStep(i, Tt, colCounter, Z, Sigma2,...
                                                    sdraw, a0_mean, a0_cov, yhat);                               
        a0draw(i, 1:i-1, :) = permute(state, [3 2 1]);

        %Draw S, the covariance of A(t) (from iWishart)
        emat    = state(2:end,:) - state(1:end-1,:);
        v       = Tt + vprior;
        H       = inv( vprior*Sprior(colCounter, colCounter) + emat'*emat );                
        sdrawNew(colCounter, colCounter) = inv(wish_rnd(H, v));                  

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function state = kalmanFilterStep(i, Tt, colCounter, Z, Sigma2, Sdraw,...
                                                       a0_mean, a0_cov, yhat)

% Do KF and state draws
z = Z(i, colCounter, :);
d = zeros(1, 1, Tt);
h = Sigma2(i, i, :);  % vart
t = repmat(eye(i-1), [1 1 Tt]);
c = zeros(i-1, 1, Tt);
r = repmat( eye(i-1), [1 1 Tt]);     
q = repmat(Sdraw(colCounter,colCounter),[1 1 Tt]);  % cdraw

%a0  = a0_mean(i, 1:i-1)';
a0  = a0_mean(colCounter,1);
p0  = a0_cov(colCounter, colCounter);

% Do KF filter
[state, varCov] = kalmanFilterFns.KalmanFilterOrigFastNoNanTVP(yhat(i,:), z, d, h,...
                                                            t, c, r, q, a0, p0);                                                

% Do backwards recursion to generate state                 
J       = (1:i-1);
obsIdx  = false(i-1, 1);
state   = kalmanFilterFns.kalmanFilterBackwardStateRecursion(state, varCov,...
                                                J, t(:,:,1), q(:,:,1), obsIdx);                               



