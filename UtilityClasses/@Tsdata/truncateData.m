function truncateData(obj, endDate, varargin)
% truncateData  Function truncates data object in accordance with input endDate. 
%   These are csDate format numerics. If not matched by dates in object, no 
%   truncation is done
%
% Input:
%
%   endDate     [csDate]    
%   varargin    [string, input]         string followed by input
%       freq        [string]            Default='q'   
%           ('a', 'q', 'm', 'd'): Defines the freqency of the endDate  input.
%       startDate 	[csDate]
%           If provided, function truncates the series to the chosen dates (if
%           possible).
%
% Usage:
%   d.truncateData(endDate, 'freq', 'm')
%   d.truncateData(endDate, 'freq', 'm', 'startDate', 1990.02)
%
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

% Create a function to check whether input x is a valid frequency.
isValidFreq = @(x) any(strcmpi( x, {'a', 'q', 'm', 'd'} ));

defaults    = {...
    'freq',         'q',    isValidFreq, ...
    'startDate',    [],     @isnumeric ...
    };
options     = validateInput( defaults, varargin(1:nargin-2) );

nObj        = numel(obj);
for j = 1 : nObj
    truncStartDate = 0;
    
    % Convert input date frequencies to obj(j).freq if different.
    if ~strcmpi(options.freq, obj(j).freq)        
        truncEndDate    = convertDatesFreq( endDate, options.freq, obj(j).freq);
        if ~isempty(options.startDate)
            truncStartDate  = convertDatesFreq(options.startDate, options.freq, obj(j).freq);
        end
    else        
        truncEndDate    = endDate;
        if ~isempty(options.startDate)
            truncStartDate  = options.startDate;
        end
    end
    
    dates = obj(j).getDates;
    data  = obj(j).getData;
    
    % Find the start and end indicies for the specified truncated dates.
    idxEnd  = find( truncEndDate    == dates );
    idx     = find( truncStartDate  == dates );
    
    % Truncate according to dates specified.
    if ~isempty(idxEnd)
        if ~isempty(options.startDate)
            
            % If truncated start date and end date specified, truncate and
            % notify.
            if ~isempty(idx)                
                dates    = dates( idx : idxEnd );
                data     = data(  idx : idxEnd );
                
                obj(j).ts   = Tsdata.setTs(dates, data);                     
                
                notify(obj(j), 'usedMethod', TsdataEventData('truncateData'));
            else
                msg = ['Tried to truncate data %s, but no matching dates. ',...
                    '(Check frequency of endDate vs. data)'];
                warning([mfilename ':noSampleMatch'], msg, obj(j).mnemonic)
            end
            
        else
            % If only a truncated end date specified, truncate and notify.
            dates        = dates( 1 : idxEnd );
            data         = data(  1 : idxEnd );
                        
            obj(j).ts   = Tsdata.setTs(dates, data);                                 
            
            notify(obj(j), 'usedMethod', TsdataEventData('truncateData'));
        end
        
    else
        msg = ['Tried to truncate data %s, but no matching dates. (Check ', ...
            'frequency of endDate vs. data)'];
        warning([mfilename ':noEndOfSampleMatch'], msg, obj(j).mnemonic)
    end
end

end
