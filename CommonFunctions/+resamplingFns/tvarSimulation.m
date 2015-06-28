function [CS, TS, yS, QS, uS] = tvarSimulation(nvar, nlag, T, sIdx,...
                                             cOpt, decayOpt, result, varargin)
% tvarSimulation	Simulate a TVAR data generating process by bootstrapping, eg 
%               drawing from the residuals. Only one draw will be made if more 
%               are not defined in the varargin input
%
% Input:
%   
%   nvar        [numeric]
%               number of variables in VAR
%
%   nlag        [numeric]
%               number of lags used in VAR
%  
%   T           [numeric]
%               number of observations in original estimation
%
%   sIdx        [numeric]
%               integer, indicating which variable in y should be used as
%               indicator for threshold (sIdx in the set {1,..,n})
%
%   cOpt        [integer]
%               the optimal threshold value
%
%   decayOpt    [interger]
%               the optimal decay factor
%
%   result      [structure]
%               result structure from tvarEstOptim. 
%               See also TVARESTOPTIM
%
%   varargin = optional:
%   'burninn' = string, defining the length of the burninn period (only
%   used if parametric=false). Must be followed by a number, eg 30.
%   Default=50
%
%   'draws' = string, defining the number of draws to be made. Must be
%   followed bu a number. Default=1
%
%   'tPlus' = string, defining if extra length should be added to the Y
%   (varargout) argument
%
%   'startingValues' = matrix, (nlag x n). Starting values used for
%   simulations
%
%   'bootStrapMethod' = string. Either 'br','bmb' or norm for respectively
%   residual BS, moving block BS or draws from the standrad normal. 
%
% Output:
%   
%   CS
%
%   TS
%
%   yS
%
%   QS
%
% Usage: 
%
%   [CS, TS, yS, QS] = tvarSimulation(nvar, nlag, T, sIdx,...
%                                             cOpt, decayOpt, result)
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
    'burninn',  50,@isnumeric,...
    'draws',    1,@isnumeric,...
    'tPlus',    0,@isnumeric,...
    'stability',true,@islogical,...        
    'startingValues',[],@isnumeric,...
    'bootStrapMethod','br',@(x)any(strcmpi(x,{'br','bmb','norm'})),...
    'showProgress',true,@islogical};

options = validateInput(defaults,varargin);

if options.tPlus > options.burninn - 30
    options.burninn = 2*options.tPlus;
end

CS  = nan(nvar*nlag, 1, 2, options.draws);
TS  = nan(nvar*nlag, nvar*nlag, 2, options.draws);
yS  = zeros(T + options.tPlus, nvar, options.draws);
QS  = nan(nvar,nvar,2,options.draws);
uS  = zeros(T, nvar, options.draws);

%DrawsIdx            = [];
stabilityCondition  = 1;
zeroAddOn           = zeros((nlag - 1)*nvar, 1);

[T0_1,C0_1] = varUtilitiesFns.varGetCompForm(result(1).beta, result(1).alfa, nlag, nvar);
[T0_2,C0_2] = varUtilitiesFns.varGetCompForm(result(2).beta, result(2).alfa, nlag, nvar);

if options.draws>1 && options.showProgress
    parfor_progress(options.draws);
end

for d = 1:options.draws
    
    if options.draws>1 && options.showProgress
        parfor_progress;
    end
    
    while stabilityCondition == 1        
        
        % For regime 1 and 2
        [randResid_1d, ~] = resamplingFns.getRandomShocks(result(1).emat, T + options.burninn, options.bootStrapMethod);        
        [randResid_2d, ~] = resamplingFns.getRandomShocks(result(2).emat, T + options.burninn, options.bootStrapMethod);        

        % Empty y mat for iterated vector
        yd = nan(nvar, options.burninn + T);
        if ~isempty(options.startingValues)
            yyd = options.startingValues'; % (nlag x n)'=(n x nlag)
            yyd = yyd(:); %(nvar*nlag)
        else
            yyd = zeros(nvar*nlag,1);
        end
        
        % Simulate system        
        randResid_1d = randResid_1d';
        randResid_2d = randResid_2d';
        
        for s = 1:options.burninn + T
            
            ee_1ds = [randResid_1d(:,s);
                        zeroAddOn];            
            ee_2ds = [randResid_2d(:,s);
                        zeroAddOn];                        
                    
            if yyd(sIdx*decayOpt) <= cOpt
                yyd = C0_1 + T0_1*yyd + ee_1ds;                                                
            else
                yyd = C0_2 + T0_2*yyd + ee_2ds;
            end                                                        
            yd(:, s) = yyd(1 : nvar, 1);
            
        end
        
        %% Estimate new parameters 
        [estYL,estXL] = varUtilitiesFns.varOrderDataFast(yd',nvar,nlag,true);
        
        % Make sample length T
        estYb   = estYL(end - T + 1 : end, :);
        estXb   = estXL(end - T + 1 : end, :);
                                                       
        % The treshold variable
        s                       = yd(sIdx,:)';
        slag                    = latMlag(s,decayOpt);
        sd                      = slag(end - T + 1:end,end);        
        [orderSd, orderSindxd]  = sort(sd);        
        [Qc, resultd]           = varUtilitiesFns.tvarEst(estYb, estXb,...
                                                      orderSd, orderSindxd, cOpt);        
                
        % Get comp form to check stability
        [T0_1d,C0_1d] = varUtilitiesFns.varGetCompForm(resultd(1).beta, resultd(1).alfa, nlag, nvar);
        [T0_2d,C0_2d] = varUtilitiesFns.varGetCompForm(resultd(2).beta, resultd(2).alfa, nlag, nvar);      
        
        if options.stability
            if any(abs(real(eig(T0_1d))) >= 1) || any(abs(real(eig(T0_2d))) >= 1)
                stabilityCondition = 1;
            else
                % To brake out of while statement if stability
                % ensured
                stabilityCondition = 0;
            end
            
        else
            
            % To brake out of while statement if stability not important
            stabilityCondition=0;
            
        end
    
    end    
    
    CS(:,1,1,d) = C0_1d;
    CS(:,1,2,d) = C0_2d;        
    TS(:,:,1,d) = T0_1d;
    TS(:,:,2,d) = T0_2d;    
    QS(:,:,1,d) = resultd(1).Q;
    QS(:,:,2,d) = resultd(2).Q;    
    yS(:, :,d)  = yd(:, end - T - options.tPlus + 1 : end)';         
    idx                 = sd <= cOpt;
    uS(idx,:,d)         = resultd(1).emat;
    uS(idx == 0,:,d)    = resultd(2).emat;
    
    % To go into while statement
    stabilityCondition = 1;
    
end

if options.draws > 1 && options.showProgress
    parfor_progress(0);
end


