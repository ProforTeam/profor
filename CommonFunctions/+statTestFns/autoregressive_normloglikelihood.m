function loglik = autoregressive_normloglikelihood(y, mu, rho, sigma)
% autoregressive_normloglikelihood  Computes the log likelihood for a linear 
%                                   univariate AR(1) model with normal residuals
% Inputs:
% y      data vector  (Tx1)
% mu     constant mean
% rho    autoregressive coefficient
% sigma  constand st dev
% OUTPUT:
% loklik log likelihood
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

T       = size(y,1);
loglik  = -0.5*T*log(2*pi) - 0.5*log(sigma^2/(1 - rho^2)) - (y(1,1) - mu/(1 - rho^2))^2/(2*sigma^2/(1 - rho^2))-...
    ((T - 1)/2)*log(sigma^2) - sum(((y(2:end,1) - mu - rho*y(1:end - 1,1)).^2)/(2*sigma^2),1);

end
