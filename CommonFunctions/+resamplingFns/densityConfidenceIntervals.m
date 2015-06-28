function [intervalsMat  percentiles] = densityConfidenceIntervals(density,xDomain,varargin)
% PURPOSE: This file creates time series for different quantiles of the density.

%Inputs:
%   density -   a matrix of forecasts (d x h) where d is the length of the 
%               xDomain and h is the number of horizons.
%   
%   xDomain -   the range of the density and the intervals ie -15:0.02:15 
%   varargin -  cell of confidence intervals (default intervals are 5 10 25 75 90 95)

%Outputs:
%   intervalsMat -  a matrix with that is (q x h), q = different quantiles 
%                   and h = number of horizons.
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

%% optional input: quantiles
if nargin>3
    disp('densityConfidenceIntervals input error: too many inputs')
elseif nargin==3
    percentiles=varargin;
else
    percentiles=[5 10 25 50 75 90 95]; %default quantiles
end;

%% define inputs
xDomainIncrement=diff(xDomain(1:2));

% Determine the length of the xDomain
[xd,h]=size(density);

intervalsMat=nan(numel(percentiles),h);

%% loop through horizons and intervals and find x value
for t=1:h
    for q=1:numel(percentiles)
        cumulativeProb=cumsum(density(:,t))*xDomainIncrement;
        tmpDist=abs(cumulativeProb-repmat(percentiles(q)/100,[xd 1]));
        [mi,ind]=min(tmpDist);
        if isnan(mi)
            intervalsMat(q,t)=nan;
        else
            intervalsMat(q,t)=xDomain(ind);
        end;
    end;
end;

