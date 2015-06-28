function out = matlabDate2YYYYdotNN( inDate, freq, errType )
% matlabDate2YYYYdotNN - Helper fn to return a unique populated element
%                               from a cell or its previous value.
%   Returns the current format of quarterly dates of 2004.01, 2004.02 etc.
%   YYYY.NN
%
% Input:
%   inDate          [datenum][nx1]
%   freq            [numeric]
%
% Output:
%   outDate         [numeric](YYYY.NN)
%
% Usage: out = matlabDate2YYYYdotNN( inDate, freq, errType )
%   e.g.    inDate = datenum('2004-01', 'YYYY-MM')
%   out = matlabDate2YYYYdotNN( inDate, 4, errType )
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

%% Validation
if nargin < 2 
    error(errType, 'A frequency is required to return the YYYY.NN dates')
end


%% Compute the YYYY.NN date format.

% Takes a the datenum input in inDate and returns the relevant info.
[startYear, endYear, startQuarter, endQuarter] ...
    = convertMadToNum( inDate(1), inDate(end), freq);

% Takes these start and end year and quarters and returns YYYY.NN (nx1) vector
out = latttt(startYear, endYear, startQuarter, endQuarter, 'freq', freq);

end