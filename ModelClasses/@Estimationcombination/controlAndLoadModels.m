function resCell = controlAndLoadModels( obj )
% controlAndLoadModels  Control, load and evaluate models to be used for
%                       combination
% 
% Input: 
%   obj     [EstimationCombination]
%
% Output: TODO
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

% Loop over saved models and load results into cell across time and models. Get
% some variables to avoid sending obj through parfor loop
modelNames      = obj.namesA.x;
nModels         = obj.namesA.numc;
modelPath       = obj.pathA;

periods         = obj.periods;
nPeriods        = numel(periods);

varNames        = obj.namesY.x;

% TODO: Taking observations in this form why? Explain the padding somewhere.
actual              = obj.y(1 + obj.nlag : end, :);   
forecastDates       = obj.dates(1 + obj.nlag : end, :);
transformation      = obj.yInfo.transf;

nfor                    = obj.nfor;
freq                    = obj.freq;
scoringMethod           = obj.densityScoreSettings.scoringMethods.x{:};
brierScoreSettings      = obj.brierScoreSettings;
densityScoreSettings    = obj.densityScoreSettings;

draws           = obj.simulationSettings.nsave;
showProgress    = obj.simulationSettings.showProgress;

controlModels   = obj.controlModels;

% Need to do this here because need some of the output above (i.e. ideally 
% should have been done during checkBatch and data in Model etc.)
if controlModels
    if showProgress
        fprintf('Combination: Controlling all models\n');
        parfor_progress(nPeriods);
    end

    % Check that all the models have the required input for the evaluation period
    % parfor
    parfor t = 1 : nPeriods
        forecastDatesti = forecastDates(t : t + nfor - 1);

        for i = 1 : nModels
            combinationFns.controlModel(modelPath, modelNames{i}, periods{t}, ...
                forecastDatesti, varNames, freq, nfor, transformation, draws, ...
                scoringMethod);
        end

        if showProgress
            parfor_progress;
        end

    end

    if showProgress
        parfor_progress(0);
    end
    
end

% Empty output
resCell     = cell(nPeriods, 1);
if showProgress
    fprintf('Combination: Loading and evaluating models\n');
    parfor_progress(nPeriods);
end

% Populate results.
%parfor
parfor t = 1 : nPeriods
    actualti        = actual(t : t + nfor - 1, :);
    forecastDatesti = forecastDates(t : t + nfor - 1);
    
    res             = cell(1, nModels);
    
    for i = 1 : nModels
        res{1,i} = combinationFns.evaluateModel(modelPath, modelNames{i}, ...
            periods{t}, actualti, forecastDatesti, varNames, transformation, ...
            brierScoreSettings, densityScoreSettings);
    end
    
    resCell{t}      = res;
    
    if showProgress
        parfor_progress;
    end
end

if showProgress
    parfor_progress(0);
end