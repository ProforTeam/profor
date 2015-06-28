function [state,varCov]=KalmanFilterOrigFastNoNanTVP(y,Z,d,H,T,c,R,Q,a0,P0)
% PURPOSE:	Apply the Kalman Filter to a time-varying state space
% formulation, specified as in Harvey (1989). Faster version of 
% KalmanFilterOrig, i.e no error checking, and
% no analytic derivation option for derivatives. See KalmanFilterOrig for 
% input desc. See especially last Note. 
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

% 1. Initialisation
%[num_observables,num_observations]=size(y);
num_observations    = size(y,2);
num_states          = size(a0,1);
% Pre-allocate space for state and covariance of state
a                   = NaN(num_states,1,num_observations);
P                   = NaN(num_states,num_states,num_observations);

% 2. The first observation    
apt = T(:,:,1)*a0 + c(:,:,1);
Ppt = T(:,:,1)*P0*T(:,:,1)' + R(:,:,1)*Q(:,:,1)*R(:,:,1)';
    
Ft          = Z(:,:,1)*Ppt*Z(:,:,1)' + H(:,:,1);
Ft_inverse  = inv(Ft);
vt          = y(:,1) - Z(:,:,1)*apt - d(:,:,1);
    
a(:,1,1) = apt + Ppt*Z(:,:,1)'*Ft_inverse*vt;
P(:,:,1) = Ppt - Ppt*Z(:,:,1)'*Ft_inverse*Z(:,:,1)*Ppt;
                         
% 3. Subsequent observations
for t=2:1:num_observations;
    
    Tt = T(:,:,t);
    ct = c(:,:,t);
    Rt = R(:,:,t);
    Qt = Q(:,:,t);
    Zt = Z(:,:,t);
    dt = d(:,:,t);
    Ht = H(:,:,t);
    
    apt         = Tt*a(:,1,t-1) + ct;
    Ppt         = Tt*P(:,:,t-1)*Tt' + Rt*Qt*Rt';         
    
    Ft          = Zt * Ppt * Zt' + Ht;   

    Ft_inverse  = inv(Ft);
    vt          = y(:,t) - Zt * apt - dt;

    a(:,1,t)    = apt + Ppt*Zt'*Ft_inverse*vt;               
    P(:,:,t)    = Ppt - Ppt*Zt'*Ft_inverse*Zt*Ppt;          

end;
% Final output   
state   = a;
varCov  = P;



