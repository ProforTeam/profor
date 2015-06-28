function simLevel = reDoDataTransUtil(simulationSmpl, historyLevel, varargin)
% reDoDataTransUtil - Transform a vector or matrix with transformed data into levels
% based on historical level data. Usefull to convert forecasts into level
% forecasts
%
% Input:
%
%   simulationSmpl = vector or matrix. (n x d), where n is number of
%   periods you want to convert, and d is number of simulations of this
%   number(s) (d can of course be 1). E.g a vector or matrix with forecasts
%   or simulationSmpl.
%
%   historyLevel = vector or matrix with historical values. (t x 1), where
%   t should be at least 13 observations long. The length of the vector
%   depends on the transformations of the simulationSmpl. (If the
%   transformation was QoQ, t could actually be 1, but by always providing
%   a longer vector (e.g. t=13), the function will never fail!) 
%
%   IT IS ASSUMED THAT THE LAST OBSERVATION IN historyLevel IS THE OBSERVATION
%   JUST PRIOR TO THE FIRST OBSERVATION IN simulationSmpl!!!
%
%   varargin = string followed by argument for one or more optional inputs.
%       freq = string, followed by value or string. Defines the frequency
%       of the forecast or simulations sample. That is, either monthly,
%       quarterly etc. (E.g. 'm' or 'q', or 12 or 4). Default=4.
%
%       forecastFreq = numeric. Transformation used on forecasts. E.g if
%       the simulationSmpl is for yoy observations, the input should be
%       9. This is used to make the correct transformations of the final
%       forecasts (used by SAM). Default=3.  
%       
% Output:
%
%   simLevel = vector or matrix. (n x d), where the sizes are the same as
%   in simulationSmpl. Data will be in levels
%
% Usage:
%
%   simLevel=reDoDataTransUtil(simulationSmpl,historyLevel)
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

%% 1) Define some defaults and optional input variables
defaults={...
    'freq',         4,  @(x) (isnumeric(x) || ischar(x)),...
    'forecastFreq', 3,  @isnumeric...
    }; 

options = validateInput(defaults, varargin(1:nargin-2));

% make freq numeric if it is a string
if ischar(options.freq)
    options.freq = convertFreqS(options.freq);
end;           

[numberOfForecast, draws] = size(simulationSmpl);       

% create first level, and then the desired transformation
if any(options.forecastFreq == [8 9 11 12])
    
    simLevel = redoDataTransformation([nan(options.freq, draws);simulationSmpl],...
        repmat(options.forecastFreq, [1 draws]), options.freq, 'X',...
        repmat([historyLevel(end-options.freq+1:end,1);nan(numberOfForecast,1)], [1 draws]));
    
elseif any(options.forecastFreq == [2 3 4 5 6 7])
    
    simLevel = redoDataTransformation([nan(1,draws);simulationSmpl],...
        repmat(options.forecastFreq,[1 draws]), options.freq, 'X',...
        repmat([historyLevel(end-1+1:end,1);nan(numberOfForecast,1)], [1 draws]));
    
elseif any(options.forecastFreq == [10 13])
    
    simLevel = redoDataTransformation([nan(options.freq+1,draws);simulationSmpl],...
        repmat(options.forecastFreq,[1 draws]), options.freq, 'X',...
        repmat([historyLevel(end-options.freq+1+1:end,1);nan(numberOfForecast,1)], [1 draws]));
    
elseif options.forecastFreq == 1
    
    simLevel = exp(simulationSmpl);                    
    
elseif options.forecastFreq == 0
    
    simLevel = simulationSmpl;                                    
    
else
    error([mfilename ':input'], 'The program can not recognise your forecastFreq input')
end

simLevel = simLevel(end - numberOfForecast + 1 : end, :);

