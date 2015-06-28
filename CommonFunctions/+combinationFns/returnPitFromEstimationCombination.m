function [outPit, outPointForecast, outEmpiricalSimulationForecast]...
           = returnPitFromEstimationCombination( obj, iModel, iForecastHorizon )
% returnPitFromEstimationCombination  - 
%   Returns Probability Integral Transform (PIT) from an EstimationCombination
%   object for the specified model and forecast horizon.
%
% Input:
%   obj                 [Estimationcombination]
%   iModel              [int]                       Selects model.
%   iForecastHorizon    [int]                       Selects forecast horizon.
%
% Output:
%   outPit              [numeric](nEvaluationPeriods x 1)
%   outPointForecast
%   outEmpiricalSimulationForecast
%
% Usage:
%   outPit = returnPitFromEstimationCombination( obj, iModel, ...
%       iForecastHorizon )
%   e.g. returnPitFromEstimationCombination( obj, 1, 1)
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

% Get the number of evaluation periods
nEvaluationPeriods  = numel(obj.periods);

% Initialise the output matrix for the PITs.
outPit                          = zeros(nEvaluationPeriods, 1);
outPointForecast                = zeros(nEvaluationPeriods, 1);
outEmpiricalSimulationForecast  = cell(nEvaluationPeriods, 1);

% At each evalation date extract the requested h-step forecast and evaluate it
% against the outturn available at that point in time.
for ii = 1 : nEvaluationPeriods
    
    % Extract the outturn
    outturn         = obj.resultCell{ii}{iModel}.actual(iForecastHorizon);
    
    % Extract the empirical PDF x-grid, the same at all forecast horizons.
    xGrid           = obj.resultCell{ii}{iModel}.xDomain;
    
    % Extract the empirical PDF for the given forecast horizon.
    pdfXdomain      = squeeze( ...
        obj.resultCell{ii}{iModel}.densities(iForecastHorizon, : , :) );
    
    % Compute the PITs and store.
    outPit(ii, 1)   = combinationFns.computePits(outturn, ...
        'pdfOfxDomain', pdfXdomain, 'xDomain', xGrid);
    
    % Extract the h-step point forecasts and store.
    outPointForecast(ii, 1) ...
        = obj.resultCell{ii}{iModel}.predictions(iForecastHorizon);
   
    outEmpiricalSimulationForecast{ii, 1} ...
        = permute(obj.resultCell{ii}{iModel}.simulations(iForecastHorizon,:,:),[3 1 2]);
    
end

