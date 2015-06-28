function daysInWeek = findDaysInWeek(year, month)
% findDaysInWeek - Find number of business days in week with spesified month(s) and 
% year(s)
%
% Input:
%   
%   year = integer or vector of numerics. Year(s) of which to evaluate
%
%   month = integer or vector of numerics. Months associated with the year
%   input. 
%   
% Output: 
%
%   daysInWeek = integer or vector of integers. Reporting the number of
%   days in each week evalueated for the month of interest. 
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

capT        = numel(year);
daysInWeek  = [];

for i = 1 : capT

    monthCal = calendar(year(i), month(i));
    % get the calendar days    
    for ii = 1 : size(monthCal, 1)
        d           = sum(sum(monthCal(ii,2:end-1)~=0));                            
        daysInWeek  = cat(1, daysInWeek, d);
    end;
            
end

% take away zero weeks since these are not among the weeks in the month!
tmp         = daysInWeek ~= 0;
daysInWeek  = daysInWeek(tmp);

