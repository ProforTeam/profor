function [xtick, xlabel] = setXtickAndLabel(dates, varargin)
% setXtickAndLabel - Set xtick and label such that it prints nicely on the axis
%
% Input:
%
%   dates = vector (n x 1), with cs dates
%
% Output:
%
%   xtick = vector with evenly spaced xtick index. Ensures that first and
%   last dates are referenced. 
%
%   xticklabel = vector (same length as xtick) with matcing dates
%
% Usage:
%
%   [xtick,xlabel]=setXtickAndLabel(dates,varargin)
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

% Defaults
defaults={...
    'maxTicks',     5,  @isnumeric,...
    'handle',       [], @(x)ishandle(x)||isempty(x),...
    'include',      [], @isscalar,...
    'xtickStart',   1,  @isnumeric...
    };

options = validateInput(defaults, varargin(1:nargin-1));

%%
r       = numel(dates);

% Set the ticks such that if fewer than 5 ticks then will just take the number
% of dates as r, i.e. min(maxTicks, r) below.
ticks   = ceil( linspace(1, r, min(options.maxTicks, r) ));

% ensure that ticks end at last date
if ticks(end) ~= r
    ticks(end) = r;
end

if ~isempty(options.include)
    if ~any(options.include == ticks)                
        ind     = ticks < options.include;
        ticks   = [ticks(ind) options.include ticks(ind == 0)];
    end
end    

% output
xtick   = ticks;
xlabel  = dates(xtick);
if ishandle(options.handle)
    set(options.handle, 'xtick', xtick);
    set(options.handle, 'xticklabel', xlabel);
end
