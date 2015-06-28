function ttt = cstttReverse(endDate, capT, freq)
% cstttReverse - Calculate a vector of dates PRIOR TO a single specified 
%               (monthly or quarterly) date, ENDING AT THE SPECIFIED DATE 
% 
%   cstttReverse   Christie Smith       June 2009
%
% INPUTS:     
%	endDate:	Date in form 1980.01 for 1980Q1 or 1980.12 for 1980M12.
%				This will be the LAST date in the vector ttt
%				either 1 or 2 or 3 or 4 (quarterly) 
%				or 1 or 2 or ... or 12 (monthly)
%	capT:		scalar, number of observations
%	freq:		1, 4, 12 or 365 depending on whether annual,
%				quarterly, monthly or daily data
%
% OUTPUTS:     
%	ttt:		Vector: capT by 1. A vector of dates with ttt(capT)=endDate.
%               If quarterly: cstttReverse(1980.01,6,4)=[1978.04, 1979.01,
%               1979.02, 1979,03, 1979,04, 1980.01]'
%               If monthly: cstttReverse(1980.01,6,12)=
%				[1979.08, 197.09, 1979.10, 1979.11, 1979.12,1980.01]'
%				If daily the dates are in Matlabs date format:   
%				cstttReverse(1980.010, 16,365)=[723175,723176,...,723190]'. 
%				And the datestr of this runs from 26-Dec-1979 to 10-Jan-1980.
%

endYear=floor(endDate);
endPeriod=round(rem(endDate,1)*100);

if floor(capT)~=capT
    error('capT should be an integer');
end
if (freq==4)||(freq==12)||(freq==1)||(freq==365)
else
    error('freq in csttt should be 4 or 12: 4=quarterly or 12=monthly')
end
if endPeriod>freq;
	error('endPeriod exceeds frequency.');
end

% Over-estimate number of years, but later select down to correct starting
% point and correct number of elements
numYears=floor(capT/freq)+2;
begYear=endYear-numYears+1;

temp=(begYear:endYear)'*ones(1,freq);
tempSize=size(begYear:endYear,2)*freq;
temp=reshape(temp',tempSize,1);

if freq==4
    %dumTemp=csQDum(size(temp,1),begPeriod);
	dumTemp=repmat(eye(4),numYears,1);
	ttt=temp+dumTemp*(1:freq)'/100;
	ttt=ttt(end-floor(freq-endPeriod)-capT+1:end-floor(freq-endPeriod));
elseif freq==12
    %dumTemp=csMDum(size(temp,1),begPeriod);
	dumTemp=repmat(eye(12),numYears,1);
	ttt=temp+dumTemp*(1:freq)'/100;
	ttt=ttt(end-floor(freq-endPeriod)-capT+1:end-floor(freq-endPeriod));
elseif freq==1
	dumTemp=0;
	endPeriod=1;
	ttt=temp+dumTemp*(1:freq)'/100;
	ttt=ttt(end-floor(freq-endPeriod)-capT+1:end-floor(freq-endPeriod));
elseif freq==365
	endDateMtlb=datenum([floor(endDate), 0, 1000*rem(endDate,1)]);

	ttt=(endDateMtlb:-1:(endDateMtlb-capT+1))';
	ttt=flipud(ttt);
	
% 	ttt=(endDateMtlb:-1:endDateMtlb-capT+1)';
% 	[yyyy jnk jnk]=datevec(ttt);			%#ok<NASGU>
% 	Jan1sDatenum=datenum(yyyy, 1, 1);
% 	dddd=ttt-Jan1sDatenum+1;
% 	ttt=yyyy+dddd/1000;
% 	ttt=flipud(ttt);
end
