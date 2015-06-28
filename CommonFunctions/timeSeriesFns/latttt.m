function timeVector = latttt(bYear, eYear, bPeriod, ePeriod, varargin)
% latttt -  Make time vector different date formats. To be used for example in 
%           conjucture with timeseries function etc. The default for this fn is 
%           cs date format, but it can also produce matlab date formats
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
%       indicating the format of the output timeVector.
%       Default=cs This is Christie Smith dates. These are numberical date
%       numbers, eg. 2001.01 for Q1 2001, and 2001.200 for day 200 in 2001
%       If MATLAB dates are to be used see MATLAB datestr function
%       for the different otions and format specifications. Both numerical 
%       and string indicators can be used. 
%
% Output: 
%
%   timeVector = string or numerical date vector. Default is cs date vector
%
%
% NOTE: This function is intended to do the same as csttt with two
% extensions: 1) It takes into account years with 366 days when using the
% daily frequency. 2) It can also handle other date formats than the cs
% date format. It calls upon the maTimeVec function to do this. 
%
% Example of use:
%
%    Yearly time vector;
%    bYear=2000;eYear=2009;bPeriod=1;ePeriod=4;freq=1;
%    timeVector=latttt(bYear,eYear,bPeriod,ePeriod,'freq',freq)
%
% See also:
%   convertMadToNum, maTimeVec and csttt
%
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

defaults = {...
    'format',   'cs',   @(x)any(ischar(x) || isnumeric(x)),...
    'freq',     4,      @(x)any(ischar(x) || isnumeric(x))...
    };
  
options = validateInput(defaults,varargin(1:nargin-4));

if ~strcmpi(options.format, 'cs')
    % If format is not cs dates, it must be MATLAB dates. Call on the
    % maTimeVec function to generate a MATLAB date string. 
    timeVector = maTimeVec(bYear, eYear, bPeriod, ePeriod, options);
else
    
    % Convert from possible char to numericals. Needs this below    
    options.freq = convertFreqS(options.freq);

    %% Do computations

    capT = (eYear - bYear + 1)*options.freq;
    year = reshape(repmat((bYear:eYear), [options.freq 1]), capT, 1);
    if options.freq == 1
        period      = zeros([capT 1]);   
        bPeriod     = 1;
        endIndex    = capT;
        div         = 1;
    elseif options.freq == 4
        period      = repmat((1:4)',[capT/options.freq 1]);        
        endIndex    = capT - options.freq + ePeriod;
        div         = 100;
    elseif options.freq == 12
        period      = repmat((1:12)',[capT/options.freq 1]);        
        endIndex    = capT - options.freq + ePeriod;
        div         = 100;
    elseif options.freq == 365   
        % need to do a loop over the calendar function here to get years with
        % 366 days into the date vector. NOTE: This is not done in csttt,
        % and csttt will therefore not be correct if year has 366 days. 
        year    = [];
        period  = [];                  
        for i = bYear : eYear
            counter = 0;
            for ii = 1 : 12
                
                nd = findDaysInMonth(i, ii, 'freq', options.freq);                
                %d=calendar(i,ii);                            
                %nd=sum(sum(d~=0));
                period  = cat(1, period,(1 + counter : nd + counter)');
                year    = cat(1, year, repmat(i, [nd 1]));                
                counter = counter + nd;                
                
            end
            % To be used below to get end period
            if i == eYear
                daysInLastYear = counter;
            end
        end
        % need to update year because of possible 366 day years
        capT        = numel(year);
        endIndex    = capT - daysInLastYear + ePeriod;
        div         = 1000;
        
    elseif options.freq == 262
                
        % need to do a loop over the calendar function here to get years with
        % 366 days into the date vector. NOTE: This is not done in csttt,
        % and csttt will therefore not be correct if year has 366 days. 
        year    = [];
        period  = [];    
        period2 = [];
        for i = bYear : eYear
            counter = 0;
            for ii = 1 : 12                                
                mc      = calendar(i, ii);
                mcb     = mc(:, 2:end-1)';
                mcb     = mcb(:);
                idx     = mcb == 0;
                mcb     = mcb(idx == 0);                
                period  = cat(1, period, mcb + repmat(counter,[numel(mcb) 1]));
                year    = cat(1, year, repmat(i,[numel(mcb) 1]));                                                
                
                counter = counter + numel(mcb);
            end
            
            % find begIndex
            if i == bYear
                %bPeriod=find(bPeriod==cumsum(period));        
                ssIndex = find(bPeriod == period);        
                if isempty(ssIndex) 
                    error([mfilename ':begIndex'], 'Your bperiod did not exist for business frequency.')
                end
                bPeriod = ssIndex(1);
            end
            if i == eYear                
                eendIndex = find(ePeriod == period(end - counter + 1 : end)) + numel(period) - counter;  
                if isempty(eendIndex) 
                    error([mfilename ':endIndex'], 'Your eperiod did not exist for business frequency.')
                else
                    endIndex = eendIndex(end);
                    if endIndex < bPeriod
                        error([mfilename ':endIndex'], 'Your eperiod did not exist for business frequency.')
                    end
                end
            end                
        end
        
        div = 1000;

    end
                                                                                                  
    time = year + period/div;                                
    %time=floor(year)+round(period)./div;                                
    timeVector = time(uint32(bPeriod):uint32(endIndex));
    
end


