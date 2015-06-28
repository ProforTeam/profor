function [PIT, varargout] = computePits(actual, varargin)
% computePits -	Computes PITs for given input.
%   Input can be either means and std, or fully sepcified densites. Function can
%   also produce some standrad test statistics for uniformity of the PIT's. See
%   chapter 5 of Handbook of Economic Forecasting, volume 1, number 24 for
%   overview of tests and also "Evaluating Density Forecasts: Forecast
%   Combinations, Model Mixtures, Calibration and Sharpness", by James Mitchell1
%   and Kenneth F. Wallis
%
% Input:
%   actual      [numeric](tx1)  actual values the densities evaluated against.
%
%   varargin = Some required, some optional:
%
%   Analytic distribution: Normal
%       'sigma'     [string] followed by standard devitaions for each t in the
%                   actual vector
%       'mu'        [string] followed by vector with mean forecasts for each t in
%                   the actual vector.
%
%   Non parametric: PDF of xDomain
%       ( 'pdfOfxDomain', [numeric](n x t) )      
%           The densities evaluated over a xDomain. Where n is the evaluation 
%           points (xDomain) and t is the number of vintages (similar to t in 
%           the actual vector)
%       ( 'xDomain', [numeric](n x 1) )
%           The xDomain the density has been evaluated over, the n evaluation
%           points.
%
%   Optional varargin:
%       'tests'             [string]
%           followed by a logical. Default=false, and no tests will be produced.
%           If set to true, two tests will be done on the PIT values: the chi2
%           test and the liiliefors test. The first tests whether the PITs are
%           uniformly distrinuted directly, the latter transfroms the PITs into
%           iidN(0,1) variable using norminv, and tests for normality.
%           null hypothesis=distribution uniform/normal
%
%       'alfa'              [string]
%           followed by integer defining significance level of tests. Default =
%           0.05 Can not be smaller than 0.001 or bigger than 0.5.
%
% Output:
%
%   PIT 	[vector](t x 1)
%       where t is the same as in actual. Contains the probability of the
%       observations. Should be unifrmly distributed
%
%   varargout = optional output arguments.
%       If you do tests on the PITs, the test result will be in the varargout
%       structure. This contains two fields: .chiSquared and .lilliefors
%       Both fields will contain a column vector where the first number is either
%       one or zero: 1 if the null hypothesis can be rejected at the significance
%       level, 0 if the null hypothesis cannot be rejected at the significance
%       level. The second column is the p-value of the test
%
% IMPORTANT: The tests could probably be refined to take into account nested
% models, autocorrelation, estimated parameters etc! This is accounted for.
%
% Eg:
% Analytic case:
%   n     = 100;
%   act   = randn(n,1);
%   mu    = repmat(mean(act), [n 1]);
%   st    = repmat(std(act), [n 1]);
%   [PIT2, inf2] = computePits(act, 'mu', mu, 'sigma', st, 'tests', true, 'alfa'...
%                           ,0.05);
%
% Non-parametric case with equally spaced PDF.
%   n           = 100;
%   act         = 0.2;
%   xGrid       = linspace(-3, 3, n)';
%   pdfXdomain  = normpdf(xGrid, 0, 1);
% 
%   pitResult   = combinationFns.computePits(act, 'pdfOfxDomain', pdfXdomain, ...
%       'xDomain', xGrid);
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

warnType = [mfilename, ':war'];

% define some defaults
defaults        = {...
    'sigma',        [],     @isnumeric,...
    'mu',           [],     @isnumeric,...
    'xDomain',      [],     @isnumeric,...
    'pdfOfxDomain', [],     @isnumeric,...
    'tests',        false,  @islogical,...
    'alfa',         0.05,   @isnumeric};

options         = validateInput(defaults, varargin(1 : nargin - 1));
options.actual  = actual;

% empty to be used below
t               = size(options.actual,1);
PIT             = nan(t,1);

% different methods based on inputs
if ~isempty(options.xDomain) && ~isempty(options.pdfOfxDomain)
    
    options.xIncrement  = abs(options.xDomain(end) - options.xDomain(end-1));
    func                = @combinationFns.nonparametricPIT;
    
elseif ~isempty(options.mu) && ~isempty(options.sigma)
    func                = @combinationFns.parametricPIT;
else
    error('computePits:err', 'You have not provided the correct input to this function, see the instructions once more...')
end

% loop over vintages (could have been done without loop, but more transparent 
% with loop)
for i = 1 : t
    PIT(i)  = feval(func, options, i);
end

%%  do the tests if required

if options.tests
    
    % some error checks
    if options.alfa > 0.5 || options.alfa < 0.001
        msg = ['The program can not use alfa values bigger than 0.5 or ', ...
            'smaller than 0.001. See lillietest documentation. Alfa changed to default'];
        warning(warnType, msg)
        options.alfa    = 0.05;
    end
    
    % Do the Lilliefors test, see MATLAB documentation for details
    nPitTrans           = norminv(PIT, 0, 1);
    
    % null hypothesis=nPitTrans normal; alternative nPitTrans not normal.
    % The result h is 1 if the null hypothesis can be rejected at the significance level.
    % The result h is 0 if the null hypothesis cannot be rejected at the
    % significance level
    [lillh, lillp]      = lillietest(nPitTrans, options.alfa);
    
    % Do the Chi-square goodness-of-fit test
    edges               = linspace(0, 1, 11);
    expectedCounts      = t * diff(edges);
    % null hypothesis = PIT random sample from a uniform distribution;
    % alternative PIT not uniform
    % The result h is 1 if the null hypothesis can be rejected at the significance level.
    % The result h is 0 if the null hypothesis cannot be rejected at the spesified significance level.
    [chih, chip]        = chi2gof(PIT, 'edges', edges, 'expected', expectedCounts, 'alpha', options.alfa);
    
    % Prepare the output
    testResults.chiSquared  = [chih chip];
    testResults.lilliefors  = [lillh lillp];
    varargout{1}            = testResults;
    
end
end


