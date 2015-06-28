function [y, x] = var2SUR(estY, estX, varargin)
% Function: Transforms output from varOrderData into input that can be used
% by Lesage's SUR program. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
%   estY = matrix. (t x n), where t is the number of observations, and n is
%   the number of variables in the VAR
%
%   estX = matrix. (t x m), where t is the number of observations, and m is
%   the number of variables*number of lags + 1 (constant). Note that the
%   ordering of the variables should be according to lags (and not
%   variables), eg y(t-1), y(t-2) etc. 
%   nlag = number of lags in VAR 
%
%   varargin = optional input argument. String followed by argument.
%
%       restrictions = matrix. Logical, with ones indications that a variable
%       should be included, and zero that it should not be included. (n x m),
%       where n and m are defined as above. 
%
% Output:
%
%   y = structure. For each n there will be a structure containing the 
%   dependant variable in the specific equation. Eg. y(n).eq=y1. See also
%   Lesage and the sur fucntion. 
%
%   x = structure. For each n there will be a structure containing the
%   explanatory variables in the specific equation. Eg. x(n).eg=[1 x1 x3].
%   See also Lesage and the sur fucntion. 
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

neqs = size(estY, 2);
nvar = size(estX, 2);                

% Defaults
defaults = {'restrictions', ones(neqs, nvar), @isnumeric};
options  = validateInput(defaults, varargin);

if nvar ~= size(options.restrictions, 2)
    error('var2SUR:err','The number of restrictions do not match the number of variables')
end;

for i = 1:neqs
    y(i).eq = estY(:, i);
    x(i).eq = [];
    for ii = 1:nvar
        if options.restrictions(i,ii) == 1
            x(i).eq = cat(2, x(i).eq, estX(:, ii));                                
        end;                    
    end;    
end;


