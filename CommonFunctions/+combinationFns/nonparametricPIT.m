function PIT = nonparametricPIT(options, i)
% nonparametricPIT - Returns Probablity Integral Transform (PIT) for a empirical 
%                   PDF with equally spaced intervals. 
%   The CDF is calculated via numerical integration and the PIT returns the
%   value of outturn plugged into this empirical CDF.
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


%% Validate inputs

if isnan( options.actual(i) )
    % THe PIT cannot be evaluated as there is no outturn at associated with
    % this particular forecast.
    PIT = NaN;
    return  
end

%% Calculate PIT.


% Integrate out the pdf at the mid-point of the input pdf - this assumes that
% the grid is equally spaced.
cdfXDensity         = cumsum( options.pdfOfxDomain(:, i) * options.xIncrement );

%% TODO: Refactor this as more than likely a more efficient way to do than
% replicating the outturn into the size of the xDomain.

% Replicate actual into the size of xDomain - to facilitate the calculation of
% squared difference between actual and the xDomain grid.
longActual          = repmat(options.actual(i), [size(options.xDomain, 1) 1]);
diffActAndxDomain   = (options.xDomain - longActual) .^ 2;

% Find the min distance to the the acutal value and choose the CDF at this
% point.
[junk, index]       = min(diffActAndxDomain);
PIT                 = cdfXDensity(index);

end
