function T = returnTable(tableInfo, varargin)
% returnTable  - Generates table using the ordered input args in varagin with the
%               table settings supplied with tableInfo.
%   NB. Input must be 1-d vectors, breaks with 2-d matricies.
%
% Inputs:
%   tableInfo       [cell][TableSettings](nVaraginx1)
%   vargin
%       Data must all be of same dimensions or a single element that is chosen
%       to be replicated in the table.
%       This is achieved using the properties of table settings:
%       TableSettings
%           colName                 % [string]
%           replicateIntoCol        % [logical]
%           colDescription          % [String]
%           convertToCategorical    % [logical]
%
% Usage:
%   T = returnTable(tableInfo, varargin)
%   e.g.
%   tableInfo = {...,
%       TableSettings('evaluationDate',     false, 'Trial Descrip'), ...
%       TableSettings('Data',               false, ''), ...
%       TableSettings('forecastHorizon',    true,  '',  true) ...
%       };
%
%   out = returnTable(evaluationDate, Data, 1)
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

%% Extract info from input args.
nVarargin       = numel(varargin);

%% Validate inputs.

errType = [mfilename ':'];

% Do some validation on the input args, due to the set up of subsequent table
% creation.
for ii = 1 : nVarargin
    
    % If any of the input arguments are strings - convert to cell arrays of strings
    % as table do not accept strings.
    if ischar(varargin{ii})
        varargin{ii}     = cellstr(varargin{ii});
    end
    
    % Must be row vectors not cols.
    isColVector = size( varargin{ii}, 2 ) > 1;
    isMatrix    = isColVector & size( varargin{ii}, 1 ) > 1;
    
    if isColVector
        if ~isMatrix
            % If not 2-dimensional matrix just transpose input arg.
            varargin{ii}    = varargin{ii}';
            
        else
            error(errType, 'The input args for table are 2-dimensional, only handles 1-d vectors')
        end
    end
end

% Check that table settings exist for all vargin.
assert(nVarargin == numel(tableInfo), errType, ...
    'Number of table info inputs does not match number of input args.');

% Check the all varaibles that are not to be replicated of the same size, and
% return that size.
nRows   = [];
count   = 0;
for ii = 1 : nVarargin
    
    if ~tableInfo{ii}.replicateIntoCol
        count       = count + 1;
        nRowsNew    = size(varargin{ii}, 1);
        
        % Initialise the number of rows
        if count == 1
            nRows   = nRowsNew;
        end
        
        % Check that the number of data points is the same.
        assert(nRows == nRowsNew, 'Data not to be replicated has to be of the same dimension');
    end
end

% If all data a single entry set the nRows to 1.
if count == 0;
    nRows           = 1;
end

% Add cols to the table sequentially according to options in tableInfo.
T = table();
for ii = 1 : nVarargin
    
    % Create table.
    if tableInfo{ii}.replicateIntoCol
        
        if tableInfo{ii}.convertToCategorical
            
            % The class catergorical only accepts cell arrays of strings - thus,
            % convert if str.
            if ischar(varargin{ii})
                varargin{ii}    = cellstr(varargin{ii});
            end
            
            % Replicate the single entry into the table.
            tableCol = table( categorical(repmat(varargin{ii}, [nRows 1])), ...
                'VariableNames', {tableInfo{ii}.colName});
            
        else
            % Insert the data.
            tableCol = table( repmat(varargin{ii}, [nRows 1]), ...
                'VariableNames', {tableInfo{ii}.colName});
        end
        
    else
        if tableInfo{ii}.convertToCategorical
            
            % Input as categorical
            tableCol = table( categorical(varargin{ii}), ...
                'VariableNames', {tableInfo{ii}.colName});
            
        else
            % Insert the data in raw input format.
            tableCol = table(varargin{ii}, ...
                'VariableNames', {tableInfo{ii}.colName});
        end
        
        
    end
    
    % Add variable descrition if requested.
    if ~isempty(tableInfo{ii}.colDescription)
        tableCol.Properties.VariableDescriptions{tableInfo{ii}.colName} = ...
            tableInfo{ii}.colDescription;
    end
    
    % Add the new col of data to the table.
    T = [T, tableCol];
    
end

end