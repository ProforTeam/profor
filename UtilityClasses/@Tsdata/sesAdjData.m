function sesAdjData(obj)
% sesAdjData    - Seasonally adjusts data using the X12Arima procedure. 
%   Default seasonal procedure is applied.
%
% Input:
%   obj         [Tsdata]
%
% Usage:
%
%   d.sesAdjData   
%
% Note: 
%   Function uses information in the obj.dataSettings property
%
% See also DATASETTING
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

import x12arima.*

nObj                = numel( obj );
for j = 1 : nObj
    if strcmpi( obj(j).dataSettings.doSesAdj, 'y' )
        
        if strcmpi( obj(j).freq, 'a' ) || strcmpi( obj(j).freq, 'd' )
            warning([mfilename ':frequency'],'Do not perform x12 on yearly or daily data')
            continue
        end
        
        % Seasonal adjust data using matlab version of x12arima program (add
        % frequency to options for each loop over frequency
        options.freq        = obj(j).freq;
        options.meth        = obj(j).dataSettings.sesAdjMethod.x{:};
        sesAdjustedData     = nbX12arima( obj(j).getData, options );
                
        obj(j).ts           = Tsdata.setTs(obj(j).getDates, sesAdjustedData.sesadj{1});        
       
        % Notify change
        notify(obj(j), 'usedMethod', TsdataEventData('sesAdjData'));
    end
end

end

