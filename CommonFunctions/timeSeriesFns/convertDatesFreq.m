function csDateOut = convertDatesFreq(csDateF, fromFreq, toFreq)
% convertDatesFreq - Convert cs date format time vector from a frequency to a new
% frequency 
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

% ensure that to and from freq input are strings, if numerics convert to
% strings
fromFreq    = convertFreqN(fromFreq);
toFreq      = convertFreqN(toFreq);

if convertFreqS(fromFreq) < convertFreqS(toFreq)
    error([mfilename ':input'],'Function have not been tested on converting from lower to higher freq. Only from higher to lower!')
end;

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
        maTimeVec(floor(csDateF(1)),...
        floor(csDateF(end)),...
        round(rem(csDateF(1),1) * scale.(fromFreq)),...
        round(rem(csDateF(end),1) * scale.(fromFreq)),...
        'freq',fromFreq)...
        );

[bYear, eYear, bPeriod, ePeriod]...
    = convertMadToNum(timeVectorFrom(1), timeVectorFrom(end), toFreq);

csDateOut = latttt(bYear, eYear, bPeriod, ePeriod, 'freq', toFreq);

