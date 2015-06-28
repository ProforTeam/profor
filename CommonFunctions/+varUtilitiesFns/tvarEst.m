function [Qc, result] = tvarEst(yy, xx, orderS, orderSindx, c)
% tvarEst - 
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

% Order the variables according to orderSindx
yy = yy(orderSindx,:);
xx = xx(orderSindx,:);

orderSLessThanC = orderS <= c;

%% Regime 1
% Get the observations associated with the threshold value
yy1 = yy(orderSLessThanC,:);
xx1 = xx(orderSLessThanC,:);
% and estimate the one regime model
[r1_alfa,r1_beta,r1_emat,r1_Q] = varUtilitiesFns.varEst(yy1, xx1, true);

%% Regime 2
% Get the observations associated with the threshold value
yy2 = yy(orderSLessThanC == 0,:);
xx2 = xx(orderSLessThanC == 0,:);
% and estimate the one regime model
[r2_alfa,r2_beta,r2_emat,r2_Q] = varUtilitiesFns.varEst(yy2, xx2, true);

%% Comput the sum of squared residuals
ssr1    = trace(r1_emat'*r1_emat);
ssr2    = trace(r2_emat'*r2_emat);
Qc      = ssr1 + ssr2;

if nargout > 1
    result(1).alfa  = r1_alfa;
    result(1).beta  = r1_beta;
    result(1).emat  = r1_emat;
    result(1).Q     = r1_Q;
    result(1).t     = size(r1_emat);
    result(1).yhat  = yy1 - r1_emat;
    
    result(2).alfa  = r2_alfa;
    result(2).beta  = r2_beta;
    result(2).emat  = r2_emat;
    result(2).Q     = r2_Q;
    result(2).t     = size(r2_emat);           
    result(2).yhat  = yy2 - r2_emat;
    
end



