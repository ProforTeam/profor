function varForc = varForecast(estY, alfaC, betaC, nlag, nfor, varargin)
% varForecast   Forecast a VAR 
%
% Output:
%
%   varForc = (nvar x nfor) matrix with forecasts   
%
% Usage: 
%
%   varForc = varForecast(estY,alfaC,betaC,nlag,nfor)
%   varForc = varForecast(estY,alfaC,betaC,nlag,nfor,'randomErrors',<>)
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



nvar = size(estY,2);

defaults    = {'randomErrors', zeros(nfor, nvar), @isnumeric};
options     = validateInput(defaults, varargin(1:nargin - 5));

varForc     = [];
% get vector of y1(t),y2(t),y1(t-1),y2(t-1), etc. from the
% original estY matrix! 
tmp = (estY(end : - 1 : end - nlag + 1, :)');            
yy  = tmp(:);
for h = 1:nfor
    yy      = alfaC + betaC*yy(:, 1) + [options.randomErrors(h,:)';zeros(nlag*nvar - nvar, 1)];
    varForc = cat(2, varForc, yy(1:nvar, 1));                                
end;