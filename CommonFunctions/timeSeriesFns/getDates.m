function [startD, endD] = getDates( sample )
% getDates - Function transfroms the input sample (e.g. '1980.02-2000.01') to
%            numerical values for start date and end data
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


pattern     = '\d+\.\d+(?=-|.+-)';
startD      = str2double(regexpi(sample, pattern, 'match'));

if isempty(startD)
    pattern     = '\d+(?=-|.+-)';
    startD      = str2double(regexpi(sample,pattern,'match'));
end

pattern     = '\d+\.\d+(?<=-|-.+)';
endD        = str2double(regexpi(sample,pattern,'match'));

if isempty(endD)
    pattern     = '\d+(?<=-|-.+)';
    endD        = str2double(regexpi(sample,pattern,'match'));
end