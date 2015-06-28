function [weights, optResult, isWeightsOk] = getWeights(obj, scoreMethod, nPeriods, ...
    nForecastHorizon, nModels, trainingSampleStartIdxo, optimizeo, nvary, isRollingWindow,...
    scores, constant)
% getWeights     Returns the weights for various scoring methods.
%
% Inputs:
%   obj                         [Estimationcombination]
%   scoreMethod                 [str]                       Scoring method.
%   nPeriods                    [int]
%   nForecastHorizon            [int]
%   nModels                     [int]
%   trainingSampleStartIdxo     [int]
%   optimizeo                   [logical]
%   nvary                       [int]
%   isRollingWindow             [logical]
%   scores                      [double]
%       (nPeriods, nModels, nHorizons, nVblY)
%   constant                    [double]
%
% Outputs:
%   weights
%   optResult
%   isWeightsOk
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


isWeightsOk = false;
cumScore    = 1;
staIdx      = 1;
onesVec     = ones(1, nModels);

switch lower(scoreMethod)
    case {'equal'}
        optResult   = {};
        weights     = repmat( (1/nModels), [nPeriods nModels nForecastHorizon nvary]);
        isWeightsOk = true;
                
    case {'mvnlogscore'}
        optResult   = cell(nPeriods, nForecastHorizon);
        weights     = nan(nPeriods, nModels, nForecastHorizon);
        
        for t = 1 : nPeriods
            if t >= trainingSampleStartIdxo
                
                weightst = nan(nModels, nForecastHorizon);
                for i = 1 : nForecastHorizon
                    if optimizeo
                        optResult{t,i}  = combinationFns.optimalWeights(scores(staIdx:t,:,i));
                        weightst(:,i)   = optResult{t,i}.x1;
                        
                    else
                        cumScore        = exp( sum(constant + scores(staIdx:t,:,i),1) );
                        weightst(:,i)   = cumScore ./ sum( cumScore, 2);
                    end
                    
                    % 1) Check for inf weights, and replace
                    if any( isinf(weightst(:,i)) )
                        weightst( isinf(weightst(:,i) ), i) = 0;
                        warning([mfilename ':isinf'],'The calculated log score weight was INF. This was replaced by 0. The weight for this recursion might not sum to one!')
                    end
                    
                    % 2) Check for all 0 weights (most likely a numerical issue)
                    % Check that not ALL the weights across models for vbl j,
                    % and for forecasting horizon i are identifical to zero, if
                    % so, the constant should be adjusted
                    if all(cumScore == 0)
                        isWeightsOk = false;
                        return
                        
                    else
                        isWeightsOk = true;
                    end
                end
                
                weights(t,:,:) = weightst;
                
                % Add to counter if rolling window
                if isRollingWindow
                    staIdx = stdIdx +1;
                end
            end
        end
                
    otherwise
        optResult   = cell(nPeriods, nForecastHorizon, nvary);
        weights     = nan(nPeriods, nModels, nForecastHorizon, nvary);
        
        for t = 1 : nPeriods
            if t >= trainingSampleStartIdxo
                weightst = nan(nModels, nForecastHorizon, nvary);
                
                for i = 1 : nForecastHorizon
                    for j = 1 : nvary
                        
                        switch lower(scoreMethod)
                            
                            case {'mse', 'crpsd', lower('brierScoreThresholdMap'), ...
                                    lower('cdfEventThresholdMap')}
                                % Use inverse weights
                                numerator       = onesVec ./ ...
                                    mean(scores(staIdx : t, :, i, j), 1);
                                weightst(:, i, j) = numerator ./ sum(numerator,2);                                                                
                                
                            case {'logscored', 'logscore'}
                                if optimizeo
                                    optResult{t,i,j}    = combinationFns.optimalWeights(scores(staIdx:t,:,i,j));
                                    weightst(:,i,j)     = optResult{t,i,j}.x1;
                                    
                                else
                                    cumScore            = exp( sum(constant + scores(staIdx:t, :, i, j), 1) );
                                    weightst(:, i, j)   = cumScore ./ sum( cumScore, 2);
                                end
                                
                                if any(isinf(weightst(:, i, j)))
                                    weightst( isinf(weightst(:,i,j) ), i, j) = 0;
                                    warning([mfilename ':isinf'],'The calculated log score weight was INF. This was replaced by 0. The weight for this recursion might not sum to one!')
                                end
                                
                        end
                    end
                    
                    % Check that not ALL the weights across models for variable
                    % j, and for forecasting horizon i are identifical to zero,
                    % if so, the constant should be adjusted
                    if all(cumScore==0)
                        isWeightsOk = false;
                        return
                        
                    else
                        isWeightsOk = true;
                    end
                end
                weights(t, :, :, :) = weightst;
                
                % Add to counter if rolling window
                if isRollingWindow
                    staIdx = staIdx +1;
                end
                
            end
        end
end
end