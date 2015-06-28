function W = getDateVintageTable( estimationObj )
% getDateVintageTable   Returns table with data aligned by date and data point.
%   Helper fn that adjust the data to the correct timing, the data contained in
%   y is padded with nForecastHorizon + 1 trailing NaNs, which are removed, the
%   dates are then matched from estimationDates.
%
% NB. estimationObj.dates and estimationObj.y dates and data align, so can use
% this to extract the date of observation.
% 
% Input: 
%   estimationObj       [Estimationcombination]
% 
% Output: 
%   W           [Table]
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

errType         = [mfilename, ': ' ];

% Extract periods
periods         = estimationObj.periods;
nObservations   = numel( periods );

% Extract variable name.
vblName         = estimationObj.namesY.xNonEmpty;

% Check individual series being extracted.
assert( numel( vblName ) == 1, errType, 'Fn set up to handle 1 vbl at a time' );

% Extract the data, it comes with trailing NaNs.
y               = estimationObj.y;
% Remove trailing NaNs.
idxObs          = ~isnan(y);
y               = y( idxObs );
% Select the elements for the real time matrix.
y               = y(end - nObservations + 1: end, 1);


%% Select the corresponding dates the raw data was observed.
observationDate = estimationObj.dates;
observationDate = observationDate( idxObs );
observationDate = observationDate(end - nObservations + 1: end, 1);

%% Convert periods date from YYYY.NN, to VYYYYQNN.
vintageName     = strrep(periods(end),'.','Q');
vintageName     = strcat('V', vintageName);

% Generate vintage name of same dimensions as the dates / data combo.
vintageName     = repmat(vintageName, [numel(periods) 1]);

% Set table input settings.
tableInfo = {...,
    TableSettings('Date',           false, ['The time period the table ', ...
    'entries are computed for. NB these are moved one period forward.']), ...    
    TableSettings('Vintage',        false, ['Real time vintage the table entries',...
    ' are computed for.'],  true),...
    TableSettings('VariableName',   true, 'Variable Name',  true), ...
    TableSettings('Data',           false, 'Real time data.')
    };

% Create a table with the dates and data. 
W               = returnTable( tableInfo, observationDate, vintageName, vblName, y );

end