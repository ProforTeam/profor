function matOut = getHistoricalPredictions(obj)
% PURPOSE: Extract historical predictions and put these into a matrix that
% can be used fore easy plotting etc. 
%
% Output: 
%
% matOut = matrix (nfor+numPeriods x numPeriods x nvary x numModels)
% with forecast and actual ordered "block diagonal". 
% The matOut array can be plotted with directly together with a 
% hairy figure plot to show historical values and forecasts given 
% at different times. 
%
% Usage:
%
% matOut=getHistoricalPredictions(obj)
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

mat = nan(nfor, numModels, nvary, numPeriods);
parfor t = 1 : numPeriods          
    mati = nan(nfor, numModels, nvary);
    for j = 1 : nvary
        mati(:,:, j) = cell2mat(cellfun(@(x)cell2mat((cellfun(@(y)(y.predictions(:,j)),x,'uniformoutput',false))),resCell(t,:),'uniformoutput',false));                                            
    end;
    mat(:,:,:,t) = mati;
end;              
% nfor numPeriods nvary numModels
mat = permute(mat, [1 4 3 2]);

A=ones(numPeriods+nfor,numPeriods);
B=full(logical(spdiags(A,0:-1:-nfor,numPeriods+nfor,numPeriods)));            
matOut=nan(numPeriods+nfor,numPeriods,nvary,numModels);            
parfor i=1:nvary
    for j=1:numModels
        matTmp=nan(numPeriods+nfor,numPeriods);
        matTmp(B)=[obj.y(:,i)';mat(:,:,i,j)];                    
        matOut(:,:,i,j)=matTmp;
    end;
end;
                       
