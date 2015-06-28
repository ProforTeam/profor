function p=approximatemvnPredictiveDensity(nfor,nvar,nforIdx,nvarIdx,actual,predictionsS,mse)
% PURPOSE: Compute predictive likelihood based on normality assumptions
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

draws   = size(predictionsS, 3);
R       = forecastFns.getR(nfor, nvar, nforIdx, nvarIdx);
p       = nan(draws, 1);

nanIdx = isnan(R'.*repmat(actual, [1 size(R, 1)]));
if any(any(R(nanIdx') == 1))
    p = nan;
else
    % Just set nan values to zero. These will not be used anyway
    actual(isnan(actual)) = 0;

    parfor i = 1 : draws        
        mu      = predictionsS(:,:,i)';
        mu      = mu(:);    
        p(i)    = mvnpdf( R*actual, R*mu, R*mse(:,:,i)*R' );            
    end
    
    % approximate the predictive densities with the mean over draws, take logs
    % to get log score
    p = log( mean(p) );        
end;