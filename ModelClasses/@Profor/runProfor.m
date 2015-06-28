function obj = runProfor( obj )
% runProfor  Run the recursive combination experiment. Will only work if
%            settings in the profor object are ok, i.e., state = true. 
% 
% Inputs:
%   obj         [Profor]      Self.    
%
%
% See also PROFOR
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

tStart              = tic;

obj.estimationState = false;               

% Adjust warning states
obj.original_warningState = Profor.warningControls();

% Define a cleanup function. Will be used below when terminating the function 
% (Matlab automatically calls this also whenever an error occurs
cleanupObj = onCleanup(@()cleanup( obj ));

%% 0) Deside if real time or not
   

% Check that the individual models batch files are ok
if isempty(obj.data)
    obj.realTime    = true;
    d               = [];
else
    % If data object is not empty, use this data set in the analysis.
    % Will be truncated at every iteration (below)
    obj.realTime    = false;        
    % Save data. Load it at each iteration later (below)
    d               = obj.data;    
end

% ...and if not real time, save the data so that it can be loaded at each
% recursion below
if ~obj.realTime
    save(fullfile(obj.savePath,'data.mat'),'d');
end


% 0.1) Load batch file with combo settings and augment if needed: will be b
% in workspace
load(fullfile(obj.pathA,'Combo.mat'));

% Set the periods correctly. This is used when loading and evaluating the
% individual models and running the combination recursively
if b.loadPeriods.default
    b.loadPeriods = combinationFns.quarterlySaveNames(b.sample, '1');
    % save the updated batch file. Will be loaded again in
    % runComboRecusively (see that code for explanation)
    save(fullfile(obj.pathA,'Combo.mat'),'b');
end

% 0.1) Do some extra error checking after controlling for real time or not
x = combinationFns.loadAndControlBatchFiles(b.pathA, b.selectionA, obj.realTime, d);

%% 1) Add counter
fprintf('Starting Profor computations:\n');         
% Total "loop" iterations
%       number of individual models (cell 2) + number of variables (cell 3)
ntot = 0;
if obj.doModels
    fprintf('Estimating %d model(s)\n', b.selectionA.numc);         
    ntot = b.selectionA.numc;
end
if obj.doCombination
    fprintf('Combining forecasts for %d variable(s)\n', b.selectionY.numc);         
    ntot = ntot + b.selectionY.numc;
end

parfor_progress(ntot);

%% 2) Estimate models recursively
if obj.doModels
    [obj.stateModelOverview, obj.errorStack]    = ...
        obj.runModelsRecursively(b, obj.savePath, obj.onlyDoLast, obj.realTime, obj.errorStack);
end
    
%% 3) Do combination recursively    
if isempty(obj.errorStack) && obj.doCombination        
    [obj.stateComboOverview, obj.errorStack]    = ...
        obj.runComboRecursively(b, obj.savePath, obj.onlyDoLast, obj.realTime, obj.errorStack);        
end

%% Done
% 
if isempty(obj.errorStack)
    obj.estimationState = true;               
end

obj.tElapsed        = toc(tStart);

% Clean up
% clear cleanupObj;
% Function automatically calls the clean up cleanupObj object when this
% function is termingated


end
