function [ TotalEconomicLoss ] = ...
    hit( centralForecast, probForecast, realisedData, eventThreshold, eventType )
% hit - 
%
% Inputs:
%   centralForecast:    [double](n,1)       Expected point forecast
%   probForecast:       [double](n,1)       Pr( X < eventThreshold )
%   realisedData:       [double](n,1)       actual / observed data
%   eventThreshold      [double]
%
% Outputs:
%   TotalEconomicsLoss      [struct]
%       (modelNames)
%
% Original: Garratt, Vahey, Wakerly (2011) NAJEF.
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

%% Error Checks
errType     = ['statTestFns:', mfilename];

assert(isequal(size(centralForecast), size(probForecast), ...
    size(realisedData)), 'Input forecasts and data of different dimensions');

nForecastDates       = size(centralForecast, 1);

%%

% Define the loss as 1 such that we can loop over a grid of C between [0, 1].
L			= 1;

% Define the grid over the cost parameter.
gridCIncrement  = 0.04;
gridC           = 0 : gridCIncrement : 1;
nGridC          = numel( gridC );
nContingencies  = 2;
% Initialise output arrays.
totalEconomicLoss     = zeros(nGridC,1);

ContingencyTable(nGridC, 1) = struct('matrix', zeros(nContingencies));

% Loop over the relative economic cost R = C / L, which equivalent to gridC
% calcaulating the economic loss for the latest vintage of data with the 1 step
% forecasts from each out of sample evaluation period.
for ii = 1 : nGridC
    
    
    contingencyTableCentral     = zeros(nContingencies, nContingencies);
    contingencyEconomicLoss     = zeros(nContingencies, nContingencies);
    
    for jj = 1 : nForecastDates
        
        % Calculate coefficients for inflation contingency, i.e. pi lt or gt a
        % given threshold.
        % Here calculate a lower tail event, i.e if inflation < Z issue warning.        
        
        outContingencies  = returnContingencyTable(...
            centralForecast(jj), realisedData(jj), eventThreshold, ...
            eventThreshold, 'BELOW', 'BELOW');
               
        % Update contingency table
        contingencyTableCentral = contingencyTableCentral + outContingencies;
        
        % Optimal rule for inflation warning, issue warning if p_z > R = (gridC(ii) / L)
        if strcmpi( eventType, 'leftHandSide')
            outContingencies     = returnContingencyTable(...
                probForecast(jj), realisedData(jj), gridC(ii), eventThreshold, 'ABOVE', ...
                'BELOW');
            
        elseif strcmpi( eventType, 'rightHandSide')
            outContingencies     = returnContingencyTable(...
                probForecast(jj), realisedData(jj), gridC(ii), eventThreshold, 'ABOVE', ...
                'ABOVE');
            
        else
            error(errType, 'Requested event threshold type "%s" not recogonised', ...
                eventType)
        end
        % Update contingency table:
        contingencyEconomicLoss = contingencyEconomicLoss + outContingencies;
    end
    
    % Store total economic loss.
    totalEconomicLoss(ii)		= L * contingencyEconomicLoss(2, 1) + ...
        gridC(ii) * ( sum( contingencyEconomicLoss(1, :) )  );
    
    % Store the contingency tables as the cost is varied.
    ContingencyTable(ii, 1).matrix  = contingencyEconomicLoss;
    
end

%% Choose what to return - refactor into main code at later date TODO.

TotalEconomicLoss.relativeCost      = gridC;
TotalEconomicLoss.totalEconomicLoss = totalEconomicLoss;
TotalEconomicLoss.ContingencyTable  = ContingencyTable;

end


