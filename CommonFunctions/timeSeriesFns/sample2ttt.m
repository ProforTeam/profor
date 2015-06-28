function dates = sample2ttt(sample, freq)
% sample2ttt - Convert a sample string into a time series vector
%
% USAGE: dates=sample2ttt(sample,freq);
%
% Input:
%
%   sample = string, e.g. '2000.01-2003.01'
%
%   freq = string, e.g. 'q'
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

% Convert to number
freq            = convertFreqS(freq);

[startD, endD]  = getDates(sample);

byear           = floor(startD);
eyear           = floor(endD);

if freq == 4 || freq == 12
    bperiod         = rem(startD, 1) * 100;
    eperiod         = rem(endD, 1)   * 100;
    
else
    bperiod         = rem(startD, 1) * 1000;
    eperiod         = rem(endD, 1)   * 1000;
end

dates           = latttt(byear, eyear, bperiod, eperiod, 'freq', freq);