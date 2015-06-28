function dates = findLongestSample(y)
% findLongestSample - Finds longest sample among y Tsdata objects in y array
%
% Input:
%   y   [Tsdata (1 x nSeries)]
%
% USAGE: dates = Tsdata.findLongestSample(y)
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

% Create a vector with the union of all the dates
dates   = [];
for i = 1 : numel(y)
    dates   = union( dates, y(i).getDates );
end

% generate a new time vector to ensure that there are no holes.
ttt     = latttt( floor(dates(1)), floor(dates(end))+1, 1, 1, 'freq', y(1).freq);

% Find the start and end index for the longest sample.
idx     = find( dates(1)    == ttt);
idxEnd  = find( dates(end)  == ttt);
dates   = ttt( idx : idxEnd );

end
