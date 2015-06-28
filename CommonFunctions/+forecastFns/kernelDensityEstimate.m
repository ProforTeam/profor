function [y, yWarning] = kernelDensityEstimate(x, xDomain)                        
% kernelDensityEstimate - 
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

    [nfor, nvary, draws] = size(x);
    % generate density forecasts
    if draws < 10
        warning([mfilename ':kernelDensityEstimate'],'Can not produce kernel density estimates. Too few draws')
        y           = [];
        yWarning    = [];
    else                
        % empty density matrix
        xdl     = size(xDomain, 1);                
        y       = nan(nfor, nvary, xdl);
        yWarning = cell(nfor, nvary);
        for h = 1 : nfor
            for k = 1 : nvary
                [y(h,k,:), yWarning{h,k}] = forecastFns.kernelDensity(squeeze(x(h,k,:)), xDomain(:,k));                                            
            end;                        
        end;  
        %forecastFns.reportyWarning(yWarning);                
    end
end        

