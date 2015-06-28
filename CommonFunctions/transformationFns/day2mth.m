function [x, dateMat] = day2mth(data, csDate, varargin)
% day2mth - Convert daily frequency numbers into monthly numbers
% 
% Input:
% 
%   data = vector (n x 1) of data. Can not contain NAN's. 
%
%   csDate = cs date of the first observation, eg: 1990.010 for
%   january 10th 1990. Need this to know how many days in months. 
%
%   varargin = optional, string followed by arg.
%       method = string, followed by either 'mean' (default), 'endOfPeriod' 
%       or 'sum'. This is the method of transformation
%
%       freq = string, followed by either 'd' (default), or 'b'. 'd' is 
%       used if the data are daily obsrevations, 'b' is used if the 
%       observations are business, eg not weekends. 
%
%       usedates = string, followed by a vector (n x 1) with monthly 
%       csDates. The length of the vector should be the same as the number 
%       of daily observations. E.g. each daily observation has a month 
%       associated with it. This is usefull if the frequency of the data is 
%       not fully daily or business, e.g. if the number of daily 
%       observations in a month is 15 and you still want to transform the 
%       daily obs. into a monthly obs. Default=[].
%
% Output:
%
%   x = vector or matrix with transformed variabels
%
%   dateMat = matrix with year,month and days in month in the columns.
%   Number of rows will equal the number of rows in x. 
% 
% Usage:
%   [x,dateMat]=day2mth(data,1990.01,'method','sum','freq','b')
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

% defaults
defaults = {...
    'method',   'mean', @ischar,...
    'freq',     'd',    @(x)any(ischar(x) || isnumeric(x)),...
    'usedates', [],     @isnumeric...
    };
    
options = validateInput(defaults, varargin(1:nargin-2));

if any(isnan(data))
    error([mfilename ':data'], 'Your data contains nans. This is not allowed')
end


% Preliminaries
% ensure that this is a string
options.freq    = convertFreqN(options.freq);
% make function handle of method
fhandle         = str2func(options.method);
% size of data
nobs            = size(data, 1);
% counter and empty output variable
cnt             = 0;
x               = [];
dateMat         = [];

% two possible algorithms for comp. 
if isempty(options.usedates)
    
    % beginning year, month and day of first monthly observation
    monthlyCsDate   = convertDatesFreq(csDate, options.freq, 'm');    
    year            = floor(monthlyCsDate);   
    month           = round(rem(monthlyCsDate,1)*100);
    days            = round(rem(csDate,1)*1000);
    daysInMonth     = 0;
    for i = 1 : month
        daysInMonth = daysInMonth + findDaysInMonth(year, i, 'freq', options.freq);                
    end
    daysInMonth     = daysInMonth - days + 1;
        
    % find calendar dates for each month in sample and compute the correct
    % convertion. If days in the last month is longer than number if
    % observations, move on the next if statement. 
    while (cnt + daysInMonth) <= nobs
        
        % compute mean, sum or end of period of this data sample
        xx  = feval(fhandle, data(1 + cnt : daysInMonth + cnt, :));
        % Put into growing output variable
        x   = cat(1, x, xx);
        % update date mmatrix
        dateMat = cat(1, dateMat, [year month daysInMonth]);        
        
        % update counter        
        cnt = cnt + daysInMonth;        
        %update year and month
        month = month + 1;
        if month > 12
            month   = 1;
            year    = year + 1;
        end                    
        % find new days in month
        [daysInMonth] = findDaysInMonth(year, month, 'freq', options.freq);            
        
    end;
    % If the last month is not full, the program will now compute the mean, sum 
    % or end of period of the last month.
    if (nobs - cnt) > 0        
        
        xx  = feval(fhandle, data(cnt+1:end, :));
        % Put into growing output variable
        x   = cat(1, x, xx);                                
        dateMat = cat(1, dateMat, [year month (nobs - cnt)]);                        
        
    end
    
else
    
    % The program will use the unique elements of the time vector to find
    % the correct number of observations in each month.
    [~, endIndexOfEachUnique, ~]    = unique(options.usedates);
    r                               = size(endIndexOfEachUnique, 1);
    
    % Loop over index numbers
    for i = 1 : r
        
        xx = feval(fhandle, data(1 + cnt:endIndexOfEachUnique(i), :));
        % Put into growing output variable
        x = cat(1, x, xx);
        
        % put extra stuff into dateMat
        year        = floor(options.usedates(endIndexOfEachUnique(i)));
        month       = round(rem(options.usedates(endIndexOfEachUnique(i)),1)*100);
        daysInMonth = endIndexOfEachUnique(i) - cnt;
        dateMat     = cat(1, dateMat, [year month daysInMonth]);     
        % update cnt
        cnt         = endIndexOfEachUnique(i);        
        
    end   
    
end

