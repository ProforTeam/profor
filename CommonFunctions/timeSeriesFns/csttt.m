function ttt = csttt(begYear, begPeriod, capT, freq)
% csttt - Calculate a string of quarterly or monthly dates
% 
%   csttt   Christie Smith       May 2008
%
%   INPUTS:     begYear: year in which to start
%               begPeriod: period in which to start: either 1 or 2or 3 or 4 
%                          or 1 or 2 or ... or 12
%               capT: scalar, number of observations
%               freq: 4 or 12 or 365 depending on whether quarterly,monthly
%               or daily data
%
%   OUTPUT:     ttt:
%               If quarterly: 1980.01, 1980.02, 1980.03, 1980.04, 1981.01...
%               If monthly: 1980.01, 1980.02, 1980.03, 1980.04, 1980.05,...
%
%
% Corrected 13 October 2008
%
  
if floor(capT) ~= capT
    error([mfilename ':input'], 'capT should be an integer');
end
if floor(begYear) ~= begYear
    error([mfilename ':input'], 'begYear should be an integer');
end
%if (freq==4)||(freq==12)||(freq==365)
%else
%    error('freq in csttt should be 4, 12, 365: 4=quarterly or 12=monthly or 365=daily')
%end
if begPeriod > freq;
	warning([mfilename ':input'], 'begPeriod exceeds freq. Starting year will be later than begYear');
end

%begYear=int16(begYear);
%begPeriod=int16(begPeriod);
%capT=int16(capT);
%freq=int16(freq);

% overestimate of number of years, but later select down to correct starting
% point and correct number of elements
numYears    = floor(capT/freq) + 2;
endYear     = begYear + numYears - 1;

temp        = (begYear:endYear)'*ones(1, freq);
tempSize    = size(begYear:endYear, 2)*freq;
temp        = reshape(temp', tempSize, 1);

if freq == 1
    dumTemp = repmat(eye(1), numYears, 1);
elseif freq == 4
    %dumTemp=csQDum(size(temp,1),begPeriod);
	dumTemp = repmat(eye(4), numYears, 1);
elseif freq == 12
    %dumTemp=csMDum(size(temp,1),begPeriod);
	dumTemp = repmat(eye(12), numYears, 1);
elseif freq == 365
    %dumTemp=csMDum(size(temp,1),begPeriod);
	dumTemp = repmat(eye(365), numYears, 1);
end
if freq == 365
    ttt = temp + dumTemp*(1:freq)'/1000;
elseif freq == 1
    ttt = (begYear:begYear + capT)';
    % hardcoding begPeriod, to avoid errors
    begPeriod = 1;
else
    ttt = temp + dumTemp*(1:freq)'/100;
end

ttt = ttt(uint32(begPeriod):uint32(capT + begPeriod - 1));

