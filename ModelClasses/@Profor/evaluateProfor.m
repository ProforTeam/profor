function r = evaluateProfor(p)
% evaluateProfor    Evaluatuates the combined forecasts used in a Profor
%                   experiment
%
% Input: 
%
%   p        [Profor]
%            Profor object with state true, i.e., the same Profor object
%            used to run the experiment
%
% Output: 
%
%   r        [Report]
%            report object containing evaluation results for the combined
%            models contained within the original Profor experiement (p)
%
% Usage: 
%
%   r = evaluateProfor(p)
%
% See also REPORT
%
% Note: This function basically constructs a evalaution folder in the
% original pathA folder (the batch file folder) and one evaluation folder
% in the original savePath folder (for the results). Then it copies the
% Combo batch files across, and constructs individual "model" combination batch 
% files as well. Then it runs a new auxiliary Profor experiment, not
% estimating models recursively, but only evaluation. This is somewhat
% inefficient since the combination results have to be generated once
% again, but helpful since we then can use the standard reporting tools.
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

%% 0) Load batch file and copy into new directory with some changes, copy results 
%  for the combination (and variable) into new directory

originalBatchPath   = p.pathA;
% check if the path exist, if not create it 
newBatchPath      = fullfile(originalBatchPath,'evaluation');
checkPath(newBatchPath);

% Load combination batch
load(fullfile(originalBatchPath,'Combo.mat'));

newSelectionA       = b.selectionY.x;

% Change some setting and save it in newBatchPath
b.pathA         = newBatchPath;  % Update pathA
b.selectionA    = newSelectionA;    
b.selectionY    = newSelectionA;
%b.dataSettings  = b.dataSettings.x(vblIdx);
save(fullfile(newBatchPath,'Combo.mat'),'b');

% Save twice, once for the Combo thing, and also for the models. Note the
% adjustements done to the "individual" model batch files
dataSettings = b.dataSettings;
for i = 1:numel(newSelectionA)
     b.selectionA    = newSelectionA(i);    
     b.selectionY    = newSelectionA(i);
     if ~dataSettings.default
         b.dataSettings  = dataSettings.x(i);
     end
     save(fullfile(newBatchPath,[newSelectionA{i} '.mat']),'b');
end
% Copy Combination_<vblName> over to new directory, and remove Combination_
% from the name    
for i = 1:numel(newSelectionA)
    
    oldResultDirectory = fullfile(p.savePath,'models',['Combination_' newSelectionA{i}]);
    newResultDirectory = fullfile(p.savePath,'models','evaluation','models',newSelectionA{i});
    
    status = copyfile(oldResultDirectory, newResultDirectory);
    
    if status ~= 1
        error([mfilename ':copyfiles'],'Could not copy result files across directories')
    end
end

%% 1) Set up a new Profor object, and run it, turn doModels off, since this has 
% already been copied over

pp                  = Profor; 
% Set the directory in which to store the results.
pp.savePath         = fullfile(p.savePath,'models','evaluation');
% Set the directory where the the model setup files reside.
pp.modelSetupPath   = newBatchPath;
pp.doModels         = false;

if ~p.realTime
   pp.data      = p.data; 
end


%% 2) Run new project

pp.runProfor;

if pp.state == 1
    % and return Report output
    r = Report(pp);
else
   error([mfilename ':output','Some unexpected error occured will running the auxiliary Profor experiment for evaluation']) 
end

%% 3) Delete all auxiliary files??
% Can here add commands to delete the evaluation folder that where
% generated during the exe. of this function (but this might mess things up
% in the Report (r) ????

% rmdir(newBatchPath,'s'); 
% rmdir(fullfile(p.savePath,'models','evaluation'),'s'); 


