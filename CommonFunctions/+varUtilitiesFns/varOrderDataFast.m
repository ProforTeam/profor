function [y, x] = varOrderDataFast(data, nvar, nlag, constant)
% PURPOSE: Get right hand side variables and lefthand side variables.
% removes any rows with nans and adjusts any dates acordingly. Faster 
% version of varOrderData, i.e. not with that many input options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%   data = matrix. (t x n), where t is the number of observations in the
%   sample, and n is the number of variables to be used in the VAR
%   estimation
%
%   nlag = number of lags in VAR 
%
%   nvar = number of variables in VAR
%
%   constant = logical. If true constant included
%   in regression. 
%
% Output:
%   y = matrix. (t x n), where t is the number of observations, and n is
%   the number of variables in the VAR
%
%   x = matrix. (t x m), where t is the number of observations, and m is
%   the number of variables*number of lags + 1 (constant). Note that the
%   ordering of the variables should be according to lags (and not
%   variables), eg y(t-1), y(t-2) etc. 
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

data(any(isnan(data),2),:) = [];    
% pull out different parts
y       = data;
const   = ones(size(data,1), 1);
% set up estimation eq
xmat    = latMlag(y, nlag, NaN);

if constant
    estData = [y const xmat];           
else    
    estData = [y xmat];
end;

% remove nans
estData(any(isnan(estData),2),:) = [];
% make rest of output
y = estData(:, 1:nvar);
x = estData(:, nvar+1:end);


