function daysInMonth = findDaysInMonth(year, month, varargin)
% findDaysInMonth - Find number of days in month in spesified month(s) and year(s)
%
% Input:
%   
%   year = integer or vector of numerics. Year(s) of which to evaluate
%
%   month = integer or vector of numerics. Months associated with the year
%   input. 
%
%   varargin = optional. String followed by input value or string. 
%       'freq' = string followed by a numeric value, either 1,4,12 or 365
%       for yearly, quarterly, monthly or daily frequencies respectively.
%       Default=4. Can also be string, but will then be converted in the
%       program, eg. a, q, m, d for yearly, quarterly, monthly or daily
%       frequencies respectively. Can also use 'b' or 262 for business. 
%       This will compute the numebr of days in the month, not counting the 
%       weekends.
%   
% Output: 
%
%   daysInMonth = integer or vector of integers. Reporting the number of
%   days in each month evalueated. 
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

defaults    = {'freq',     'q',    @(x)any(ischar(x) || isnumeric(x))};
options     = validateInput(defaults, varargin(1:nargin-2));

% convert to string if numeric
options.freq = convertFreqN(options.freq);

capT        = numel(year);
daysInMonth = [];

for i = 1 : capT

    monthCal = calendar(year(i), month(i));
    % get the calendar days                    
    if strcmpi(options.freq, 'b')
        d = sum(sum(monthCal(:,2:end-1)~=0));
    else
        d = sum(sum(monthCal~=0));
    end
                        
    daysInMonth = cat(1, daysInMonth, d);
        
end
