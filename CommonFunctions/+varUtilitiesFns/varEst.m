function [alfa, beta, emat, Q] = varEst(estY, estX, constant)
% PURPOSE: Estimate simple VAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%   estY = matrix. (t x n), where t is the number of observations, and n is
%   the number of variables in the VAR
%
%   estX = matrix. (t x m), where t is the number of observations, and m is
%   the number of variables*number of lags + 1 (constant). Note that the
%   ordering of the variables should be according to lags (and not
%   variables), eg y(t-1), y(t-2) etc. 
%
%   constant = logical. If true constant included in estimation (in estX). 
%   Important: If true ones should be inthe estX matrix (first columnn)
%
% Output:
%   alfa = vector. (n x 1), where n is the number of variables. Constant
%   form regression
%
%   beta = matrix. (n x (m-1)), where n is the number of variables, and m-1
%   is the number of variables*number of lags. 
%
%   emat = residual matrix. (t x n). varargout{1}
%
%   Q = covariance matrix computed using residCovMat. varargout{2}
%
% Usage:
%
%   [alfa, beta, emat, Q] = varEst(estY, estX, constant)
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

coeff   = (estX\estY)';
yhat    = estX*coeff';

if constant
    alfa = coeff(:,1);
    beta = coeff(:,2:end);
else
    alfa = [];
    %beta=coeff(:,2:end);
    beta = coeff;
end;

emat    = estY - yhat;
[t,n]   = size(estX);
Q       = (emat'*emat)/(t - n);

