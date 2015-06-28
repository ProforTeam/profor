function contingencyTable = returnContingencyTable( inForecast, inData, ...
    actionThreshold, eventThreshold, actionThresholdType, eventThresholdType )
% returnContingencyTable -  Returns matrix of coeficients for use in calc of 
%                           economic loss.
%
% Components used in the calculation of the economic loss. Allows for
% calculation of the loss when inflation is above or below the threshold.
%
% Inputs:
%   inForecast:             (1,1)
%   inData:                 (1,1)
%   actionThreshold:        (1,1) - inflation action threshold
%   eventThreshold:         (1,1) - inflation event threshold
%   actionThresholdType     [str]       (ABOVE, BELOW)
%   eventThresholdType      [str]       (ABOVE, BELOW)
%                                   
% Outputs: Count of inflation event contingencies. n_ij, where i - Action and
%   j - Event. 0 - Yes, 1 - No.
%
%   contingencyTable(1,1)      (Event = Yes,  Action = Yes)
%   contingencyTable(1,2)      (Event = Yes,  Action = No)
%   contingencyTable(2,1)      (Event = No,   Action = Yes)
%   contingencyTable(2,2)      (Event = No,   Action = No)
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

%% ERROR CHECKS.
% Check input args.
assert(nargin == 6, 'Missing input variables');
assert(isequal(size(inForecast), size(inData), size(actionThreshold), ...
    size(eventThreshold)), 'Input arguments have different dimensions')
assert(all(size(inForecast) == [1,1]), 'Input variables are not size (1,1)');

%% MAIN PROGRAM.
% Initialise contingency table.
contingencyTable  = zeros(2, 2);

% Set the conditions for the action and event contingency tables for two cases 
% where the data is above or below the respective thresholds.
switch(upper( eventThresholdType ))
    case 'BELOW'
        % Below event if: inflation < threshold.
        eventOccurs = inData < eventThreshold;
        
    case 'ABOVE'        
        % Above event if: inflation > threshold.
        eventOccurs = inData > eventThreshold;
                
    otherwise
        error('The event threshold type is not recognised')
end

switch(upper( actionThresholdType ))
    case 'BELOW'        
        % Take action if: inflation < threshold
        actionOccurs = inForecast < actionThreshold;
                
    case 'ABOVE'        
        % Take action if: 
        actionOccurs = inForecast > actionThreshold;
                
    otherwise
        error('The action threshold type is not recognised')
end

%% Populate the contingency table.

if actionOccurs
    
    if eventOccurs        
        contingencyTable(1, 1) = contingencyTable(1, 1) + 1;
        
    else        
        contingencyTable(1, 2) = contingencyTable(1, 2) + 1;
    end
    
else
    
    if eventOccurs        
        contingencyTable(2, 1) = contingencyTable(2, 1) + 1;
        
    else        
        contingencyTable(2, 2) = contingencyTable(2, 2) + 1;
    end
    
end

end



