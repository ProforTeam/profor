function [tStat, varargout] = clarkWestTestStat(y1, y2, actual, varargin)
% clarkWestTestStat -   Clark and West test for equal forecasting performance for
%                   nested models.
%   see: "Approximately normal tests for equal predictive accuracy in nested 
%   models", Journal of Econometrics, 2006
%   See also discussions in Clark and McCracken "Testing for unconditional
%   predictive ability" Chapter 14 The Oxford Handbook of Economic Forecasting
%   Edited by Michael P. Clements and David F. Hendry
%
% Input: 
%   y1      [numeric](tx1)          out of sample forecasts for model 1    
%   y2      [numeric](tx1)          out of sample forecasts for model 2.
%       This model shoud nest model 1, eg. if some of the parameters in model 2
%       were set to zero, model 2 would be the same as model 1. 
%   actual 	[numeric](tx1)          acutal values for the same observations that
%                                   y1 and y2 gives forecasts for. 
%
%   varargin{1} = ('start',start)
%     start = optional. 
%       Integer indicating at which point in the (tx1) matrixes of forecasts 
%       from the two models test statistics should be computed from. 
%       Must be smaller than t, eg start<=t and start>0 (obviously there should 
%       be more than just a few observations in the sample to get a robust test)
%       Use this option if you want a number of test statistics to be computed
%       recusively from start=tt to start=t. Default is the length of the y1 
%       vector,  i.e., one test value is computed, using the whole vector of y1 
%       and y2. 
%
%   varargin{2} = ('alfa',alfa)
%   alfa = optional. This should be a integer, eg 5, 10  or something else
%   indicating the level of significance you want to test at. Remember that
%   this is a one sided test!
%   Default is 5
%
%   varargin{3} = ('h',h)
%   h = optional. Integer, Defining forecasting horizon. Will only be used to correct
%   for autocorrelation in the forecasts at horizons bigger than 1. If you
%   do not want to correct for this - let h == 1 irrespective of the actual
%   forecasting horizon. Correction will be made by using Newey-West
%   estimated of the variance
%   Default is 1.
%
% Output:
%   tStat 	[numeric]               number of t-statistics. 
%       If you compute the t-stat. for many vintages, this will be a vector. If 
%       you only do one vintage, this will be one number. If the number is 
%       bigger than 1.645 (for one sided 0.05 (alfa==5) test), the null hyp. of 
%       equal MSE is rejected  against the alternative that model 2 has better 
%       forecasting accuracy. 
%   
%   varargout{1}
%   tCrit = optional. Vector equal size as tStat with the critical values used to 
%   evaluate tStat. 
%
%   varargout{2}
%   info = optional. Cell, same size as tStat with info regarding the 
%   critical value(which is affected by the number of observations), 
%   and the hyp. test. 
%
% Usage: 
%   e.g. [tStat, tCrit] = clarkWestTest(y1, y2, acutal, 'start', 30, 'alfa', 5)
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
end
% length of vector
T = length(y1);

% Define some defaults
defaults        = {...
    'start',        T,     @isnumeric,...
    'alfa',         5,              @isnumeric,...
    'h',            1,              @isnumeric,...
    };
options         = validateInput(defaults, varargin);

% number of vintages to compute tStat values for
numberOfVintages = T - options.start + 1;

% error check 
if options.start > T
    error([mfilename ':input'],'The start index can not be set to a number bigger than the length of the y vector')
end

% make emty matrix for output
tStat = NaN(numberOfVintages, 1);
tCrit = NaN(numberOfVintages, 1);
info  = cell(numberOfVintages, 1);

%% Comput test statsistics 

% Construct vector to be used to compute test statistics. below we regress
% this vector on a constant and test whether the constant is significantly
% different from zero. The null hyp. is equal MSFE. The alternative is that
% model 2 has a smaller MSPE than model 1. We reject the null hyp. if the
% test stat. is greater than some boundary dep. on your choice. 
F = ( ((actual - y1).^2) - (((actual - y2).^2) - ((y1 - y2).^2)) );

% make some constants
iota = ones(T, 1);

% loop over number of vintages
for v = 1 : numberOfVintages
    y       = F( 1:options.start + v - 1, 1);
    x       = iota( 1:options.start + v - 1, 1);
    nobs    = length(y);    
    xpxi    = inv(x'*x);

    constant    = xpxi*(x'*y);
    yhat        = x*constant;
    resid       = y - yhat;    
    % if autocorr. in residuals, h>1, possible do newey west
    if options.h > 1
        nwerr       = neweyWestCorrectionOfVariance(resid, nobs, x, xpxi);
        tStat(v, 1) = constant/nwerr;        
    else
        sigu        = resid'*resid;
        sige        = sigu/(nobs - 1);
        sigc        = sqrt(sige*(diag(xpxi)));
        tStat(v, 1) = constant/sigc;
    end    
    % Calculate the critical sign. level    
    if nargout > 1
        % maybe this shoudl be the normal distrib??        
        tCrit(v, 1) = -tdis_inv(options.alfa/100, nobs);
        info{v}     = sprintf(['Ho: MSEy1 == MSEy2, H1: MSEy2<MSEy1\n',...
        'Reject the hypothesis of equal MSE if tstat > %f\n'], tCrit(v, 1));
    end
end

% If more than one output argument is present:
if nargout>1
    varargout{1} = tCrit;
    varargout{2} = info;
end

