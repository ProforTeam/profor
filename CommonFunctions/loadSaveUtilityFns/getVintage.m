function vintageNumeric = getVintage(ttt,freq)
% getVintage - Construct a numeric vinatge identifier
%
% Input: 
%   ttt                 [numeric]  
%       A pf numeric date, e.g., 200.01 
%   freq                [string]
%       A string identifying the freqency of ttt
%
% Output:
%   vintageNumeric      [numeric]
%       A numceric value where the year, month and day are stacked together
%       to categorize a vintage
%
% Usage: 
%   vintageNumeric = getVintage(ttt,freq)
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

%% Get the vintage date implied by the frequency and dates (ttt) from input
vintageYear         = floor(ttt);
if strcmpi(freq,'q')
    vintageMonth    = rem(ttt,1)*300;
else
    vintageMonth    = rem(ttt,1)*100;
end
vintageDay          = findDaysInMonth(vintageYear, vintageMonth);

if vintageMonth < 10
    vintageNumeric = str2double([num2str(vintageYear) '0' num2str(vintageMonth)  num2str(vintageDay)]);
else
    vintageNumeric = str2double([num2str(vintageYear) num2str(vintageMonth)  num2str(vintageDay)]);
end;