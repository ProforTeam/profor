function [predictions,actual]=getPredictionsAndActual(obj)
% PURPOSE: Extract historical predictions and actual. Usufull for
% testing differences of forecasts etc. 
%
% Output: 
%
% predictions = matrix (numPeriods x numModels  x nfor x nvary)
% with forecast. 
%
% actual = matrix, equal size as predictions.
%
% Usage:
%
% [predictions,actual]=getPredictionsAndActual(obj)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numPeriods  = numel(obj.periods);
numModels   = obj.namesA.numc;
nfor        = obj.nfor;                                
nvary       = obj.namesY.numc;        
resCell     = obj.resultCell;

[predictions, actual] = deal(nan(numPeriods, numModels, nfor, nvary));  

parfor i = 1 : nfor             
    [predictionsi, actuali] = deal(nan(numPeriods, numModels, nvary));                
    for j = 1 : nvary
        predictionsi(:,:, j)    = cell2mat(cellfun(@(x)cell2mat((cellfun(@(y)(y.predictions(i,j)),x,'uniformoutput',false))),resCell,'uniformoutput',false));                                            
        actuali(:,:, j)         = cell2mat(cellfun(@(x)cell2mat((cellfun(@(y)(y.actual(i,j)),x,'uniformoutput',false))),resCell,'uniformoutput',false));                                            
    end;
    predictions(:,:,i,:)    = predictionsi;
    actual(:,:,i,:)         = actuali;
end                                                 
        