function trendAdjData(obj)
% detrendData   - Detrends data
%
% See also DATASETTING, TSDATA.TRENDADJDATA 
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
        
        % get some preliminaries for computation and output    
        [dataPoint, dataDates, ~, ~,...
            dataSimulations, ~] = extractNeededInformation(obj(j));        

        draws               = obj(j).getDraws;
        numberOfForecast    = obj(j).getNfor;
                        
        forecastSimulations  = nan(numberOfForecast, draws);
        
        switch lower(method)
            case {'linear'}
                forecastPoint = detrend(dataPoint, 'linear');                

                for d = 1 : draws
                    y                           = detrend(dataSimulations(:,d), 'linear');                
                    forecastSimulations(:, d)   = y(end - numberOfForecast + 1:end, 1);                
                end
                
            case {'hp'}                
                lamda   = obj(j).dataSettings.setLambdaAs;                
                                
                yy              = hpfilter(dataPoint, lamda);
                forecastPoint   = dataPoint - yy;
                
                for d = 1 : draws
                    yy                          = hpfilter(dataSimulations(:,d), lamda);                    
                    y                           = dataSimulations(:,d) - yy;
                    forecastSimulations(:, d)   = y(end - numberOfForecast + 1:end, 1);                
                end                
                
            case {'tbp'}
                freqNum = convertFreqS(obj(j).freq);
                pl              = 1.5 * freqNum;
                pu              = 8   * freqNum;
                forecastPoint   = bpass(dataPoint, pl, pu);                
                
                for d = 1 : draws
                    y                           = bpass(dataSimulations(:, d), pl, pu);
                    forecastSimulations(:, d)   = y(end - numberOfForecast + 1:end, 1);                
                end                
                
            otherwise
                error([mfilename ':method'],'Program does not recognise method')
        end
        
        forecastDates           = dataDates(end - numberOfForecast + 1:end,1);                                                              
        
        obj(j).ts               = TsdataForecast.setTs(dataDates, forecastPoint);                
        obj(j).tsSimulations    = TsdataForecast.setTs(forecastDates, forecastSimulations);                                       
                
        % Notify change
        notify( obj(j), 'usedMethod', TsdataEventData('detrendData') );        
        
    end    

end

end

