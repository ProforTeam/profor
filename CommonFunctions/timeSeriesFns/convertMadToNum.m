function [bYear, eYear, bPeriod, ePeriod] = convertMadToNum(fromDate, toDate, freq)
% convertMadToNum - Convert MATLAB dates (either vectors,serial date numbers or 
%                   date str into numbers for bYear etc. using the given freq
%
% Input:
%   fromDate = MATLAB format date, eg either numerical or string
%
%   toDate = MATLAB format date, eg either numerical or string
%   
%   freq = numerical or string defining the frequency you want as output,
%   eg. 1 4 12 365 for year, quarter, month day.
%
% Ouput:
%   bYear = numeric. First year of sample, eg. 2000
%
%   eYear = numeric. Last year of sample, eg. 2009
%
%   bPeriod = numeric. First observation period of sample. Depending on frequency
%   (see below), this can be eg. 1 for quarter one. 
%
%   ePeriod = numeric. Last observation period of sample. Depending on frequency
%   (see below), this can be eg. 1 for quarter one. 
%
% Usage:  
%   [bYear,eYear,bPeriod,ePeriod]=convertMadToNum('03/02/2000','04/04/2001',4)
%   will give bYear=2000, eYear=2001, bPeriod=1, ePeriod=2
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


% Convert to number if string
freq = convertFreqS(freq);

bYear = str2double(datestr(fromDate, 'yyyy'));
eYear = str2double(datestr(toDate, 'yyyy'));    

% get the periods depending on the frequency
if freq == 1 
    bPeriod = 1;
    ePeriod = 1;
elseif freq == 4
    bPeriod = ceil(str2double(datestr(fromDate, 'mm'))/3);
    ePeriod = ceil(str2double(datestr(toDate, 'mm'))/3);                        
elseif freq == 12    
    bPeriod = str2double(datestr(fromDate, 'mm'));
    ePeriod = str2double(datestr(toDate, 'mm'));        
elseif freq == 262
    bPeriod = str2double(datestr(fromDate, 'dd'));
    ePeriod = str2double(datestr(toDate, 'dd'));                
elseif freq == 365
    bPeriod = str2double(datestr(fromDate, 'dd'));
    ePeriod = str2double(datestr(toDate, 'dd'));            
end
