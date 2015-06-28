function [logScore, logScoreWarning] = getLogScore(empiricalForecastPdf,...
                                          density, xDomain, actual, method)
% getLogScore Returns the log-score according to requested method
%   Currently 2 methods implemented:
%   1. ksdensity: Normal kernel approximation.
%   2. normal: Takes mean and standard-deviation of the simulation sample to
%               construct normal approximation.

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

logScoreWarning     = [];

if nargin == 4
    method = 'ksdensity';
end;

if isnan( actual )
    logScore    = nan;
    
else
    
    switch method
    
        case{'ksdensity'}
            % Repeats the target (actual) observation into a vector of the same
            % size as the x_grid, and then finds the closest point to this. This
            % is used to read off directly the PDF value at this particular grid
            % point which comes from the corresponding KDE.
            
            % find the nearest point of the forecast in the xDomain vector
            longActual          = repmat(actual, [numel(xDomain) 1]);

            diffActAndxDomain   = ( xDomain(:) - longActual(:) ) .^ 2;
            [~, Index]          = min( diffActAndxDomain );

            % find the height at the correct realisation
            logScore            = log( density(Index) );
            
        case{'normal'}            
                        
            meanf               = mean(empiricalForecastPdf);
            stdf                = std(empiricalForecastPdf);            
            logScore            = log( normpdf(actual, meanf, stdf) );            
            
    end
    
    if isnan(logScore) || isinf(logScore)
        
        logScoreWarning     = {'weightFunction:war', ...
            'logScore is NaN or Inf. Replaced by 1e-10^5!'};
        
        logScore            = log( 1e-10^5 );
                
    end
end