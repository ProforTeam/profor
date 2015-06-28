function sigma=drawSigma(Sprior,varCov,vpost)
% PURPOSE: Draw covariance matrix based on independent-Wishart distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
% Sprior = matrix (n x n), where n is the number of variables. Should be a
% popsitive definite covariance prior. 
%
% varCov = matrix (n x n), where n is as above. Estimated (ols) covariance
% matrix of residuals.
%
% vpost = scalar. Scaling parameter
%
% Output:
%
% sigma = matrix (n x n), where n is as above. Draw of covariance from
% independent-wishart distribution
%
% Usage:
%
% sigma=drawSigma(Sprior,varCov,vpost)
%
% Note: No error checking due to speed
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

Spost=Sprior+varCov; 
Rd=chi2rnd(vpost);
sigma=Spost./Rd;    