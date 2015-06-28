function [tStat, varargout] = logScoreTestStat(y1, y2, nested, varargin)
% logScoreTestStat Perform one-shot test for equal logScore
% of forecast densities. 
% Equivalent to the Diebold-Mariano test 
% for point forecasts, various familiar issues
% arise, including with autocorrelation in forecasts,
% non-rolling regressions and nested models.  Best
% regarded as a "rough guide" to significance.
%
% The program uses adjusted variances to handle
% autocorrelation in the forecasts. Models
% can be specified as nested or not.
%
% Bao, Y., T-H. Lee and B. Saltoglu (2007) "Comparing Density Forecast Models",
% Journal of Forecasting, 26, 203-225.
%
% Amisano, G. and R. Giacomini (2007) "Comparing Density Forecasts via Likelihood
% Ratio Tests", Journal of Business and Economic Statistics, 25, 2, 177-190. 
%
% Hall, S. and  J. Mitchell "Evaluating, Comparing and Combining density Forecasts Using the
% KLIC with an Application to the bank of England and NIESR 'Fan' Charts of
% Inflation", OxFord Bulletin of Economics and Statistic, 2005
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input: 
%   y1 = vector (tx1), with out of sample logScore values for model 1 
%   
%   y2 = vector (tx1), with out of sample logScore values for model 2.
%
%   nested = integer. nested == 1 if the models that you compare are nested.
%   If the models are not nested 'nested'==0;
%
%   varargin{1} = ('start',start)
%   start = optional. Integer indicating at which point in the (tx1) matrixes of
%   forecasts from the two models test statistics should be computed from. 
%   Must be smaller than t, eg start<=t and start>0 (obviously there should be
%   more than just a few observations in the sample to get a robust test)
%   Use this option if you want a number of test statistics to be computed
%   recusively from start=tt to start=t. Default is the length of the y1 vector, 
%   i.e., one test value is computed, using the whole vector of y1 and y2. 
%
%   varargin{2} = ('alfa',alfa)
%   alfa = optional. This should be a integer, eg 5, 10  or something else
%   indicating the level of significance you want to test at. Remember that
%   this is a two sided test!
%   Default is 5
%
% Output:
%   tStat = Vector or number of t-statistics. If you compute the t-stat.
%   for many vintages, this will be a vector. If you only do one vintage,
%   this will be one number. If the number is bigger than 1.645 in absolute 
%   value(for two sided 0.05 (alfa==5) test), the null hyp. of equal logScore 
%   is rejected against the alternative that model 2 has better forecasting accuracy. 
%   
%   varargout{1}
%   tCrit = optional. Vector equal size as tStat with the critical values used to 
%   evaluate tStat. Note that the ctitical values for the nested version of
%   this test is collected from the chi-squared test statistics
%
%   varargout{2}
%   info = optional. Cell, same size as tStat with info regarding the 
%   critical value(which is affected by the number of observations), 
%   and the hyp. test. 
%
% Example: [tStat,tCrit]=logScoreTestStat(y1,y2,acutal,'start',30,'alfa',5)
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



%% Initial stuff
if nargin < 3
    error([mfilename ':input'],'This function needs at least three input arguments')
end;
% length of vector
T = length(y1);

% Define some defaults
defaults        = {...
    'start',        T,     @isnumeric,...
    'alfa',         5,              @isnumeric,...
    };
options         = validateInput(defaults, varargin);

% number of vintages to compute tStat values for
numberOfVintages = T - options.start + 1;

% error check 
if options.start > T
    error([mfilename ':input'],'The start index can not be set to a number bigger than the length of the y vector')
end;

% make emty matrix for output
tStat = NaN(numberOfVintages, 1);
tCrit = NaN(numberOfVintages, 1);
info  = cell(numberOfVintages, 1);

%% Comput test statsistics 

% Construct vector to be used to compute test statistics. below we regress
% this vector on a constant and test whether the constant is significantly
% different from zero. The null hyp. is equal logScore. The alternative is that
% model 1 and model 2 have different logScore. We reject the null hyp. if the
% test stat. is greater than some boundary dep. on your choice. 
if nested == 0 
    % computes d(t) to be regressed on a constant
    F = y2 - y1;
    % define nestCnt to add start at the first row in the output arguments
    nestCnt = 0;
elseif nested == 1
    % computes h(t-1)*d(t) to be regressed on a constant, where
    % h(t-1)=(1,d(t-1))'. Note that we loose one observation by doing this!        
    tmpF    = y2 - y1;
    F       = [tmpF(2:end, 1), tmpF(1:end - 1, 1).*tmpF(2:end, 1)];
    % define nestCnt to add start at the second row in the output arguments
    nestCnt = 1;
else
    error([mfilename ':input'],'Nested needs to be either 0 or 1. Nested==0; the models are NOT nested\nNested==1; the models are nested')
end;

% make some constants
iota = ones(size(F, 1), 1);

% loop over number of vintages
for v = 1:numberOfVintages - nestCnt
    if nested == 0
        y       = F(1:options.start + v - 1, 1);
        x       = iota(1:options.start + v - 1, 1);
        nobs    = length(y);        
        xpxi    = inv(x'*x);
        
        constant    = xpxi*(x'*y);
        yhat        = x*constant;
        resid       = y - yhat;

        % autocorr. in residuals
        sigc        = neweyWestCorrectionOfVariance(resid, nobs, x, xpxi);        
        tStat(v, 1) = abs(constant/sigc);        
        
    elseif nested == 1
        FF = F(1:options.start + v - 1, :);
        TT = size(FF, 1);
        
        sigc         = covzeromean(FF) + 2*covzeromean( (FF(2:end, :)'*FF(1:end - 1, :)) );
        tStat(v+1,1) = abs( TT*mean(FF, 1)*inv(sigc)*mean(FF,1)' );
    end;   
    % Calculate the critical sign. level    
    if nargout > 1
        if nested == 0   
            % maybe this shoudl be the normal distrib??
            tCrit(v, 1) = -tdis_inv(options.alfa/100, nobs);
            info{v}=sprintf(['Ho: logScorey1 == logScorey2, H1: logScorey1~=logScorey2\n',...
                'Reject the hypothesis of equal logScore if tStat > %f\n'],tCrit(v, 1));        
        elseif nested == 1
%            probability=chi2cdf(tStat(v+nestCnt,1),2);        
            tCrit(v + 1, 1)=chis_inv(options.alfa/100, 2);
            info{v + 1}=sprintf(['Ho: logScorey1 == logScorey2, H1: logScorey1~=logScorey2\n',...
                'Reject the hypothesis of equal logScore if tStat > %f\n'],tCrit(v + nestCnt, 1));
        end;
    end;
end;
% If more than one output argument is present:
if nargout > 1
    varargout{1} = tCrit;
    varargout{2} = info;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = covzeromean(x)
% PURPOSE: Computes inpu to robust cov matrix est.
[T, m]  = size(x);
y       = NaN(m, m);
for i = 1:m
    for j = 1:m
        y(i, j) = (x(:,i)'*x(:,j))/T;
    end;    
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


