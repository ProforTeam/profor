function [weightsAndScores, forecastObj] = updateWeightAndScores(obj, method, ...
    optimize, isProduceForecast, eventThreshold)
% updateWeightAndScores     Update weights and scores based on requested method
%                           without needing to reload and evaluate all models.
%   Also, get new impliled forecasts for these recalculated weights.
%
% Input:
%   obj                 [Estimationcombination]
%   method              [str]                % One of the scoring methods
%       e.g. (crpsD, logScoreD, mvnlogscore, equal, mse)
%   optimize            [logical]               % TODO: 
%   isProduceForecast   [logical]               % TODO: 
%   eventThreshold      [double]                
%       Requested threshold when needed to select from map object of optiions.
%       Only thresholds specified in
%       Profor.brierScoreProperties.eventThresholdValues will be available. 

%
% Output:
%   weightsAndScores    [structure]
%   forecastObj         [Tsdataforecast]
%
%
% Usage:
%   [weightsAndScores, forecastObj] = updateWeightAndScores(obj, method,...
%                                                   optimize, isProduceForecast)
%       e.g. updateWeightAndScores(obj, 'crpsD', false, false)
%
% Note:
%   No changes will be done to the estimation object itself (only
%   temporarily within the code).
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

%% Validation.

% Initialise isEventThresholdUsed and set as true if an input arg.
isEventThresholdUsed    = false;
if nargin == 5
    isEventThresholdUsed = true;
end   

%% Refactor into separate fn. TODO.

% Initial settings and weightsAndScores. To be used if something goes
% wrong, and to re-set the estimation object
method0             = obj.densityScoreSettings.scoringMethods.x{:};
optimize0           = obj.densityScoreSettings.optimize;
weightsAndScores0   = obj.weightsAndScores;

% Output
weightsAndScores        = [];
forecastObj             = [];

if ~strcmpi(method0, method) || optimize0 ~= optimize || isEventThresholdUsed
    
    % Do this in a try catch block. If error occurs, make sure settings are
    % set back to original, and return empty output
    try
        % Change estimation settings
        obj.densityScoreSettings.optimize            = optimize;
        obj.densityScoreSettings.scoringMethods      = {method};
        
        if isEventThresholdUsed
            obj.weightsAndScores    = constructScoresAndWeights(obj, eventThreshold);
            
        else
            obj.weightsAndScores    = constructScoresAndWeights(obj);
        end
        
        
        if isProduceForecast
            % Get new impliled forecasts for these weights (note, no level
            % supplied, so transformations of the forecasts not possible)
            %[forecastObj, ~]        = forecastingFns.combination(estimation, dataLevel)
            [forecastObj, ~]        = forecastingFns.combination(obj);
        end
        
        % and get the weightsAndScores
        weightsAndScores        = obj.weightsAndScores;
        
        % Reset estimation object
        obj = resetSettings(obj, method0, optimize0, weightsAndScores0);
        
    catch exception1
        
        % Reset estimation object
        obj = resetSettings(obj, method0, optimize0, weightsAndScores0);
        
        msgString = ['Tried to update weights, scores and forecasts, but something went wrong.\n',...
            ' Estimation object is set back to its original state and output is empty'];
        
        exception = MException([mfilename ':constructScoresAndWeights' ], msgString);
        exception = addCause(exception, exception1);
        throw(exception)
        
    end
    
else
    
    warning([mfilename ':noChange'],['No change was done to the wegithsAndScores and forecasts. Supplied inputs were identical to the once already applied\n',...
        ' The output will be empty'])
    
end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = resetSettings(obj, method0, optimize0, weightsAndScores0)

obj.densityScoreSettings.scoringMethods     = {method0};
obj.densityScoreSettings.optimize           = optimize0;
obj.weightsAndScores                        = weightsAndScores0;

end
