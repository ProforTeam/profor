function ematBlock=getBootstrBlocks(b,emat)
% PURPOSE: Generate overlapping blocks for moving block bootstrap procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%   
%   b = numeric, size of block. See function getBootstrBlockSize
%
%   emat = matrix (t x n) of residuals
%
% Output:
%
%   ematBlock = matrix (b x (t-b+1) x n) of overlapping blocks 
%
% Usage:
%   ematBlock=getBootstrBlocks(b,emat)
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

[T,n]=size(emat);
% ensure zero mean
emat=emat-repmat(mean(emat,1),[T 1 1]);        

N=T-b+1;
ematBlock=nan(b,N,n);
for j=1:n
    for i=1:N
        ematBlock(:,i,j)=emat(i:b+i-1,j);
    end;
end