function x = getHorizons( obj )
% getHorizons
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

x = [];
if ~isempty(obj.resultCell)
    resCell     = obj.resultCell;
    numPeriods  = obj.numPeriods;
    numModels   = obj.numModels;
    nfor        = obj.batch.nfor;
    nvary       = obj.nvary;
    x           = nan(numPeriods, numModels, nfor, nvary);
    parfor i = 1 : nfor
        %xi=nan(numPeriods,numModels,nvary);
        xi      = nan(numPeriods, numModels);
        xi(:,:) = cell2mat(cellfun(@(x)cell2mat(...
            (cellfun(@(y)(y.horizons(i,1)),x,'uniformoutput',false))),...
            resCell,'uniformoutput',false)...
            );
        xi          = repmat(xi,[1 1 nvary]);
        x(:,:,i,:)  = xi;
    end
end
end
