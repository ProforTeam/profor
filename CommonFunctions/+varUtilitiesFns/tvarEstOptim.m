function [cOpt, decayOpt, result, sd] = tvarEstOptim(y, nlag, sIdx, varargin) 
% tvarEstOptim  - Estimate TVAR and optimal decay and threshold values
%
% Input: 
%
%   y           [numeric]
%               matrix (t x n), where t is number of observations and n number
%               of variables. Can not contain NaN's.
%
%   nlag        [numeric]
%               defines number of lags to be used (for the moment the same
%               number of lags must be used in each regime)
%
%   sIdx        [numeric]
%               integer, indicating which variable in y should be used as
%               indicator for threshold (sIdx in the set {1,..,n})
%
%   varargin    [optinal input arguments, sting followed by argument]
%       .quantile   [numeric]
%                   defines the lower (quantile) and upper (1-quantile).
%                   Default = 0.15
%       .maxDecay   [numeric]
%                   integer, defines the maximum lag for the decay parameter
%                   (must be less than or equal to nlag). Default = nlag
%
% Output:
%
%   cOpt        [integer]
%               the optimal threshold value
%
%   decayOpt    [interger]
%               the optimal decay factor
%
%   sd          [vector]
%               (tt x 1), the treshold variable for the decayOpt. 
%               tt is the length of y after removing nlag. 
%
%   result      [structure]
%               containing the following fields for each regime:
%               result(i).alfa  = constant parameters (n x 1)
%               result(i).beta  = lag parameters (n x nlag*n)
%               result(i).emat  = residuals (t1 x n)
%               result(i).Q     = error covariance matrix (n x n)
%               result(i).t     = nobs in this regime - t1
%
% Usage: 
%
% [cOpt, decayOpt, result, orderS, orderSindx] = tvarEstOptim(y, nlag, sIdx,...
%                                                      'maxDecay',nlag - 1) 
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



% Defaults
defaults={...
    'quantile', 0.15, @(x)(x>0 && x<1),...
    'maxDecay', nlag, @isnumeric};

options = validateInput(defaults,varargin);


%% 0) Preliminary stuff

[~, n] = size(y);

if options.maxDecay > nlag
   error([mfilename ':input'],'maxDecay is larger than nlag. Not allowed') 
end

if sIdx > n || sIdx < 0
    error([mfilename ':input'],'sIdx is not in among the variables in y') 
end;

%% 1) Get some initial information

% The treshold variable
s = y(:,sIdx);

% Get the range for which to search for tresholds
initOrderS  = sort(s);
quantOrderS = quantile(initOrderS,[options.quantile 1 - options.quantile]);
[~,sidx]    = min(abs(initOrderS - quantOrderS(1)));
[~,eidx]    = min(abs(initOrderS - quantOrderS(2)));

% Prepare the data
slag    = latMlag(s,options.maxDecay);
slag    = slag(1+nlag:end,:);

ylag    = latMlag(y,nlag);
x       = [ones(size(ylag,1),1) ylag];

xx      = x(1+nlag:end,:);
yy      = y(1+nlag:end,:);

%% 1) estimate d and c, i.e., the decay factor and the treshold value

% Do a grid search...
Qc      = nan(eidx - sidx + 1, options.maxDecay);
for d   = 1 : options.maxDecay
    
    sd                      = slag(:,d);
    [dOrderS, dOrderSindx]  = sort(sd);    
    
    for i = sidx : eidx
        ci                  = dOrderS(i);            
        Qc(i - sidx + 1, d) = varUtilitiesFns.tvarEst(yy, xx, dOrderS, dOrderSindx, ci);                
    end
    
end

%% 2) Get final output
[~,idx]         = min(vec(Qc));
[I, decayOpt]   = ind2sub(size(Qc),idx);

sd                      = slag(:,decayOpt);
[orderS, orderSindx]    = sort(sd);    
orderSUsed              = orderS(sidx:eidx);
cOpt                    = orderSUsed(I);

[Qc, result]            = varUtilitiesFns.tvarEst(yy, xx, orderS, orderSindx, cOpt);                


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
