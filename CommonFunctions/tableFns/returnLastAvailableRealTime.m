function  varargout = returnLastAvailableRealTime(inArg, forecastHorizon)
% returnLastAvailableRealTime 
%   Helper fn that returns last available element available in real time. Now
%   works from data, simply returns last available element that isn't NaN.
% TODO: Rename function and check usage. 
%
% Input: 
%   inArg              
%   forecastHorizon
%
% Output:
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

% Find if there are any elementst that are not NaN
idx = ~isnan(inArg);
isDataAvail = sum( idx ) > 0;

% If there are any elements that are not NaN then select the last element,
% otherwise just return the NaN.
if isDataAvail
    outPit = inArg(idx, 1);
    outPit = outPit(end, 1);
else
    outPit = inArg(end, 1);
end

varargout   = num2cell( outPit  );

