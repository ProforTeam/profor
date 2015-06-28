function [stateComboOverview, errorStack] = runComboRecursively(bc, savePath, ...
    onlyDoLast, realTime, errorStack)
% runComboRecursively
%
% Input:
%   bc              [Batchcombination]
%   savePath
%   onlyDoLast
%   realTime
%   errorStack
%
% Output:
%   stateComboOverview
%   errorStack
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

% Import the correct package
import combinationFns.*

% Loop over variables (need to do this becasue not all models forecast the same
% variable)
nVariables          = bc.selectionY.numc;
variableNames       = bc.selectionY.x;
nModels             = bc.selectionA.numc;
modelNames          = bc.selectionA.x;
pathA               = bc.pathA;
dataSettings        = bc.dataSettings;

stateComboOverview  = false(nModels, nVariables);
errorStackfor       = cell(1, nVariables);

% Only do last vintage for recursive combo, but use whole sample of model forecast in
% this combo
if onlyDoLast
    [~, st, ~]  = regexpi(bc.sample, '(?<=(-|- ))(\d)', 'match', 'start', 'end');
    sample      = [bc.sample(st:end) ' - ' bc.sample(st:end)];
else
    % Adjust the sample once again if isRollingWindow. Need to do
    % this such that the recursive estimation does not go further back than
    % bc.trainingSample ends.
    
    if ~isempty(bc.trainingPeriodSample) %bc.isRollingWindow
        [~, st, ~]  = regexpi(bc.trainingPeriodSample, '(?<=(-|- ))(\d)', 'match', 'start', 'end');
        [~, en, ~]  = regexpi(bc.sample, '(?<=(-|- ))(\d)', 'match', 'start', 'end');
        sample      = [bc.trainingPeriodSample(st:end) ' - ' bc.sample(en:end)];
        
    else
        sample      = bc.sample;
    end
    
end

% Loop over variables because not all models needs to contain all the
% variables. Alternatively we could require that this should be the case,
% but that would make the somewhat restrictive if we have a lot of
% variables and models (e.g., a factor model can forecast many variables, a
% VAR can not)
for i = 1 : nVariables
    
    modelsindx = false(nModels, 1);
    try
        % Find which models that forecast this variable
        for j = 1 : nModels
            % load batch file to check if the variable is in the model
            B = load(fullfile(pathA,[modelNames{j} '.mat']));
            
            if ismember(variableNames{i}, B.b.selectionY.x);
                modelsindx(j) = true;
            end
        end
        
        if all(modelsindx == 0)
            continue
            
        else
            %% Re-load the Batch combo file. Need to do this because it will be
            % adjusted within the Recursiveestimation below (and since we
            % are looping over variables)
            % loads batch file b.
            load(fullfile(pathA,'Combo.mat'));
            
            modelNamesi     = modelNames(modelsindx);
            b.selectionY    = variableNames(i);
            b.selectionA    = modelNamesi;
            
            if ~dataSettings.default
                b.dataSettings  = dataSettings.x(i);
            end
            
            % Change the pathA property to savePath, i.e., the path where
            % the recursively estimated models are stored. In running the
            % models rucersuvely, the pathA refers to the path for the
            % batch files, when loading and evaluating the models, pathA
            % refers to where the model results are stored...
            b.pathA = fullfile(savePath,'models');
            % And trun of showProgress if this is true (will conflict with
            % the parfor loop used in the program (and the waitbar)
            b.simulationSettings.showProgress = false;
            
            if realTime
                % Loading data from file, the last vintage available.
                endDate     = sample2ttt(sample, b.freq);
                dataPath    = b.dataPath;  
                %d       = loadData(b.dataPath, endDate(end), b.freq, [b.selectionY.x b.selectionX.x]);
                d           = loadData( dataPath, endDate(end), b.freq, b.selectionY.x);
                
            else
                dataPath    = savePath;    
                load(fullfile(dataPath,'data.mat'),'d');
            end
            
            % Make recursive object and populate with data, batch and settings.
            R                   = RecursiveEstimation;
            R.type              = {'Forecast'};
            R.sample            = sample;
            R.data              = d;
            R.batch             = b;
            R.saveRecursions    = true;
            R.savePath          = fullfile(savePath,'models',['Combination_' variableNames{i}],'results');
            %R.saveNames=quarterlySaveNames(sample,settings.combinationForecastMonth);
            R.saveNames         = quarterlySaveNames(sample, '1');
            R.realTime          = realTime;
            R.dataPath          = dataPath;            
            
            % Run the model recursively
            R.runRecursiveEstimation;
            
            stateComboOverview(:,i) = modelsindx;
            
            %clear R b
        end
    catch exception1
        
        msgString = ['Tried to run variable %s, but some error occured:-(((.\n',...
            'Continuing to next variable\n'];
        
        exception           = MException([mfilename ':run' ], msgString, variableNames{i});
        exception           = addCause(exception, exception1);
        errorStackfor{i}    = exception;
        
    end
    
    % Add to counter
    parfor_progress;
    
end

% Remove the empty cells
errorStack = [ errorStack, errorStackfor(cellfun( @(x)~isempty(x) , errorStackfor) ) ];
