function exception = runModelsRecursivelyParFor(bc, savePath, onlyDoLast, realTime, i)
% runModelsRecursivelyParFor    TODO:
%
% Input:
%   bc      [Batchcombination]
% Output
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

try
    
    if onlyDoLast
        % TODO: Explain what doing.
        [~, st, ~]  = regexpi(bc.sample, '(?<=(-|- ))(\d)', 'match', 'start', 'end');
        sample      = [bc.sample(st:end) ' - ' bc.sample(st:end)];
        
    else
        sample      = bc.sample;
    end
    
    % Load the batch file for model i, and update it with the settings for 
    % sample, nsave (draws) and forecasting horizon that is given by the
    % batch combination file
    b       = combinationFns.setBatch(bc.simulationSettings.nsave, sample, bc.forecastSettings.nfor, bc.pathA, bc.selectionA.x{i});
    
    
    % Need to load data here to pass to RecursiceEstimation object. Will be
    % reloaded every time within the recursive estimation as well 
    if realTime
        % Loading data from xls spreadsheet
        endDate     = sample2ttt(sample, b.freq);
        dataPath    = b.dataPath;     
        d           = loadData( dataPath, endDate(end), b.freq, b.selectionY.x);                
    else
        dataPath    = savePath;             
        load([dataPath '/data.mat'],'d');
    end
                
    % Make recursive object and populate with data, batch and settings.
    R                   = RecursiveEstimation;
    R.type              = {'Forecast'};
    R.data              = d;
    R.batch             = b;
    R.saveRecursions    = true;
    R.savePath          = [savePath '/models/' bc.selectionA.x{i} '/results'];
    R.sample            = sample;
    R.saveNames         = combinationFns.quarterlySaveNames(sample, '1');
    R.realTime          = realTime;
    R.dataPath          = dataPath;
    
    % Run the model recursively
    R.runRecursiveEstimation;
    
    exception            = [];
    
    %clear R d b
catch exception1
    msgString = ['Tried to run model %s, but some error occured:-(((.\n',...
        'Continuing to next model\n'];    
    
    exception = MException([mfilename ':run' ], msgString, bc.selectionA.x{i});
    exception = addCause(exception, exception1);    
    return

end
end