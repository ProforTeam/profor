function [varargout] = getPreparedViews( mapObj , variableName, horizon)
% getPreparedViews  -   Contructs a set of prepared tables based on the
%                       results from a Parfor experiment
%
% Input:
%   mapObj          [container.Map]
%       (Vintage, periods, horizon, M1, ..., Mn)
%   variablename    [string]
%   horizon         [integer]
%
% Output:
%   varargout       [variable number of output arguments]
%
% Usage:
%   [varargout] = getPreparedViews( mapObj , variableName, horizon)
%
% Eaxmple:
%   [realTime,M1,M2] = getPreparedViews( WmapObj , 'gdp',1)
%
%   Here the fist input is a container.Map object containing the weights from a
%   Profor experiment (see Notes below). We want to extract the weights used for
%   forecasting gdp at horizon 1. The first varargout will always be a
%   realTime matrix: The diagonal from a "real time matrix" with weights for
%   each model. The second, third etc. output will be a standard "real time
%   matrix": one output variable for each model in the experiment. If the
%   number of models in the experiment is 3, the function call above will
%   give you the results for model 1 and 2 only. If the numbers of models
%   in the experiment is 1, the M2 output argument will be empty.
%
% Notes:
%   The input mapObj can be constructed from the Profor method:
%   [WmapObj, SmapObj] = createResultTables( obj ). That is,  either
%   WmapObj, or SmapObj should be supplied to this function.
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

%% Refactor:
nDeclaredInputArgs = 3;

%% Get the tables from the mapObj
T               = mapObj([variableName '_h' int2str(horizon)]);

%% Get the prepared tables

% 1) Generate real time tables.

% Returns the last element for arbitrary matrx of input variables, such that
% the 'real time' value of the input vbl is returned.
func            = @returnRealTimeVintageResultFromTable;

% Get real time matrix by grouping on Vintage, and returning the last element of
% this with @returnRealTimeVintageResultFromTable.
realTimeTable   = rowfun(func, T,...
    'GroupingVariable',     {'Vintage'}, ...
    'ExtractCellContents',  true, ...
    'OutputVariableNames',  T.Properties.VariableNames(2:end));
realTimeTable.Properties.RowNames   = {};

realTimeTable.Properties.VariableDescriptions{'Vintage'} ...
    = 'The real time vintage the table entries are computed for.';
realTimeTable.Properties.VariableDescriptions{'Periods'} ...
    = ['The time period the table entries are computed for.',...
    ' Note that these are moved one period forward.'];
realTimeTable.Properties.VariableDescriptions{'Horizon'} ....
    = 'Forecasting horizon';

% First putput
varargout{1}    = realTimeTable;

% If more than 1 output arg requested, output full realtime tables for remaing 
% (N-1) models.
if nargout > 1
    
    modelNames      = T.Properties.VariableNames(nDeclaredInputArgs + 1 : end);
    periods         = unique(T.Periods);
    maxperiods      = numel(periods);
    
    % Annonymous fn that returns row with leading zeros if no data available.
    func            = @(y)returnHitoricalResultFromTable(y, maxperiods);
    
    % Convert periods date from YYYY.NN, to VYYYYQNN.
    variableNames   = strrep(periods,'.','Q');
    variableNames   = strcat('V', variableNames);
    
    for i = 1 : numel(modelNames)
        % For each model, for each period return the values at each vintage. 
        C           = rowfun(func, T,...
            'GroupingVariable',     {'Periods'},...
            'InputVariables',       modelNames(i),...
            'OutputVariableNames',  variableNames);
        C.Properties.RowNames = {};
        
        % Create a model name column in a table.
        C1          = table( repmat(modelNames(i), [height(C) 1]), ...
            'VariableNames', {'Model'});
        
        % Append model name column to the table Ç.
        C           = [C1 C];
        
        C.Properties.Description = ['Real time vintages along the x-axis.',...
            ' Time periods along the y-axis.'];
        
        varargout{1+i} = C;
    end
    
    if nargout > numel(varargout)
        varargout = [varargout cell(1,nargout-numel(varargout))];
    end
    
end




