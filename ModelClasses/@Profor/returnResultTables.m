function outTable = returnResultTables( obj, scoreMethod, eventThreshold)
% returnResultTables Generates tables for weights and scores. 
%   
% Input:
%   obj             [Profor]
%   scoreMethod     [cell][str](1xn)        Methods for which results required.
%   eventThreshold  [double]                
%       Requested threshold when needed to select from map object of optiions.
%       Only thresholds specified in
%       Profor.brierScoreProperties.eventThresholdValues will be available. 

%
% Output:
%   outTable
%       Vintage         YYYY.NN_1
%       Periods         YYYY.NN_1
%       Variable        [str]
%       Horizon         [int]
%       ModelName       [str]
%       Method          [str]
%       Weights         [double]
%       Scores          [double]
%
% Usage: outTable = returnResultTables( obj, scoreMethod)
%   e.g. outTable = returnResultTables( obj, {'logScoreD', 'crpsD'})
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

% Initialise isEventThresholdUsed and set as true if an input arg.
isEventThresholdUsed    = false;
if nargin == 3
    isEventThresholdUsed = true;
else
    % Need this for the parfor loop below
    eventThreshold = [];
end    
   
%% Return the result tables

if obj.state
    
    % Load the batchcombination object to extract information on the model 
    % combination stored in the orginal batch file. 
    load([obj.pathA '/Combo.mat']);
    
    periods             = returnPeriodCorrectedForTrainingSample(b);   
    nHorizons           = b.forecastSettings.nfor;
    selectionY          = b.selectionY;
    savePath            = obj.savePath;
    
    nVariables          = selectionY.numc;
    nEvaluationDates    = periods.numc;
    
    outTable            = table();
    for v = 1 : nVariables
        selectionYv = selectionY.x{v};
        parfor p = 1 : nEvaluationDates
            
            % Load the model for given variable and evaluation period.
            m           = Model.loado(fullfile(savePath,'models',['Combination_' ...
                 selectionYv],'results',periods.x{p},'m'));
            
            % Generate weights and score table for teh scoreMethod defined.
            if isEventThresholdUsed
                w   = returnResultTables( m.estimation, nHorizons, ...
                    selectionYv, scoreMethod, eventThreshold);

            else
                w   = returnResultTables( m.estimation, nHorizons, ...
                    selectionYv, scoreMethod);                
            end
            
            % Add rows
            outTable    = [outTable; w];
            
        end
    end
    
        
else
    error([mfilename ':input'],'The state of the Profor object is not ok. Can not make tables');
end

end




