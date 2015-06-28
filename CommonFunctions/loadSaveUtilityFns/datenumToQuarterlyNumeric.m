function datesPfFormat = datenumToQuarterlyNumeric(inDate, freq)
% convertXlsDatesToPfDates - Returns a quarterly time series in form YYYY.QQ
%                            where QQ are numeric from 01-04.
%
% Input:
%   inDate              [datenum](nx1)
%   freq                [str]
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

% Validation of input variables.
errType     = 'convertXlsDatesToPfDates: ';

% Validate freq a string
if ~ischar( freq )
    msg = sprintf('The %s must be a string', inputname(2));
    error([errType, msg])
end

% TODO: Validation that inDate of datenum format.

% Extract the year and month of the start and end of the inDate.
% This does not work unless you have the financial toolbox...
startYear           = year(inDate(1));
endYear             = year(inDate(end));
startMonth          = month(inDate(1));
endMonth            = month(inDate(end));

if strcmpi(freq, 'q')
    % For the quarter in numeric form, ie Q1 would be denoted by 01 etc.
    startQuarter     = ceil( startMonth / 3 );
    endQuarter       = ceil( endMonth   / 3 );
    
else
    % Not sure what you're doing here.
    error('Should not arrive here - unwritten code')
    %     startPeriod     = str2double(inDate{1}(4:5));
    %     endPeriod       = str2double(inDate{end}(4:5));
end

datesPfFormat = latttt(startYear, endYear, startQuarter, endQuarter, 'freq', freq);

end
