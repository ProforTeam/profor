function weightsAndScores = constructScoresAndWeights(obj, eventThreshold)
% constructScoresAndWeights     Returns weights and scores used in model
%                               combination.
%   Extracts data from obj.resultCell.
%
% INPUT:
%   obj             [Estimationcombination]
%   eventThreshold  [double]
%       Requested threshold when needed to select from map object of optiions.
%       Only thresholds specified in
%       Profor.brierScoreProperties.eventThresholdValues will be available.
%
% OUTPUT:
%   weightsAndScores    [struct]
%       weights
%       scores(nPeriods, nModels, nforo, nvary)     [resCell]
%           For the given fieldname (scoring method) populate the 1-step scores
%           across the evaluation sample given in obj.periods.
%       optResult
%
% NB. The weights and scores for the final period of the estimation sample take
% NaN as there is no observation for outturn of the 1-step forecast standing at
% this point of time.
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

%% Validation

% % Initialise isEventThresholdUsed and set as true if an input arg.
% isEventThresholdUsed    = false;
% if nargin == 2
%     isEventThresholdUsed = true;
% end

%% Construct the weights and scores.

weightsAndScores = [];
if ~isempty(obj.resultCell)
    
    % just check batch setting again
    % obj.batch.checkBatchSettings;
    
    % To speed up the parfor loop extract common data from object into
    % workspace.
    methodo                 = obj.densityScoreSettings.scoringMethods.x{:};
    resCell                 = obj.resultCell;
    nPeriods                = numel(obj.periods);
    nModels                 = obj.namesA.numc;
    nforo                   = obj.nfor;
    nvary                   = obj.namesY.numc;
    trainingSampleStartIdxo = obj.trainingSampleStartIdx;
    
    %% Extract scores from resCell
    switch lower(methodo)
        case {'mvnlogscore'}
            scores = nan(nPeriods, nModels, nforo);
            parfor i = 1:nforo
                % Seems to extract mvnLogScore from resCell at each horizon.
                a               = cell2mat(cellfun( @(x) cell2mat( ( ...
                    cellfun( @(y)(y.mvnLogScore(i,1)), x, 'uniformoutput', false ) ...
                    ) ), ...
                    resCell, 'uniformoutput', false));
                scores(:,:,i)   = a;
            end
            
        case {'equal'}
            scores = [];
            
        otherwise
            switch lower(methodo)
                case{'mse'}
                    fieldName = 'sqprederror';
                    
                otherwise
                    fieldName = methodo;
            end
            scores = nan(nPeriods, nModels, nforo, nvary);
            
            try
                %
                parfor i = 1 : nforo
                    
                    scorei = nan(nPeriods, nModels, nvary);
                    for j = 1 : nvary
                        
                        % if Brier score, extract differently as not just stored
                        % as the others. Need to access
                        % BrierScore.brierScore('eventThreshold_d_d')
                        
                        switch lower( fieldName )
                            case {  lower('brierScoreThresholdMap'), ...
                                    lower('cdfEventThresholdMap') }
                                
                                % Extract data from container map in resCell for
                                % each forecast horizon, i, at each date in
                                % nPeriods and for each model in nModels.
                                scorei(:, :, j) = extractDataFromMap(obj, resCell, ...
                                    fieldName, eventThreshold, i, nforo, nPeriods);
                                
                            otherwise
                                % Access scores where no event threshold is
                                % used.
                                
                                % Extract data stored in fieldName.
                                extractFieldFromResCell = @(x)cell2mat( ...
                                    ( cellfun( @(y)(y.(fieldName)(i,j)), x, ...
                                    'uniformoutput', false) ));
                                
                                scorei(:, :, j) = cell2mat( ...
                                    cellfun( extractFieldFromResCell, resCell, ...
                                    'uniformoutput', false));
                        end
                        
                    end
                    scores(:,:,i,:) = scorei;
                end
                
            catch Me
                % Sometimes the above routine fails. Do not know why...
                for i = 1 : nforo
                    scorei = nan(nPeriods, nModels, nvary);
                    
                    for j = 1:nvary
                        for t = 1:nPeriods
                            resCellt = resCell{t};
                            
                            for m = 1 : nModels
                                resCellm        = resCellt{m};
                                scorei(t, m, j) = resCellm.(fieldName)(i,j);
                            end
                        end
                    end
                    
                    scores(:, :, i, :) = scorei;
                end
            end
    end
    
    %% Construct weights
    
    constant                    = 0;
    optimizeo                   = obj.densityScoreSettings.optimize;
    isRollingWindow             = obj.isRollingWindow;
    
    isWeightsOk                 = false;
    maxConstantIterations       = 100;
    nIter                       = 0;
    
    % This is done in a while statement to have the possibility to
    % adjust the constant. The constant might need to be different from
    % zero if the numerical weights turn out to be zero for all models!
    while ~isWeightsOk
        
        nIter = nIter + 1;
        
        [weights, optResult, isWeightsOk] = getWeights(obj, methodo, nPeriods, nforo,...
            nModels, trainingSampleStartIdxo, optimizeo, nvary, isRollingWindow, ...
            scores, constant);
        
        if ~ isWeightsOk
            constant = constant + 1;%0.0001;
        end
        
        if nIter == maxConstantIterations
            error([mfilename ':isWeightsOk:iterations'],'Your weights do not seem to be well behaved. Likely caused by by zeros in the weighting matrix and numerical issues')
        end
        
    end
    
    if nIter > 1
        warning([mfilename ':is0'],'The calculated wegiths were all 0, needed to set the constant adjustment to %6.4f to avoid this',constant);
    end
    
    % Populate the output
    weightsAndScores.weights    = weights;
    weightsAndScores.scores     = scores;
    weightsAndScores.optResult  = optResult;
    
end
end

