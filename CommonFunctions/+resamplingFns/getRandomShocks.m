function [shocks,drawsIdx]=getRandomShocks(emat,nfor,method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE: Generate random shocks based on residuals or draws from the
% normal
%
% USAGE: shocks=getRandomShocks(emat,nfor)
%
% Input: 
%
%   emat = (t x n) residual matrix, where t is time periods and n is number
%   of variables in model (VAR)
%
%   nfor = scalar. Forecasting horizon or number of observations (t)
%
%   method = string, either normal, br or bmb. If norm shocks are drawn 
%   from the normal dist. If br program performs a residual based 
%   bootstrap. If bmb program performs a moving block bootstrap. 
%   Default='norm'. Note, if method='bmb', draws and ematBlock must be 
%   provided as varargin (see below)
%
% Output:
%
%   shocks = (nfor x n), matrix with generated shocks. (From multivariate
%   normal)
%
%   drawsIdx = vector, (d x 1). Index numbers, where for:
%   'br' method d=nfor as defined above. Index numbers for draws of emat
%   'bmb' method d=draws, where draws is defined by function         
%   [b,draws]=getBootstrBlockSize(T) and T=size(emat,1). Index numbers for 
%   draws of ematBlock (see function getBootstrBlocks)
%   'norm' method drawsIdx=[]
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

[T,nvar]=size(emat);
sigma=(emat'*emat)/T;
% empty output
shocks=nan(nfor,nvar);
drawsIdx=[];
switch lower(method)
    case{'norm'}
        futureShocks=randn(nvar,nfor);     
        chQ=chol(sigma,'lower');
        for h=1:nfor
            shocks(h,:)=(chQ*futureShocks(:,h))';                   
        end;            
    case{'br'}
        %futureShocks=emat(ceil(rand(nfor,1)*T),:);
        %shocks=futureShocks;    
        emat=emat-repmat(mean(emat,1),[T 1]);        
        drawsIdx=ceil(rand(nfor,1)*T);
        shocks=emat(drawsIdx,:);        
    case {'bmb'}        
        
        import resamplingFns.*
        
        [b,draws]=getBootstrBlockSize(nfor);
        ematBlock=getBootstrBlocks(b,emat);                
        
        drawsIdx=ceil(rand(draws,1)*size(ematBlock,2));
        tmp=ematBlock(:,drawsIdx,:);
        for j=1:nvar
            tmp2=tmp(:,:,j);
            shocks(:,j)=tmp2(1:nfor);        
        end;       
    otherwise
        error('getRandomShocks:method','Input method is not supported')
end;



