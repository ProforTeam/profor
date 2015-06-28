function [betab,yb,sigmab]=olsSimulation(emat,x,beta,draws,varargin)
% PURPOSE: Do bootstrap of ols estimation by drawing from residuals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
%   emat = residual matrix. (t x neq), where t is the number of obserations.
%   Note neq can be > 1. I.e. can do more than one OLS equation in same run
%   of program (to save time). However, all equations need to have the same
%   regressors, i.e. RHS variables x. 
%   
%   x = matrix. (t x n), where t is as above and n is number of variables
%   in right hand side of regression
%
%   beta = vector. (neq x n) with initial regression coefficients. n and 
%   neq is defined as above
%
%   draws = integer. Numebr of simulations to be done
%
% Output:
%
%   betab = matrix. (neq x n x d) with simulated coeffs. d is number of draws
%   and n and neq is as above
%
%   yb = matrix. (t x neq x d) with simulated left hand side variables, i.e.
%   dependent variables. t, neq and d as above. Note: This is NOT yhat
%
%   sigmab = matrix. (neq x d) with variance of each simulated regressions,
%   i.e. (y-yhat)'*(y-yhat)/T-nvar
%
% Usage:
%
%   [betab,yb,sigmab]=olsSimulation(emat,x,beta,draws)
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
    
import resamplingFns.*

defaults={'bootStrapMethod','br',@(x)any(strcmpi(x,{'br','bmb','norm'}))};
options=validateInput(defaults,varargin(1:nargin-4));

[T,nvar]=size(x);
[Te,neq]=size(emat);
[neqb,nvarb]=size(beta);
if T~=Te || neq~=neqb || nvar~=nvarb
    error('olsSimulation:input','The sizes of the input matrixes x,emat and beta do not match')
end;

betab=nan(neq,nvar,draws);
yb=nan(T,neq,draws);
sigmab=nan(neq,draws);

tic
if draws>1
    parfor_progress(draws);
end;

parfor d=1:draws
        
    [randResid,drawsIdx]=getRandomShocks(emat,T,options.bootStrapMethod);
        
    yy=x*beta'+randResid; % (T x n)*(n x neq) + (T x neq) = (T x neq)
    betab(:,:,d)=(x\yy)'; % (neq x n) 
    residb=yy-x*betab(:,:,d)'; % (T x neq) - (T x n)*(n x neq)= (T x neq)   

    yb(:,:,d)=yy; % (T x neq)
    sigmab(:,d)=diag((residb'*residb)./(T-nvar)); %diag((neq x T)*(T x neq))=neq
    
    if draws>1
        parfor_progress;
    end;
end;

if draws>1
    parfor_progress(0);
end;


