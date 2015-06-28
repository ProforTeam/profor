function trendAdjData(obj)
% detrendData   - Detrends data
%
% Usage:
%
%   d.trendAdjData
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

import filterFns.*

numo    = numel(obj);
for j = 1 : numo
    
    if strcmpi( obj(j).dataSettings.doTrendAdj, 'y' )
                               
        
        method  = obj(j).dataSettings.trendAdjMethod.x{:};
        data    = obj(j).getData;
        
        switch lower(method)
            case {'linear'}
                x       = detrend(data, 'linear');
            case {'hp'}                
                lamda   = obj(j).dataSettings.setLambdaAs;                
                yy      = hpfilter(data,lamda);
                x       = data-yy;
            case {'tbp'}
                freqNum = convertFreqS(obj(j).freq);
                pl      = 1.5 * freqNum;
                pu      = 8   * freqNum;
                x       = bpass(data, pl, pu);                
            otherwise
                error([mfilename ':method'],'Program does not recognise method')
        end
        
        obj(j).ts           = Tsdata.setTs(obj(j).getDates, x);        

        % Notify change
        notify( obj(j), 'usedMethod', TsdataEventData('detrendData') );        
        
    end    

end

end

