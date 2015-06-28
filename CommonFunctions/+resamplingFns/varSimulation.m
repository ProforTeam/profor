function [CS, TS, yS, QS, uS, DrawsIdx] = varSimulation(C0, T0, u0, nvar, nlag,...
    T, varargin)
% varSimulation	Simulate a VAR data generating process by bootstrapping, eg 
%               drawing from the residuals. Only one draw will be made if more 
%               are not defined in the varargin input
%
% Input:
%   T0 = matrix. (n+(n*(nlag-1))) x (m-1)). VAR(p) respresented as
%   VAR(1). beta parameters in VAR regression (not inclding const.)
%
%   C0 = vector. (n+(n*(nlag-1))) x 1). VAR(p) respresented as
%   VAR(1). Constants in VAR regression
%
%   u0 = residual matrix. (t x n), where t is the number of obserations,
%   and n is the number of variables in the VAR
%   
%   nlag = number of lags used in VAR
%   
%   nvar = number of variables in VAR
%  
%   T = number of observations in original estimation
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
%   betab = matrix. This will be the bootstrapped beta parameter values. 
%   (nvar x nvar*nlag x draws)
%
%   alfab = matrix. This will be the bootstrapped alfa parameter values. 
%   (nvar x 1 x draws)
%
%   varargout = optional ouput:
%       
%       Y = Dependant variable(s) matrix for each draw, (T x nvar x draws)
%
%       SIGMA = covariance matrix from each draw, (nvar x nvar x draws)
%       
%       DrawsIdx = vector with index of draw indexes used to simulate VAR
%       (T+ x 1 x draws)
%
%   IMPORTANT: The variables needs to be ordered the following way in the 
%   T0 coeff matrix:
%   [y1(t-1) y2(t-1) yn(t-1)...y1(t-nlag) y2(t-nlag) yn(t-nlag)]
%   The C0 and T0 vector and matrix must also represent VAR(p) as
%   VAR(1), see function varGetCompForm.m
%
% Usage: [alfab, betab, varargout] = varSimulation(C0, T0, u0, nvar, nlag, T)
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

import varUtilitiesFns.*
import resamplingFns.*

% Defaults
defaults={...
    'burninn',  50,@isnumeric,...
    'draws',    1,@isnumeric,...
    'tPlus',    0,@isnumeric,...
    'stability',true,@islogical,...
    'sur',false,@islogical,...
    'betaRestrictions',[],@isnumeric,...
    'startingValues',[],@isnumeric,...
    'bootStrapMethod','br',@(x)any(strcmpi(x,{'br','bmb','norm'})),...
    'showProgress',true,@islogical};

options=validateInput(defaults,varargin);

if options.tPlus>options.burninn-30
    options.burninn=2*options.tPlus;
end
if isempty(C0)
    options.constant=false;
    C0=zeros(size(T0,1),1);
else
    options.constant=true;
end
if isempty(options.betaRestrictions) && options.sur
    error([mfilename ':input, You want to do SUR simulation, but have not provided betaRestrictions'])
end

CS  = nan(nvar*nlag,1,options.draws);
TS  = nan(nvar*nlag,nvar*nlag,options.draws);
QS  = nan(nvar,nvar,options.draws);

yS  = zeros(T + options.tPlus, nvar, options.draws);

uS  = zeros(T+options.tPlus,nvar,options.draws);

DrawsIdx=[];
stabilityCondition=1;
zeroAddOn=zeros((nlag-1)*nvar,1);

if options.draws>1 && options.showProgress
    parfor_progress(options.draws);
end

for d=1:options.draws
    
    if options.draws>1 && options.showProgress
        parfor_progress;
    end
    
    while stabilityCondition==1        
        
        [randResid,drawsIdx]=getRandomShocks(u0,T+options.burninn,options.bootStrapMethod);        

        %empty y mat for iterated vector
        y=nan(nvar,options.burninn+T);
        if ~isempty(options.startingValues)
            yy=options.startingValues'; % (nlag x n)'=(n x nlag)
            yy=yy(:); %(nvar*nlag)
        else
            yy=zeros(nvar*nlag,1);
        end
        %simulate system        
        randResid=randResid';
        for s=1:options.burninn+T
            ee=[randResid(:,s);zeroAddOn];            
            %if s==1
            %    yy=zeros(nvar*nlag,1);
            %else
            %    yy=[]
            %end            
            yy=C0+T0*yy+ee;            
            y(:,s)=yy(1:nvar,1);
        end
        % estimate new parameters 
        [estYL,estXL]=varOrderDataFast(y',nvar,nlag,options.constant);
        
        % make sample length T
        estYb   = estYL(end - T + 1 : end, :);
        estXb   = estXL(end - T + 1 : end, :);
        
        if options.sur            
            if options.constant                
                % get sur input from lat output. If no restrictions this will give ordianry
                % ols/ML results
                [sy,sx]=var2SUR(estYb,estXb,'restrictions',options.betaRestrictions);   
            else
                [sy,sx]=var2SUR(estYb,estXb,'restrictions',options.betaRestrictions(:,2:end));                                   
            end                        
            surResults=latSur(nvar,sy,sx,1);
            % transforms sur output to lat var putput
            [aa,bb,emati]=sur2VAR(surResults,options.betaRestrictions,'constant',options.constant);
            sigma=(emati'*emati)/(T-(nvar*nlag)-options.constant);                                   
        else            
            % estimate the parameters
            [aa,bb,emati,sigma]=varEst(estYb,estXb,options.constant);            
        end
        
        % get comp form to check stability
        [betaCbb,alfaCbb]=varGetCompForm(bb,aa,nlag,nvar);
        if options.stability
            if any(abs(real(eig(betaCbb)))>=1)
                stabilityCondition=1;
            else
                % To brake out of while statement if stability
                % ensured
                stabilityCondition=0;
            end
            
        else
            
            % To brake out of while statement if stability not important
            stabilityCondition=0;
            
        end
    
    end
    if options.constant
        CS(:,1,d)=alfaCbb;
    end
    TS(:,:,d)       = betaCbb;
    QS(:,:,d)       = sigma;
    yS(:, :, d)     = y(:, end - T - options.tPlus + 1 : end)';     
    uS(options.tPlus+1:end,:,d)=emati; 
    
    if strcmpi(options.bootStrapMethod,'br')    
        DrawsIdx=cat(3,DrawsIdx,drawsIdx(end-T-options.tPlus+1:end,1));
    end
    
    % to go into while statement
    stabilityCondition=1;
    
end

if options.draws>1 && options.showProgress
    parfor_progress(0);
end

