function outTable = getRealTimeTable(obj, vblNames, modelNames, ...
    forecastHorizon, scoreMethod, dataType, realTimeTableType, eventThreshold)
% getRealTimeTable - Returns a real time table where at each vintage the current 
%                   outturns from that data vintage are used to construct the
%                   values of interest (scores, weights etc).
%
% Input:
%   obj                 [Report]
%   vblNames            [str]
%   eventThreshold      [double]
%   modelNames          [cell][str]
%   forecastHorizon     [double]
%   scoreMethod         [str]
%   dataType            [str]       ('weights' or 'scores')
%   realTimeTableType   [str]       ('current' or 'full')
%       Full    - all evaluation periods for every vintage
%       current - only evaluation periods corresponding to that vintage
%
% Usage:
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.getRealTimeTable
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

%% Validation

outTable = {};

if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the getRealTimeTable method for a Report that does not contain a Profor class'])
    return    
        
else

    % Warning / Error identifiers.
    errType = ['Report:', mfilename];

    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'modelNames', 'forecastHorizon', 'scoreMethod', 'dataType', 'realTimeTableType', 'eventThreshold'};               
    numberOfInputArgs   = nargin;

    if numberOfInputArgs == 8 && ~isempty(eventThreshold)
        isThresholdSupplied = true;
    else
        isThresholdSupplied = false;
    end
        
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

scoreMethod     = ifStringConvertToCellstr( scoreMethod );
vblNames        = ifStringConvertToCellstr( vblNames );
modelNames      = ifStringConvertToCellstr( modelNames );
if iscellstr(dataType) 
   dataType = dataType{1}; 
end
if iscellstr(realTimeTableType) 
   realTimeTableType = realTimeTableType{1}; 
end

%% Extract parameters from input args
nModels         = numel( modelNames );
nHorizons       = numel( forecastHorizon );
nVariableNames  = numel( vblNames );

%% 2. Get cdf Threshold tables, prob( X < eventThreshold).
% Name of scoring method to access CDFs of event thresholds.

% Fn to check results table and populate if data not there, either with or
% without event threshold.
if isThresholdSupplied
    requestedScoreMethod    = strcat(scoreMethod(1), '_', num2str(eventThreshold));
    requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');
    obj.populateResultTable( scoreMethod, eventThreshold )
    
else
    requestedScoreMethod    = scoreMethod;
    obj.populateResultTable( scoreMethod )
end

%% After the extraction of the data, return table of data.


outTable            = [];

for hh = 1 : nVariableNames
    

    % Initialise output table
    outTablehh            = table();

    % Find the requested series and plot them.
    count       = 0;
    for ii = 1 : nHorizons

        switch lower( realTimeTableType )
            case 'full'
                % Return the entire matrix of real time weights or scores.
                realTimeTable   = getRealTimeTable(obj.resultTable, vblNames{hh}, forecastHorizon(ii), ...
                    requestedScoreMethod, dataType);

                for jj = 1 : nModels
                    count       = count + 1;

                    % To display an individual model just select the index and it will be displayed.
                    idx         = realTimeTable.Model == modelNames(jj) ;

                    % Print the selected real time table to screen.
                    realTimeTable(idx, :);

                    % Output the real time table requested.
                    outTablehh    = [outTablehh; realTimeTable(idx, :) ];
                end

            case 'current'
                % Return the current weights / scores.
                realTimeTable  = getRealTimeTableDiagonal(obj.resultTable, vblNames{hh}, ...
                    forecastHorizon(ii), requestedScoreMethod, dataType);

                % Output the real time table requested.
                outTablehh    = [outTablehh; realTimeTable ];

            otherwise
                error(errType, 'Unrecognised method %s for table output', realTimeTableType)
        end

    end
    
    outTable = cat(2,outTable,{outTablehh});

    
end

end


