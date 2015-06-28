function dates = str2DateYYYYNN(dates, dateFormat, freq)
% str2DateYYYYNN  - Converts str in dateFormat to YYYY.NN format used by PROFOR.
%   Loops over the formats for the date in dateFormat until one works, if none
%   do then throws error.
%
% Input:
%   dates           [str]
%   dateFormat      [cellstr]       e.g. {'yyyy-mm-dd'}
%   freq            [str]           e.g. 'q'
%
% Output:
%   dates           [double]        PROFOR's YYYY.NN format.
%
% Usage:
%   dates = str2DateYYYYNN(dates, dateFormat, freq)
% e.g.
%   dates = str2DateYYYYNN('2001-09-23', {'YYYY-MM-DD', 'yyyy.mm.dd'}, 'q')
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

%% Validation
errType = ['timeSeriesFns:', mfilename ]; 

assert(iscellstr( dateFormat ), errType, 'Date format must be cellstr')

%% Convert the string to YYYY.NN format.

% Convert the string of dates to Matlab's datenum format.
dates                   = str2Datenum(dates, dateFormat);

% Find the year and quarter start and end.
[startYear, endYear, ...
    startQuarter,endQuarter]    = convertMadToNum(dates(1), dates(end), freq);

% Convert this range into YYYY.NN format. 
dates                           = latttt(startYear, endYear, startQuarter, ...
    endQuarter, 'freq', freq);

end
