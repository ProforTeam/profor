function [st, en, datesOut, stt, enn] = mapDatesAndSample(sample, dates, freq)
% mapDatesAndSample  -  Finds start and end indexes of a dates vector based
%                       on a sample string.
%
% Input:
%   sample      [string]        cs format (e.g. 2000.01 - 2005.04)
%   dates       [vector](tx1)	cs date format
%   freq        [string]        Frequency of dates (e.g. 'q')
%
% Output:
%   st = scalar, index number for where in the dates vector the sample
%   starts. If datesOut (see below) is not empty, st is an index number for
%   where in datesOut sample starts.
%
%   en = scalar, index number for where in the dates vector the sample
%   ends. If datesOut (see below) is not empty, en is an index number for
%   where in datesOut sample end.
%
%   datesOut = vector (tt x 1). Empty if sample is contained within the
%   dates vector. If sample is not fully contained inside the dates vector,
%   datesOut will not be empty. tt do not have to equal t.
%
%   stt = scalar, if datesOut is empty stt=st. If datesOut is not empty,
%   stt is an index number for where in datesOut dates starts.
%
%   enn = scalar, if datesOut is empty enn=en. If datesOut is not empty,
%   enn is an index number for where in datesOut dates ends.
%
% USAGE: [st,en,datesOut,stt,enn]=Tsdata.mapDatesAndSample(sample,dates,freq)
%
% Note: st and en are indexes between sample and dates/datesOut and stt and
% enn are indexes between dates (the input vector) and dates/datesOut

% REFACTOR: TODO
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

errType         = 'mapDatesAndSample:input';

datesOut        = [];
stt             = [];
enn             = [];

if ~ischar(sample)
    error(errType,'The sample must be a string, e.g. ''1980.02-2000.04''')
end

[startD, endD]  = getDates( sample );

st              = find( dates == startD );
if isempty( st )
    warning(errType, 'The sample start date is not in the loaded data set')
end

en              = find( dates == endD );

%if isempty(en)
%    warning('Tsdata:mapDatesAndSample','The sample end date is not in the loaded data set')
%end

% If any of st or en is empty, construct a new datesOut vector,
% and update the st and en variables
if isempty(st) || isempty(en)

    % Must ensure that it becomes a full time vector!
    datesOut    = unique( [dates; sample2ttt(sample, freq)] );
    datesOut    = latttt( floor(datesOut(1)), floor(datesOut(end)) + 1, 1, 1, ...
        'freq',freq);
    st          = find( datesOut    == startD   );
    en          = find( datesOut    == endD     );
    stt         = find( dates(1)    == datesOut );
    enn         = find( dates(end)  == datesOut );
    %st=find(dates(1)==datesOut);
    %en=find(dates(end)==datesOut);
    
else
    stt         = st;
    enn         = en;
end

end
