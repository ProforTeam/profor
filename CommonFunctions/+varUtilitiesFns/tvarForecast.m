function tvarForc = tvarForecast(estY, nlag, nfor, C, T,...
                                    sIdx, decayOpt, cOpt, result, varargin)
% varForecast - Forecast a TVAR 
%
% Output:
%
%   tvarForc = (nvar x nfor) matrix with forecasts   
%
% Usage: 
%
%   varForc = varForecast(estY,alfaC,betaC,nlag,nfor)
%   varForc = varForecast(estY,alfaC,betaC,nlag,nfor,'randomErrors',<>)
%
% See also TVARSIMULATION, TVAREST
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



nvar = size(estY,2);

defaults    = {...
               'bootStrapMethod','br',@(x)any(strcmpi(x,{'non','br','bmb','norm'})),...
                };
options     = validateInput(defaults, varargin);

if strcmpi(options.bootStrapMethod,'non')
    predictionErrors = zeros(nfor, nvar,2);
else
    [predictionErrors_1, ~] = resamplingFns.getRandomShocks(result(1).emat, nfor, options.bootStrapMethod);        
    [predictionErrors_2, ~] = resamplingFns.getRandomShocks(result(2).emat, nfor, options.bootStrapMethod);            

    predictionErrors = cat(3,predictionErrors_1,predictionErrors_2);    
end


tvarForc     = [];
zeroAddOn    = zeros((nlag - 1)*nvar, 1);
% get vector of y1(t),y2(t),y1(t-1),y2(t-1), etc. from the
% original estY matrix! 
tmp = (estY(end : - 1 : end - nlag + 1, :)');            
yy  = tmp(:);

for h = 1:nfor

    ee_1ds = [predictionErrors(h,:,1)';
                zeroAddOn];            
    ee_2ds = [predictionErrors(h,:,2)';
                zeroAddOn];                        

    if yy(sIdx*decayOpt) <= cOpt
        yy = C(:,1,1) + T(:,:,1)*yy + ee_1ds;                                                
    else
        yy = C(:,1,2) + T(:,:,2)*yy + ee_2ds;
    end                                                        
    tvarForc = cat(2, tvarForc, yy(1:nvar, 1));                                

end
