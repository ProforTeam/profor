function [HLN, DM]=harveyLeyborneNewbold_DieboldMariano(S1,S2,h)
% harveyLeyborneNewbold_DieboldMariano - 
%   compute the Harvey, Leybourne and Newbold (1997; IJF) small 
%   sample adjustment of the Diebold and Mariano (1995) test statistic.
%   The DM test statistic is also returned.
% Best regarded as a "rough guide" to significance in nested applications.
% See clarkWestTestStat.m
%
% Inputs are:   s1 = scores for forecasts of the first density f1
%               s2 = scores for forecasts of the second density f2
%
% Output:       HLN and DM test statistics of the test: 
%                   H0: E(S1-S2)=0 vs E(S1-S2) neq 0
%                   Negative values favour S2 > S1, positive that S1 > S2.
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

k=find(~isnan(S1)); %remove NaNs
s1=S1(k);
s2=S2(k);

T=length(s1);
d=s1-s2;
dadj=d-mean(d); %mean correct differences
gamma=zeros(h,1); %gamma(j) = (j-1)th autocorrelation, so that gamma(1) is the correlation.
for k=0:(h-1)
    gamma(k+1)=sum(dadj((1+k):T).*dadj(1:(T-k)))./T; %autocorrelations
end;

DM=mean(d)./sqrt( (gamma(1)+2*sum(gamma(2:h)))/T );
adjust=sqrt( (T+1-2*h+(h*(h-1))/T)/T ); 
HLN=DM*adjust;

end