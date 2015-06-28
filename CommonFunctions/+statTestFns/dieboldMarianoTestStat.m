function [tStat, mse, varargout] = dieboldMarianoTestStat(y1, y2, actual, varargin)
% dieboldMarianoTest  -  Diebold and Mariano test for equal forecasting performance
%                       for non-nested models. 
%   Function also produces mse values + some optional output arguments (see below)
%  
% Issues arise in small samples and with nested models
% see harveyLeybourneNewbold_dieboldMariano.m
% and clarkWEstTestStat.m
% Best regarded as a "rough guide" to significance in many applications.
%
% Input: 
%   y1      [numeric](tx1)      Out of sample forecasts for model 1    
%   y2      [numeric](tx1)      Out of sample forecasts for model 2.
%   actual 	[numeric](tx1)      Acutal values for the same observations that
%                               y1 and y2 gives forecasts for. 
%   varargin:
%   ('start', start)    [int]
%       Indicating at which point in the (tx1) matrixes of forecasts from the 
%       two models test statistics should be computed from. Must be smaller than 
%       t, eg start<=t and start>0. Use this option if you want a number of test 
%       statistics to be computed recusively from start=tt to start=t. Default 
%       is the length of the y1 vector,  i.e., one test value is computed, using 
%       the whole vector of y1 and y2. 
%
%   ('alfa', alfa)      [int]
%       Two sided level of significance for the test. Default is 5
%
%   ('h', h)            [int]
%   	Forecast horizon. Will only be used to correct for autocorrelation in 
%       the forecasts at horizons bigger than 1. If you do not want to correct 
%       for this - let h == 1 irrespective of the actual forecasting horizon. 
%       Correction will be made by using Newey-West estimated of the variance
%       Default is 1.
%
% Output:
%   tStat       [numeric]
%       Vector or of t-statistics. If you compute the t-stat for many vintages, 
%       this will be a vector. If you only do one vintage, this will be one 
%       number. If the absolute value if the number is bigger than 1.96 (for two 
%       sided 0.05 (alfa==5) test, not corrected for small sample), the null hyp. 
%       of equal MSE is rejected against the alternative that the forecasting 
%       performance is sign. different. 
%   
%   mse         [numeric](vintages x 2)
%       Where vintages will be the same as above (see 'start' option) and the 
%       mse for y1 will be in the first column and the mse value for y2 in the 
%       second column. 
%
%   varargout:
%   tCrit       [numeric]
%       Vector equal size as tStat with the critical values used to evaluate 
%       tStat. 
%   info        [cell]
%       Same size as tStat with info regarding the critical value (which is 
%       affected by the number of observations), and the hyp. test. 
%   bias        [numeric] 
%       matrix same size as mse, containing values for the bias    
%
% Usage: 
%   [tStat, mse, varargout] = dieboldMarianoTest(y1, y2, actual, varargin)
%   e.g. 
%   [tStat, tCrit] = dieboldMarianoTest(y1, y2, acutal, 'start', 30, 'alfa', 5)
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
tStat   = NaN(numberOfVintages, 1);
mse     = NaN(numberOfVintages, 2);
bias    = NaN(numberOfVintages, 2);
tCrit   = NaN(numberOfVintages, 1);
info    = cell(numberOfVintages, 1);

%% Compute test statsistics 

% Construct vector to be used to compute test statistics. below we regress
% this vector on a constant and test whether the constant is significantly
% different from zero. The null hyp. is equal MSFE. The alternative is that
% the models has different forecasting performance. We reject the null hyp. if the
% test stat. is greater than some boundary dep. on your choice. 
F = ( (actual - y1).^2) - ((actual - y2).^2);

% make some constants
iota = ones(T,1);

% loop over number of vintages
for v = 1:numberOfVintages
    
    % compute mse
    mse(v, 1) = mean( (actual(1:options.start + v - 1) - y1(1:options.start + v - 1)).^2 );
    mse(v, 2) = mean( (actual(1:options.start + v - 1) - y2(1:options.start + v - 1)).^2 );
        
    % compute test statistics
    y       = F(1:options.start + v - 1, 1);
    x       = iota(1:options.start + v - 1, 1);
    nobs    = length(y);    
    xpxi    = inv(x'*x);

    constant    = xpxi*(x'*y);
    yhat        = x*constant;
    resid       = y - yhat;
    
    % if autocorr. in residuals, h>1, possible do newey west
    if options.h > 1
        nwerr       = neweyWestCorrectionOfVariance(resid, nobs, x, xpxi, 'nlag', options.h-1);
        tStat(v, 1) = constant/nwerr;        
    else
        sigu        = resid'*resid;
        sige        = sigu/(nobs - 1);
        sigc        = sqrt(sige*(diag(xpxi)));
        tStat(v, 1) = constant/sigc;
    end    
    % Calculate the critical sign. level    
    if nargout > 2
        % maybe this shoudl be the normal distrib??        
        tCrit(v, 1) = -tdis_inv(options.alfa/200, nobs);
        info{v}     = sprintf(['Ho: MSEy1 == MSEy2, H1: MSEy2~=MSEy1\n',...
        'Reject the hypothesis of equal MSE if |tstat| > %f\n'],tCrit(v, 1));
        
        %compute the bias
        bias(v, 1) = mean( y1(1:options.start + v - 1) - actual(1:options.start + v - 1) );
        bias(v, 2) = mean( y2(1:options.start + v - 1) - actual(1:options.start + v - 1) );
    
    end         
    
end

% If more than one output argument is present:
if nargout > 2
    varargout{1} = tCrit;
    varargout{2} = info;
    varargout{3} = bias;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
