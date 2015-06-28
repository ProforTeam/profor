classdef Forecasting < handle
% Forecasting -  
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
    
    properties(SetAccess=protected,Hidden)
        dataSettings
        forecastingState = false;
    end
    
    properties(SetAccess=protected)
        method
        
        predictionsA
        predictionsY
        
        tElapsed  %Total time used to forecast
    end
    
    methods
        function obj = Forecasting(  )
            % Forecast  Class constructor.
            
        end
                
        %% General methods
        obj = forecast(obj, modelObj)                
        
    end
end