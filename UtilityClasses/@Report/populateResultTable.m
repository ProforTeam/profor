function populateResultTable( obj, scoreMethod, eventThreshold )
% populateResultTable - Helper fn that checks if results populated for given score
%                       method, if not, insert data to resultTable.
%   The score method with an event threshold is stored as method_d, e.g.
%   cdfEventThresholdMap_1_5, however when populating the table you need to pass
%   the stem component parts, i.e. method = cdfEventThresholdMap, and threshold
%   = 1.5. Hence, the need for scoreMethod and eventThreshold.
%
% Inputs:
%   obj                     [Report]
%   scoreMethod             [str]
%   eventThreshold          [double]

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

%% Validation.

% Define errror identifier. 
errType    = ['Report:', mfilename];

% If an event threshold passed, then construct the composite method name.
if nargin == 2
    requestedScoreMethod    = scoreMethod;
    isThresholdSupplied     = false;
    
elseif nargin == 3
    % The requested score method is stored with its decimal pt replaced with an
    % underscore.
    requestedScoreMethod    = strcat(scoreMethod(1), '_', num2str(eventThreshold));
    requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');
    isThresholdSupplied     = true;
end


%% Check result table, if not already populated, populate.

% Check the contents of the Reports result table and see if already populated.
tableColNames           = obj.resultTable.Properties.VariableNames;
isTablePopulated        = numel(tableColNames) > 0;

% Check to see if prob( X < eventThreshold) is already in the Report result
% tables, if not populate.
if isTablePopulated
    % If the table is populated check that the scoring method has not already
    % been populated into the result table.
    
    methodInTable = ifCategoricalConvertToString( unique(obj.resultTable.Method));
    
    isRequestedMethodInTable = sum( strcmpi( requestedScoreMethod, ...
        methodInTable )) > 0;
    
    if ~isRequestedMethodInTable
        % If the requested method not in the table, populate table.
        if isThresholdSupplied
            obj.resultTable     = obj.proforObj.returnResultTables( scoreMethod, ...
                eventThreshold );
            
        else
            obj.resultTable     = obj.proforObj.returnResultTables( scoreMethod );
            
        end
    end
    
else
    % If no data in result table, populate with requested score method.
    if isThresholdSupplied
        obj.resultTable     = obj.proforObj.returnResultTables( scoreMethod, ...
            eventThreshold );
        
    else
        obj.resultTable     = obj.proforObj.returnResultTables( scoreMethod );
        
    end
end