function p = multivariateNormalPredLikelihood(realizations, mu, mse)
% PURPOSE: Estimate the multivarate predicitve likelihood based on the
% multivariate normal distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
% realizations = vector (t x n), where t is the number of periods and n is 
% the number of variables, on which the predicitve density should be 
% evaluated
%
% mu = vector (t x n), with mean (point forecast) for each of the n
% variables over periods t
%
% mse = matrix, (n x n x t) with the covariance/mse of the forecasts
% (depending on the forecast horizon)
%
% Output:
%
% p = vector (t x 1) with predictive likelihoods under the assumption of
% multivariate normality. I.e. p(i) is the mvnpdf of X(i,:) and mse(:,:,i)
%
% Usage:
%
% p=multivariateNormalPredLikelihood(realization,mu,mse)
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

[t, n]              = size(realizations);
[tmu, nmu]          = size(mu);
[nmse, nnmse, tmse] = size(mse);
% error check
if t ~= tmu || t ~= tmse
    error([mfilename ':input'],'The number of time periods do not match between the different inputs')
end
if n ~= nmu || n ~= nmse || nmse ~= nnmse
    error([mfilename ':input'],'The number of variables do not match between the different inputs, or mse is not symmetric')
end;
% compute output
p = mvnpdf(realizations, mu, mse);