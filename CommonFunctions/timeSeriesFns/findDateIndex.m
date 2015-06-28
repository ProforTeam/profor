function [index, timeVectorNew] = findDateIndex(fdat, fromFreq, tdat, toFreq)
% findDateIndex - Generate new date vector mapping new and old frequencies. Used
% together with the function convertFreqdataStructure to ensure that dates
% map between old and converted freqeuncy
%
% Input:    
%   
%   fdat = vector with cs dates. This should be the time vector with the
%   highest frequency, eg monthly if converting monthly to quarerly data.
%
%   fromFreq = string. Either a, q, m, or d for yearly, quarterly, monthly 
%   or daily data. Freqeucny of original data.   
%
%   tdat = vector with cs dates. This should be the time vector with the
%   lowest frequency, eg quarterly if converting monthly to quarerly data.
%
%   toFreq = string. See fromFreq. Freqeuncy of new/converted data
%
% Ouput:
%   
%   index = structure with fromFreq and toFreq fields. This will be as long
%   as the output time vector, and conatin placeholders indexing the
%   original time vectors intersect with the new time vector
%   
%   timeVectorNew = new time vector in cs date format. 
%
% NOTE: This functino is not efficient. Should re program to make it
% faster!
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

% Convert to strings if numbers have been used
fromFreq    = convertFreqN(fromFreq);
toFreq      = convertFreqN(toFreq);

% Frequency conveters (for cs dates)
%freqNum.q=4;freqNum.m=12;freqNum.a=0;freqNum.d=365;
% Scales
scale.b = 1000;
scale.d = 1000;
scale.m = 100;
scale.q = 100;
scale.a = 1;

% From time
timeVectorFrom = datenum(...
    maTimeVec(floor(fdat(1)),...
        floor(fdat(end)),...
        round(rem(fdat(1),1)*scale.(fromFreq)),...
        round(rem(fdat(end),1)*scale.(fromFreq)),...
        'freq',fromFreq)...
        );
% To time
timeVectorTo = datenum(...
    maTimeVec(floor(tdat(1)),...
        floor(tdat(end)),...
        round(rem(tdat(1),1)*scale.(toFreq)),...
        round(rem(tdat(end),1)*scale.(toFreq)),...
        'freq',toFreq)...
        );
    
% Find first and last observations
st = min([min(timeVectorFrom) min(timeVectorTo)]);
en = max([max(timeVectorFrom) max(timeVectorTo)]);

% New time vector
[bYear, eYear, bPeriod, ePeriod] = convertMadToNum(st, en, toFreq);
timeVectorNew = latttt(bYear, eYear, bPeriod, ePeriod, 'freq', toFreq);

% Get time vectors to find intersects. Change format to get the correct
% intersects depending on the conversion
if (strcmpi(fromFreq,'d') || strcmpi(fromFreq,'b')) && strcmpi(toFreq,'m')
    formatIndex = 12;
elseif (strcmpi(fromFreq,'b') && strcmpi(toFreq,'q')) || (strcmpi(fromFreq,'d') && strcmpi(toFreq,'q')) || (strcmpi(fromFreq,'m') && strcmpi(toFreq,'q'))
    formatIndex = 27;
elseif (strcmpi(fromFreq,'b') && strcmpi(toFreq,'a')) || (strcmpi(fromFreq,'d') && strcmpi(toFreq,'a')) ||  (strcmpi(fromFreq,'m') && strcmpi(toFreq,'a')) || (strcmpi(fromFreq,'q') && strcmpi(toFreq,'a'))
    formatIndex = 10;
else
    error('can not recoqnise format conversion')
end;
      
timeVectorNewS = latttt(bYear, eYear, bPeriod, ePeriod,...
                                'freq', toFreq,...
                                'format', formatIndex);

[~, index.(fromFreq), ~]    = intersect(...
    cellstr(timeVectorNewS),cellstr(latttt(floor(fdat(1)),floor(fdat(end)),...
    round(rem(fdat(1),1)*scale.(fromFreq)),...
    round(rem(fdat(end),1)*scale.(fromFreq)),...
    'freq',fromFreq,'format',formatIndex))...
    );

[~, index.(toFreq), ~]      = intersect(...
    cellstr(timeVectorNewS),cellstr(latttt(floor(tdat(1)),floor(tdat(end)),...
    round(rem(tdat(1),1)*scale.(toFreq)),...
    round(rem(tdat(end),1)*scale.(toFreq)),...
    'freq',toFreq,'format',formatIndex))...
    );
    
index.(fromFreq)    = sort(index.(fromFreq));
index.(toFreq)      = sort(index.(toFreq));


