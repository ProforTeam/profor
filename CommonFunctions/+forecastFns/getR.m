function R=getR(nfor,nvar,ia,ib,methodSum)
% PURPOSE: Construct a R selection matrix which can be used to select from
% the mvnpdf when constructing density evaluation. Assumed to be used in
% conjunction with mvnpdf and the funtion getMse. 
%
% Input: 
%
% nfor = integer. Number of forecasts
%
% nvar = integer. Number of variables
%
% ia = vector (1 x n), where n is the number of forecasts to be evaluated.
% n<=nfor. I.e. if nfor=5, ia can equal e.g. [1 2 3 4 5] or [3 4] etc. 
%
% ib = vector (1 x m), where m is the number of variables to be evaluated.
% m<=nvar. I.e. if nvar=2, ib can equal e.g. [1 2] or [1] etc. 
%
% methodSum = optional extra input. If something is supplied, the program
% will collaps R (see below) to become a (1 x nfor*nlag) vector. Used in
% conjuction with the mvnpdf function this will evaluate the sum of the
% forecasts. Note: It is not possible to evaluate the sum of two variables
% independently (this must be done in two different calls to the function).
%
% Output:
%
% R = matrix/vector, depending on input. Will always have size (? x
% nfor*nvar), where ? differs depending on input. 
%
% Usage: 
%
% R=getR(nfor,nvar,ia,ib)
%
% Note: 
% This function is ment to be used in conjunction with mvnpdf and the mse
% output from the getMse function. I.e. if nvar=2, nfor=2,
% mse=varUtilities.getMse(...) will be of size (N x N), where 
% N=(nfor x nvar). Use R=getR(nfor,nvar,ia,ib), for some ia and ib with 
% p=mvnpdf(R*actual,R*mu,R*mseR') to get the predictive likelihood. 
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

% First make R such that it takes into account whether R should be single
% or multi and which horizon that should be evaluated
R=zeros(nfor,nvar);
R(ia,ib)=1;
R=R';
R=diag(R(:));
% Remove rows with all zeros. Number of columns must equal nfor*nvar
R(all(R==0,2),:)=[];

if nargin==5
    % Adjust for possible sum method
    R=any(R==1).*1;        
end;

% switch lower(method)                                    
%     case{'sum'}
%         % make double by multiplying by 1
%         
%     otherwise % 'single'    
%         % R is R
%         R=R;                
% end;

