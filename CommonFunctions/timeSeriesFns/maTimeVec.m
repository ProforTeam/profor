function timeVector = maTimeVec(bYear, eYear, bPeriod, ePeriod, varargin)
% maTimeVec - Make time vector using Matlab date formats. To be used for
% example in conjucture with timeseries function etc.
%
% Input:
%   
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
%   varargin = optional. String followed by input value or string. Can be
%   one or more of the following:
%       'freq' = string followed by a numeric value, either 1,4,12 or 365
%       for yearly, quarterly, monthly or daily frequencies respectively.
%       Default=4. Can also be string, but will then be converted in the
%       program, eg. a, q, m, d for yearly, quarterly, monthly or daily
%       frequencies respectively.
%
%       'format' = string followed by either a string or a number
%       indicating the format of the output timeVector (which will be a
%       date string). See MATLAB datestr for the different otions.
%       Default=20 or 'dd/mm/yyyy'
%
% Output: 
%
%   timeVector = string. Time vector using MATLAB dates
%
% Usage: 
%
%    Yearly time vector;
%    bYear=2000;eYear=2009;bPeriod=1;ePeriod=4;freq=1;
%    timeVector=maTimeVec(bYear,eYear,bPeriod,ePeriod,'freq',freq)
% 
%    Quarterly time vector;
%    bYear=2000;eYear=2009;bPeriod=4;ePeriod=4;freq=4;
%    timeVector=maTimeVec(bYear,eYear,bPeriod,ePeriod,'freq',freq)
% 
%    Monthly time vector;
%    bYear=2000;eYear=2009;bPeriod=3;ePeriod=4;freq=12;
%    timeVector=maTimeVec(bYear,eYear,bPeriod,ePeriod,'freq',freq,'format',
%    21)
%
%    Daily time vector;
%    bYear=2009;eYear=2009;bPeriod=300;ePeriod=330;freq=365;
%    timeVector=maTimeVec(bYear,eYear,bPeriod,ePeriod,'freq',freq)
%
% See also:
%   convertMadToNum
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

%% Set defaults

defaults={...
    'format',   'mm/dd/yy', @(x)any(ischar(x) || isnumeric(x)),...
    'freq',     4,          @(x)any(ischar(x) || isnumeric(x))...
    };
  
options = validateInput(defaults, varargin(1:nargin-4));

% Convert to number if string
options.freq = convertFreqS(options.freq);


%% Do computations

capT = (eYear - bYear + 1)*options.freq;
year = reshape(repmat((bYear:eYear), [options.freq 1]), capT, 1);
if options.freq == 1
    month       = ones(capT, 1);
    day         = ones(capT, 1);
    endIndex    = capT;    
    begIndex    = 1;
elseif options.freq == 4
    month       = repmat((3:3:12)', [capT/options.freq 1]);
    day         = repmat([31 30 30 31]', [capT/options.freq 1]);
    endIndex    = capT - options.freq + ePeriod;
    begIndex    = bPeriod;
elseif options.freq == 12
    month       = repmat((1:12)', [capT/options.freq 1]);
    day         = findDaysInMonth(year,month);
    endIndex    = capT - options.freq + ePeriod;
    begIndex    = bPeriod;
elseif options.freq == 365            
    % need to do a loop over the calendar function here to get years with
    % 366 days into the date vector
    year        = [];
    month       = [];
    day         = [];
    daysInLastYear = 0;
    for i = bYear : eYear        
        for ii = 1 : 12
            
            d       = findDaysInMonth(i, ii, 'freq', options.freq);
            day     = cat(1, day, (1:d)');
            year    = cat(1, year, repmat(i,[d 1]));
            month   = cat(1, month, repmat(ii,[d 1]));            
                        
            %d=calendar(i,ii);
            %index=d~=0;            
            %day=cat(1,day,sort(d(index)));
            %year=cat(1,year,repmat(i,[sum(sum(index)) 1]));
            %month=cat(1,month,repmat(ii,[sum(sum(index)) 1]));            
            % To be used below to get end period
            if i == eYear
                daysInLastYear = daysInLastYear + max(max(d));
            end
        end
        
    end;
    % need t update year because of possible 366 day years
    capT        = numel(year);    
    endIndex    = capT - daysInLastYear + ePeriod;
    begIndex    = bPeriod;
elseif options.freq == 262     
    % need to do a loop over the calendar function here to get years with
    % 366 days into the date vector
    year            = [];
    month           = [];
    day             = [];
    daysInLastYear  = 0;
    period          = [];
    for i = bYear : eYear   
        counter2 = 0;
        for ii = 1 : 12
                        
            d   = calendar(i,ii);                            
            dd  = d(:,2:end-1)';
            dd  = dd(:);
            tmp = dd ~= 0;
            D   = dd(tmp);
            Dd  = numel(D);
            
            day     = cat(1, day, D);
            year    = cat(1, year, repmat(i,[Dd 1]));
            month   = cat(1, month, repmat(ii,[Dd 1]));            
            
            nd      = findDaysInWeek(i, ii);                
             
            for iii = 1 : numel(nd)
                
%                 if nd(iii)~=5 && iii==1 && ii~=1
%                     counter2=counter2+(5-nd(iii)+1);
%                 end;                    

                period = cat(1, period, (1 + counter2 : nd(iii) + counter2)');                                                                   
                
                if nd(iii) ~= 5 && iii ~= 1
                    counter2 = counter2 + nd(iii);
                else
                    counter2 = counter2 + nd(iii) + 2; % +2 becasue of the weekends
                end
                
            end
             
            % To be used below to get end period
            if i == eYear
                daysInLastYear = daysInLastYear + numel(D);
            end
        end
        
    end
        
    begIndex    = find(bPeriod == period);        
    endIndex    = find(ePeriod == period);        
    capT        = numel(year);            
    
    if isempty(begIndex) 
        error([mfilename ':begIndex'], 'Your bperiod did not exist for business frequency.')
    else
        begIndex = begIndex(1);
    end
    if isempty(endIndex) 
        error([mfilename ':endIndex'], 'Your eperiod did not exist for business frequency.')
    else
        endIndex = endIndex(end);
        if endIndex < bPeriod
            error([mfilename ':endIndex'], 'Your eperiod did not exist for business frequency.')
        end
    end       
    
end
    
% not implemented for functino yet, but can easily be added (as varargin for example)    
[hour, minute, second] = deal(zeros(capT, 1));

% adjust for starting and ending periods
time    = [year, month, day, hour, minute, second];
adjTime = time(begIndex:endIndex, :);

% make final timeVector in Matlab format
timeVector = datestr(datenum(adjTime), options.format);








