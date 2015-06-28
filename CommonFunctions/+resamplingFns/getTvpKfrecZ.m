function Z=getTvpKfrecZ(yhat)
% PURPOSE: Construct Z matrix for time-varying vector autoregression when
% the A matrix is lower triangular (only works for this case)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
% yhat = array (n x t) with estimated residuals from VAR regression. n is
% number of variables and t is number of observations
%
% Output:
%
% Z = array (n x (n(n-1))/2) with yhat ordering recursively, i.e. for n=3
% and t=1, Z is: 
%  [0           0           0;
%  -yhat(1,1)   0           0;
%  0            -yhat(1,1)  -yhat(2,1)]
%
% Usage:
%
% Z=getTvpKfrecZ(yhat)
%
% Notes: no error checking in code due to speed
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

[n,t]=size(yhat);
Z=zeros(n,(n*(n-1))/2,t);

cnt=1;
for i=1:n-1
    idxr=1+i;
    idxc=cnt:(cnt+numel(1:i)-1);
    Z(idxr,idxc,:)=-yhat(1:i,:);
    cnt=cnt+numel(idxc);
end;



%Z(1+i,i:(1+i))
%
%Z(:,:,i)=[zeros(1,3);
%        -myy(1,i) zeros(1,2);
%        0 -myy(1:2,i)'];        

