function [intervalsMat, quantiles] = densityConfidenceIntervals(density, xDomain, varargin)
% densityConfidenceIntervals - Create time series for different quantiles of the 
%                              density.
%
% Usage: [intervalsMat  quantiles]=densityConfidenceIntervals(density,xDomain)
%
% Inputs:
%   density -   a matrix of forecasts (d x h) where d is the length of the 
%               xDomain and h is the number of horizons.
%   
%   xDomain -   the range of the density and the intervals ie -15:0.02:15 
%   varargin -  string followed by argument
%       'quantiles',arg = (1 x x) of confidence intervals (quantiles) 
%       (default intervals are [5 10 25 75 90 95])
%
% Outputs:
%   intervalsMat -  a matrix with that is (q x h), q = different quantiles 
%                   and h = number of horizons.
%
%   quantiles - a (1 x n) vector with quantiles. (Either the same as
%   supplied to function, or the defaults.)
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

%% optional input: quantiles

% Defaults
defaults = {'quantiles', [5 10 25 50 75 90 95], @isnumeric};
options = validateInput(defaults, varargin(1:nargin-2));


%% define inputs
xDomainIncrement = diff(xDomain(1:2));

% Determine the length of the xDomain
[xd, h] = size(density);

intervalsMat = nan(numel(options.quantiles), h);

%% loop through horizons and intervals and find x value
for t = 1 : h
    for q = 1 : numel(options.quantiles)
        if sum(density(:, t)) == 1
            % This is an observation, not a density
            intervalsMat(q, t) = xDomain(density(:, t)== 1);            
        else
            cumulativeProb  = cumsum(density(:, t))*xDomainIncrement;
            tmpDist         = abs(cumulativeProb - repmat(options.quantiles(q)/100, [xd 1]));
            [mi, ind]       = min(tmpDist);
            if isnan(mi)
                intervalsMat(q, t) = nan;
            else
                intervalsMat(q, t) = xDomain(ind);
            end
        end
    end
end
quantiles = options.quantiles;

