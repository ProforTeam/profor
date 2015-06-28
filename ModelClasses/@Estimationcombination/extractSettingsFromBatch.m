function [obj] = extractSettingsFromBatch(obj, batch)
% extractSettingsFromBatch  Extract the parameter settings from the batch file. 
%
% Input:
%   obj     [Estimation]                            Self
%   batch   [Batchvar/Batchcombination etc]         A model type specific batch
%                                                   file
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

bs      = struct(batch);
fnames  = fieldnames(bs);
nFnames = numel(fnames);

objMeta = metaclass(obj);
pNames  = {objMeta.PropertyList.Name};

for i = 1:nFnames

    if any(strcmpi(fnames{i},pNames))    
        emi = findobj(objMeta.PropertyList,'Name',fnames{i});
        if emi.Dependent == true
            error([mfilename ':program'],'Can not transfer dependent porperty')
        end
        
        obj.(fnames{i}) = bs.(fnames{i});     
        
    else
        
        if strcmpi(fnames{i},'selectionY')
            obj.namesY          = bs.selectionY;
        elseif strcmpi(fnames{i},'selectionA')
            obj.namesA          = bs.selectionA;            
        elseif  strcmpi(fnames{i},'forecastSettings')
            obj.nfor            = bs.forecastSettings.nfor;
        end
    end
    
end

end