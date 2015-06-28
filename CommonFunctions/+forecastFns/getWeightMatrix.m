function weightMatrix = getWeightMatrix( estimation )
% getWeightMatrix - Extract and return the weight matrix, replace with equal
%                   weights if scores not computable.
%
% Input:
%   estimation      [Estimation Class]      Typically [EstimationCombination].
%
% Output:
%   weightMatrix    [numeric](nModels x nForcHorizon, nVblsY)
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

warnType        = [mfilename ':getWeightMatrix'];

% Extract the method used to generate the scores and the number of Y variables.
scoringMethod   = estimation.densityScoreSettings.scoringMethods.x{:};
nVblsY          = estimation.namesY.numc;

% Extract the weights and back out the number of evaluation periods
% (nEvaluationPeriods), nModels and the number of forecast horizon periods
% (nForcHorizon), W has dim: (nEvaluationPeriods x nModels x nForcHorizon x nVblsY),
W               = estimation.weightsAndScores.weights;
[nEvaluationPeriods, nModels, nForcHorizon, ~]   ...
    = size(W);

% Check that the number of forecast horizons is equal to that stored in
% estimation.
assert( estimation.nfor == nForcHorizon, 'Weights and forecast horizon incompatible')

% Populate the weights.
if estimation.onlyEvaluation && nModels == 1
    % The weights are one when there is only one model evaluated.
    weightMatrix = ones(1, nModels, nForcHorizon, nVblsY);
    
else
    % Extract the weights and replace non-evaluable scores with equal weights.
    
    % Initialise output weights matrix.
    weightMatrix = nan(1, nModels, nForcHorizon, nVblsY);
    
    % Loop over the forecast horizon and populate weights.
    for i = 1 : nForcHorizon
        % Index gives the last period with evaluable weights. 
        % TODO: clarify dates naming etc.
        % E.g. For the 1-step forecast, i = 1, the only data point without an
        % outturn is the current period, so the last available weight is
        % nEvaluationPeriods - i. 
        idxLastAvailableWeights = nEvaluationPeriods - i;
        
        % Replace with equal weights if scores not computable (insufficient data
        % points for eg), or if trainingSampleStartIdx is set different to
        % default value 1.
        if idxLastAvailableWeights <= 0 || idxLastAvailableWeights <= estimation.trainingSampleStartIdx - 1
            warning(warnType, ['Weight matrix is too short. Replacing ', ...
                'weights with equal weights'])
            weightMatrix(1,:,i,:) = repmat(1/nModels, [1 nModels 1 nVblsY]);
            
        else
            switch lower(scoringMethod)
                case {'mvnlogscore'}
                    weightMatrix(1,:,i,:) = repmat(W(idxLastAvailableWeights, :, i), [1 1 1 nVblsY]);
                    
                otherwise
                    weightMatrix(1, :, i, :) = W(idxLastAvailableWeights, :, i, :);
            end
        end
        
        
        if any( any ( isnan( weightMatrix(1, :, i, :) )))
            error(warnType, 'Weight matrix contain nans. Not allowed')
        end
        
    end
end

end