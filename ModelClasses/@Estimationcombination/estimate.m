function obj = estimate(obj, mobj)
% estimate - Estimate function for Estimationcombination class
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

%% TODO: Refactor 
transformedTsdataName = 'E';

obj.estimationState = false;        

%%
tStart = tic;

data            = mobj.data;
batch           = mobj.batch;
showprogress    = mobj.showProgress;

%% 0-1: Pre-estimation stuff

% 0) Extract settings from batch file and apply to Estimation object.
obj                  = obj.extractSettingsFromBatch( batch );

%Temporary variables used below
trainingPeriodSample = batch.trainingPeriodSample;
loadPeriods          = batch.loadPeriods;


%% 1) Get the data from the Tsdata object, and transform it according to the 
% settings in the batch file 
[obj.y, obj.yInfo, ydates] = estimateFns.getFromTsData(obj, data);
                
obj.sample                  = getSample(ydates);
st                          = max(obj.yInfo.minPanel);
en                          = min(obj.yInfo.maxPanel);
obj.estimationDates         = obj.dates(st:en);

if ~isempty(trainingPeriodSample)
    ts                      = sample2ttt(trainingPeriodSample, obj.freq);
    trainingSampleStartIdx  = find(obj.estimationDates == ts(end-1)) - obj.nlag;
    
    if isempty(trainingSampleStartIdx)
        error([mfilename ':settrainingSampleStartIdx'], ...
            'The trainingSampleStartIdx is empty. This is a programming bug.')
    
    else
        obj.trainingSampleStartIdx = trainingSampleStartIdx;
    end
    
else
    obj.trainingSampleStartIdx  = 1;
end

if ~loadPeriods.default
    obj.periods = loadPeriods.x;
    
else
    obj.periods = cellstr(num2str(obj.estimationDates(1+obj.nlag:end)));
end

% 1.1) Send back to batch for final initalization check
checkInitialization(batch, obj);

%% 2) Estimate model

% 2.1) Conrol, load and evaluate models
if showprogress
    fprintf('Combination: Controlling, loading and evalauting models\n')
end
obj.resultCell          = controlAndLoadModels( obj );

% 2.2) Compute weight and scores
if showprogress
    fprintf('Combination: Estimating weights and scores\n')
end

obj.weightsAndScores    = constructScoresAndWeights( obj );

controlOutput(obj, obj.weightsAndScores);

%% Done
obj.tElapsed = toc(tStart);

obj.estimationState = true;        
end
