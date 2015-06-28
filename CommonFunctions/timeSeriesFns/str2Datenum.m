function dates = str2Datenum(dates, dateFormat)
% str2Datenum  - Converts str in dateFormat to Matlabs datenum.
%   Loops over the formats for the date in dateFormat until one works, if none
%   do then throws error.
%
% Input:
%   dates           [str]        
%   dateFormat      [cellstr]        e.g. {'yyyy-mm-dd'}
%
% Output:
%   dates           [double]        Matlab's datenum format for dates.
%
% Usage:
%   dates = str2Datenum(dates, dateFormat)
% e.g.
%   dates = str2Datenum('2001-09-23', {'YYYY-MM-DD', 'yyyy.mm.dd'})
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

%% Convert string to datenum.

% Initialise loop parameters
isFailed            = true;
nIter               = 1;

% Convert dates from string format into datenum format by looping over formats in
% dateFormat
while isFailed
    try
        dates       = datenum(dates, dateFormat{nIter});
        isFailed    = false;
        
    catch Me
        nIter       = nIter + 1;
        if nIter > numel(dateFormat)
            throw(Me)
        end
    end
end

end
