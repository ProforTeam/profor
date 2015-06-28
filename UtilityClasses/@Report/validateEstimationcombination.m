function validateEstimationcombination( obj )
% validateEstimationcombination - Validates and extracts estimationcombination.
%   Used in the Report Class Constructor.
%
% Inputs:
%   obj                     [Report]

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

% Define error identifier.
errType    = ['Report:', mfilename];

% Check if a EstimationCombination batch file is supplied.
isEstimationcombination     = ...
    exist( fullfile( obj.proforObj.pathA, 'Combo.mat' ), 'file' );

% If there is an EstimationCombination batch file extract the relevant settings
% to restrict user inputs into subsequent methods.
if isEstimationcombination
    
    % Load the batch setup file.
    EstimationCombinationBatch  = load([obj.proforObj.pathA '/Combo.mat'] );
    
    % Extract the allowable threshold values and types.
    obj.EventThreshold.threshold    = ...
        EstimationCombinationBatch.b.brierScoreSettings.eventThresholdValue;
    obj.EventThreshold.type         = ...
        EstimationCombinationBatch.b.brierScoreSettings.eventType.xNonEmpty;
    
    % Extract the number of allowable forecast horizons.
    obj.allowableProperties.nForecastHorizon = ...
        EstimationCombinationBatch.b.forecastSettings.nfor;
    
    % Extract the allowable variable names.
    obj.allowableProperties.vblNames = ...
        EstimationCombinationBatch.b.selectionY.xNonEmpty;
    
    % Store combination model names.
    obj.allowableProperties.modelNames = {'Combo: ', ...
        strjoin( EstimationCombinationBatch.b.selectionA.xNonEmpty, ', ')};
    
end


end