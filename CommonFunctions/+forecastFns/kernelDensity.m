function [y, yWarning] = kernelDensity(x, xDomain)                            
% Estimate the PDF using a kernel smoother
% (Could be more sophisticated in use of ksdensity, specifying parameters)
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

    yWarning    = [];            
    y           = ksdensity(x,xDomain);                                 
    if min(y) < 0
        error([mfilename ':kernelDensity'], 'Negative values for a pdf are inadmissible.');
    end                        
    if all( y == 0 ) || all( diff(x) < 0.000001 )
        y   = zeros(size(y));
        xdl = size(xDomain,1);
        % Your density is flat, this must be a
        % realization, find realization in xDomain, and
        % put a value of one here
        actual = x(1, 1); % First draw is as good as any

        % find the nearest point of the forecast in the xDomain vector
        longActual          = repmat(actual, [xdl 1]);
        diffActAndxDomain   = (xDomain(:,1) - longActual(:)).^2;
        [~, idx]             = min(diffActAndxDomain);                            
        if isempty(idx) || all( idx == 0 ) 
            error([mfilename ':kernelDensity'],'Flat density, must be observed value, but no match between observation and xDomain');
        end;
        y(idx, 1) = 1;                                                            
    else
        % Check the density estimate
        xDomainIncrement    = xDomain(2,1) - xDomain(1,1);
        yCdf                = cumsum(y)*xDomainIncrement;                                        
        if max(yCdf) > 1.01 || max(yCdf) < 0.99
            yWarning = {[mfilename ':kernelDensity'],'PdfSum exceeds 1 or do not sum to 1'};
            warning(yWarning{1}, yWarning{2})
        end                
    end;        
end
