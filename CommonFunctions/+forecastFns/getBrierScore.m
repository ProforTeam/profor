function [BrierScore, outWarning] = getBrierScore(empiricalForecastPdf, empiricalForecastDomain, ...
    outturn, eventThreshold, eventType, nBins)
% getBrierScore - Evaluated for the event outturn < eventThreshold.
%
% Input:
%   outturn                         The values of the realised actual data
%   empiricalForecastPdf            EmpiricalPdf - specific to problem
%       TODO: have general incorporation of empirical pdf.
%   nBins
%   eventThreshold
%   eventType
%
% Output:
%   BrierScore      [struct]
%       brierScore
%       brierScoreTest
%       resolution
%       reliability
%       uncertainty
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

errType             = [mfilename, ': '];
outWarning     = [];

% If actual data is NaN return score as the same.
if isnan( outturn )
    BrierScore.brierScore     = nan;
    return    
end


%% Validation
% Check that there is a corresponding forecast for each realised data point.
nRows               = size(outturn, 1);
assert( nRows == size(empiricalForecastPdf, 2), errType, 'Forecast and data mismatched')

%% Compute Brier score.

% Create logical values of the observations, where we allow for upper and lower
% tail events.
switch lower( eventType )
    case lower( 'rightHandSide' )
        eventOccured    = outturn >= eventThreshold;                                             
        
    case lower( 'leftHandSide' )
        eventOccured    = outturn < eventThreshold;                                             
        
    otherwise
        error(errType, '%s not recognised as eventType', eventType)
end


% First, extract options in the same format so can use helper fn in
% combinationFns.nonparametricPIT to calculate the probability of the event 
% occuring using the empirical pdf and evaluating the CDF at the event threshold.
options.xIncrement      = abs(empiricalForecastDomain(end) - ...
    empiricalForecastDomain(end - 1));
options.pdfOfxDomain    = empiricalForecastPdf;
options.xDomain         = empiricalForecastDomain;

% Actual / outturn here is the eventThreshold.
options.actual          = eventThreshold;

% Number of outturns / actual is 1 as fn set up. 
nOutturns               = 1;

% Evaluate the empirical CDF at the event threshold.
probForecast    = combinationFns.nonparametricPIT( options, nOutturns);


% Calculate the Brier score without the decomposition.
BrierScore.brierScore ...
    = sum( (eventOccured - probForecast) .^ 2, 1) / size(probForecast, 1);

% Initialise bins and occ
binUnitLocation = 0: 1 / nBins : 1;
Bin(1:nBins)    = struct('bin', 0);
Occ(1:nBins)    = struct('occ', 0);

% Need adjusting for upper tail event ??? Think below is correct as eventOccured has changed
for ii = 1 : nRows
    for jj = 1 : nBins        
        % Select appropriate range accounting for start  period to include the
        % initial values.
        if jj == 1
            isInRange = probForecast(ii) >= binUnitLocation( jj ) & ...
                probForecast(ii) <= binUnitLocation( jj + 1 );
            
        else
            isInRange = probForecast(ii) > binUnitLocation( jj ) & ...
                probForecast(ii) <= binUnitLocation( jj + 1 );
            
        end
                
        if isInRange
            Bin(jj).bin(end + 1, 1)  = probForecast(ii);
            Occ(jj).occ(end + 1, 1)  = eventOccured(ii);
        end
    end
end

occ = sum(eventOccured, 1) / size(eventOccured, 1);

% Initialise occk
Occk(1 : nBins)     = struct('occk', 0);
Pk(1 : nBins)       = struct('pk', 0);

for ii = 1 : nBins
    
    if size(Occ(ii).occ, 1) == 1
        Occk(ii).occk   = 0;
        
    else
        Occk(ii).occk   = sum(Occ(ii).occ, 1) / (size(Occ(ii).occ, 1) - 1);
    end
    
    if size( Bin(ii).bin, 1) == 1
        Pk(ii).pk       = 0;
        
    else
        Pk(ii).pk       = sum( Bin(ii).bin, 1) / (size( Bin(ii).bin, 1) - 1);
    end
    
end

% Initialise structure for results
Results(1 : nBins)     = struct('resolution', 0, 'reliability', 0);

for ii = 1 : nBins    
    Results(ii).resolution      = (size(Occ(ii).occ, 1) - 1)  * (Occk(ii).occk  - occ).^2;
    Results(ii).reliability     = (size(Occ(ii).occ, 1) - 1)  * (Pk(ii).pk  - Occk(ii).occk)^2;    
end

% Calculate components of the Brier score.
uncert      = occ * (1 - occ);
Res         = (1 / size(probForecast, 1)) * sum( [Results(:).resolution] );
Rel         = (1 / size(probForecast, 1)) * sum( [Results(:).reliability] );

bscore_test = uncert + Rel - Res;

%% Select data to pass back.
if isnan( BrierScore.brierScore ) || isinf( BrierScore.brierScore )
    
    outWarning         = {'weightFunction:war', ...
        'Brier Score is NaN or Inf. Replaced by 1e-10^5!'};
    
    BrierScore.brierScore   = log( 1e-10^5 );
    
end

BrierScore.uncertainty              = uncert;
BrierScore.resolution               = Res;
BrierScore.reliability              = Rel;
BrierScore.brierScoreDecomposition  = bscore_test;


end
