function [alfa,beta,emat]=sur2VAR(result,restrictions,varargin)
% Function: Transforms output from Lesage's sur function into format that
% can be used by Lat var utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
%   result = result structure from Lesage's sur function. See this for
%   details.
%
%   restrictions = matrix. Logical, with ones indications that a variable
%   should be included, and zero that it should not be included. (n x m),
%   where n is the number of variables in the VAR, and m is
%   the number of variables*number of lags + 1 (constant)
%
% Output:
%
%   alfa = vector. (n x 1), where n is the number of variables. Constant
%   from regression
%
%   beta = matrix. (n x (m-1)), where n is the number of variables, and m-1
%   is the number of variables*number of lags. 
%
%   emat = matrix with residuals from regression. (t x n) , where t is the
%   numbe of observations, and n is the same as above.
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

defaults={'constant',true,@islogical};
options=validateInput(defaults,varargin);

neqs=size(result(:),1);
nvar=size(restrictions,2);

% empty variables for output
alfa=[];beta=zeros(neqs,nvar-1);emat=[];

for i=1:neqs
    if options.constant
        alfa=cat(1,alfa,result(i).beta(1));    
        b=result(i).beta(2:end);        
        cnt=0;        
        for ii=1:nvar-1
            if restrictions(i,ii+1)==1
                beta(i,ii)=b(1+cnt);                     
                cnt=cnt+1;
            end;    
        end;                    
    else            
        b=result(i).beta(1:end);        
        cnt=0;        
        for ii=1:nvar-1
            if restrictions(i,ii+1)==1
                beta(i,ii)=b(1+cnt);                     
                cnt=cnt+1;
            end;    
        end;                            
    end;
    emat=cat(2,emat,result(i).resid(:));
end;
