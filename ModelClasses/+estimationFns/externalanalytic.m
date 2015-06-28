function res = externalanalytic( obj )
% externalanalytic  Populate required fields for the external analytic
%                   forecast.
%   Currently only the adjusted estimation dates are returned.
%
% Input:
%   obj                 [Estimation]
%
% Output:
%   predictionsA        [Tsdataforecast]
%   predictionsY        [Tsdataforecast]
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


% Finding the elements of the time series y for which there are data points.
st                  = max( obj.yInfo.minPanel );
en                  = min( obj.yInfo.maxPanel );            
% y                   = obj.y(st : en, :);

% Set the estimationDates from which, estimationSample is a dependent property.
res.estimationDates = obj.dates(st : en);
