function forcd = density2Simulation(density, nDraws, xDomain)
% PURPOSE: Resample from desnity to generate simulation sample
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

    T                   = length( xDomain );
    xDomainIncrement    = xDomain(2, 1) - xDomain(1, 1);        
    yCdf                = cumsum( density )*xDomainIncrement;                                
    yCdf                = yCdf(:);

    forcd       = nan(nDraws, 1);
    randDraws   = rand(nDraws, 1);

    parfor d = 1: nDraws
        longd           = repmat(randDraws(d), [T 1]);
        diffyCdfAndDraw = (yCdf - longd(:)).^2;
        [~, index]      = min( diffyCdfAndDraw );                                                            
        forcd(d)        = xDomain( index );
    end        

end            