function outTable = getRealTimeDataMatrix( mapObj , variableName)
% getRealTimeDataMatrix  -  Returns the data in real time matrix format (date vs
%                           vintage).
%
% Input:
%   mapObj          [container.Map]     Data for given series in variableName.
%       (Date, Data, Vintage)           and keys are the variableNames, eg.
%       'gdp'.
%   variablename    [string]            
%
% Output:
%   outTable       [Table]
%       In format: (Date, Vintage), with vintage as YYYYQNN
%
% Usage:
%   outTable = getRealTimeDataMatrix( mapObj , variableName)
%
% Eaxmple:
%   outTable = getRealTimeDataMatrix( mapObj , 'gdp')
%
%   Here the fist input is a container.Map object containing the raw data from a
%   Profor experiment. The output will be a standard "real time matrix": one 
%   output variable for each vintage. 
%
% Notes:
%   The input mapObj can be constructed from the Profor method:
%   mapObj = createInputDataTables( obj ). 
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

%% Get the requested table from the mapObj
T               = mapObj(variableName);

%% Get the prepared tables

date            = unique( T.Date );
maxperiods      = numel( date );

% Annonymous fn that returns row with leading zeros if no data available.
func            = @(y)returnHitoricalResultFromTable(y, maxperiods);

% Convert periods date from YYYY.NN, to VYYYYQNN.
dateRowName   = strrep(date,'.','Q');
dateRowName   = strcat('V', dateRowName);

% For each model, for each period return the values at each vintage.
outTable        = rowfun(func, T,...
    'GroupingVariable',     {'Date'},...
    'InputVariables',       'Data',...
    'OutputVariableNames',  dateRowName);
outTable.Properties.RowNames = {};

outTable.Properties.Description = ['Real time vintages along the x-axis.',...
    ' Time periods along the y-axis.'];






