function out = extractDataFromMap(obj, resCell, fieldName, eventThreshold, ...
    iForecastHorizon, nForecastHorizons, nPeriods)
% extractDataFromMap  - Extract data from container map objects in resCell.
%
% To extract the data stored in the container maps, a couple of extra stages are 
% needed due to some issues with indexing. (Might be a neater way to do this)
%
% Inputs:
%   obj                 [Estimationcombination]
%   resCell             [cell](nPeriods x nModels)
%   fieldName           [str]
%   eventThreshold      [double]
%   iForecastHorizon    [int]
%   nForecastHorizons   [int]
%   nPeriods            [int]
%
% Outputs:
%   out                 [double]        
%       Array of data for iForecastHorizon at each date in nPeriods, for each 
%       model in nModels.
%
% Usage: 
%   out = extractDataFromMap(obj, resCell, fieldName, eventThreshold, ...
%    iForecastHorizon, nForecastHorizons, nPeriods)
%
% e.g. 
%   out = extractDataFromMap(obj, resCell, 'brierScoreThresholdMap', 1.1, ...
%    1, 4, 2)
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

% Create a fn to extract the map objects stored in fieldName.
extractMapFromCell = @(x) ( cellfun( @(y)( y.(fieldName) ), x, ...
    'uniformoutput', false) );

% Extract the map objects into a temporary vbl.
brierMapObject = cellfun( extractMapFromCell, resCell, 'uniformoutput', false);

% Define the mapKey used to access the map object.
mapKey = num2str( eventThreshold );

% A fn to extract the requested event threshold.
dataForEventThreshold = @(x)cell2mat( ( cellfun( @(y)( y(mapKey) ), x, ...
    'uniformoutput', false) ));

% Extract all the data for the given map object into an array.
arrayOfMapData = cell2mat( cellfun( dataForEventThreshold, brierMapObject, ...
    'uniformoutput', false));

% Maps seem to be a bad idea as nested indexing is not supported - Hence, need 
% an extra fn here to extract the data for the given horizon and date.
idx = iForecastHorizon : nForecastHorizons : nForecastHorizons * nPeriods;

% Store the scores / values for each vbl j, by forecast horizon and model.
out = arrayOfMapData(idx, :);

end