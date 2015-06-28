function [stateModelOverview, errorStack] = runModelsRecursively(bc, savePath, onlyDoLast, realTime, errorStack)
% runModelsRecursively  TODO:
%
% Input:
%   b               [Class Batchcombination]
%   savePath        [string]
%   data            [empty/Tsdata class]
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

numModels           = bc.selectionA.numc;
errorStackparfor    = cell(numModels, 1);
stateModelOverview  = false(numModels, 1);
% parfor
parfor i = 1 : numModels
    
    % Need function here so that I can call import inside that function
    % (matlab thing)
    errorStackparfor{i} = Profor.runModelsRecursivelyParFor(bc, savePath, onlyDoLast, realTime, i);
    if isempty(errorStackparfor{i})
        stateModelOverview(i) = true;
    end
    
    % Add to counter
    parfor_progress;
    
end

% Remove the empty cells
errorStack = [errorStack, errorStackparfor(cellfun( @(x)~isempty(x) , errorStackparfor) ) ];

end


