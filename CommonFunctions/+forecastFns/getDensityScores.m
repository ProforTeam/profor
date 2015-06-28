function out = getDensityScores(outturn, empiricalPdf, gridSmothedEmpiricalPdf, ...
    smoothedEmpiricalPdf, brierScoreSettings, densityScoreSettings)
% getDensityScores - Returns scores for the empirical forecast density.
%
% Input:
%   outturn                     [double]
%   empiricalPdf                [double]    Empirical PDF
%   gridSmothedEmpiricalPdf     [double]    Domain of smoothed empirical PDF
%   smoothedEmpiricalPdf        [double]    Smootherd version of the empirical
%                                           PDF
% See Also: EVALUATEFORECAST.
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

errType     = [mfilename, ': '];

if ndims( empiricalPdf ) == 3
    [nForecastDates, nVbls, nDraws] = size( empiricalPdf );
    
else
    error(errType, 'Only implemented with empirical pdf of 3 dimensions')
end


%% Evaluate scores.

% Compute the CRPS score.
out.crpsD    = nan(nForecastDates, nVbls);
for t = 1 : nForecastDates
    for n = 1 : nVbls
        out.crpsD(t, n) = forecastFns.getContinuousRankedProbabilityScore( ...
            squeeze( empiricalPdf(t, n, :) )', ...
            outturn(t, n),...
            densityScoreSettings.crpScoreMethod.x{:}...
            ); % simulations need to be (nn x d) actual (nn x 1)
    end
end


% Compute the log-score.
out.logScoreD        = nan(nForecastDates, nVbls);
out.logScoreWarning  = cell(nForecastDates, nVbls);
for t = 1 : nForecastDates
    for n = 1 : nVbls
        [out.logScoreD(t, n), out.logScoreWarning{t, n}] = ...
            forecastFns.getLogScore( ...
            squeeze( empiricalPdf(t, n ,:) ),...
            squeeze( smoothedEmpiricalPdf(t, n, :) ), ...
            gridSmothedEmpiricalPdf(:, n), ...
            outturn(t, n),...
            densityScoreSettings.logScoreMethod.x{:}...
            );
    end
end


%% Compute the Brier Score.

% TODO - Checks eventThresholdValues make sense.

% Extract parameters used in constructing Brier score.
nBins               = brierScoreSettings.nBins;
eventThresholdValue = brierScoreSettings.eventThresholdValue;
eventType           = brierScoreSettings.eventType;

brierScore                  = nan(nForecastDates,  nVbls);
out.brierScoreWarning       = cell(nForecastDates, nVbls);
out.brierScoreThresholdMap  = containers.Map();

for ii = 1 : numel( eventThresholdValue )
    for t = 1 : nForecastDates
        for n = 1 : nVbls
            
            [BrierScore, out.brierScoreWarning{t, n}] = ...
                forecastFns.getBrierScore( ...
                squeeze( ...
                smoothedEmpiricalPdf(t, n, :) ), ...
                gridSmothedEmpiricalPdf(:, n), ...
                outturn(t, n), ...
                eventThresholdValue(ii), eventType.x{:}, nBins ...
                );
            
            % Store the brier score
            brierScore(t, n)	= BrierScore.brierScore;
            
        end
    end
    
    % Use a map container to point to the appropriate event threshold.    
    out.brierScoreThresholdMap( num2str( eventThresholdValue( ii ) )) ...
        = brierScore;    
end


%%  Store the empirical CDF at the eventThreshold - This is all you need in
% order to compute the contingency tables and resultant Total Economic Loss, and
% relative operating charateristics (ROC).

cdfEventThreshold           = nan(nForecastDates,  nVbls);
out.cdfEventThresholdMap    = containers.Map();

for ii = 1 : numel( eventThresholdValue )
    for t = 1 : nForecastDates
        for n = 1 : nVbls
            % Only works on scalars. 
            cdfEventThreshold(t, n) = ...
                forecastFns.getCdfEventThreshold( ...
                squeeze( ...
                smoothedEmpiricalPdf(t, n, :) ), ...
                gridSmothedEmpiricalPdf(:, n), ...                
                eventThresholdValue( ii ) ...
                );  
            
            if strcmpi( eventType.x{:}, 'rightHandSide')
                cdfEventThreshold(t, n) = 1 - cdfEventThreshold(t, n);
            end            
        end
    end
    
    % Use a map container to point to the appropriate event threshold.    
    out.cdfEventThresholdMap( num2str( eventThresholdValue( ii ) ) ) ...
        = cdfEventThreshold;    
end

end