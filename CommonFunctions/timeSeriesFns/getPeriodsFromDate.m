function periods_yyyynn = getPeriodsFromDate(date, n_periods, freq)
% getPeriodsFromStartDate Helper fn to return vector of dates from date at 
%                         given frequency for a set number of periods.
%
% Input:
%   date            [numeric] - Must be of format YYYYMMDD
%   n_periods       [numeric] - Number of periods for vintages
%   freq            [str]     - Frequency of period.
%
% Usage:
%   periods_yyyynn  [numeric] - YYYY.NN format, eg. 2000.01
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

%% Validation
errType = ['timeSeriesFns:', mfilename ];

assert(strcmpi(freq, 'q'), errType, 'NotImplementedError: Only quarterly freq');

% Set freq_number for generation of quarterly data.
freq_number = 4;

% TODO: Check inVintageDate of YYYYMMDD format.
if ~isnumeric(date)
    error(errType, 'date date has to be double')
end

if numel(num2str(date)) < 8
    error([errType, 'The date should be of YYYYMMDD format'])
end

%% Generate dates from date, n_periods, and eventually freq.

% Convert start date to Matlab datenum format. 
date_datenum = str2Datenum( num2str(date), {'yyyymmdd'});

% Use Matlab's datenum form to get the start year and end.
[bYear, ~, bPeriod, ~] = convertMadToNum(date_datenum, ...
    date_datenum, freq);

% Generate the n_period dates from date onwards.
periods_yyyynn =  csttt(bYear, bPeriod, n_periods, freq_number);

end
