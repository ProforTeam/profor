function extractModelProperties(obj, modelObj, errType)
% extractModelProperties - 
%
% Input:
%   obj         [Report]
%   modelObj    [Model]
%   errType     [str]       Error type name.
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

% Extract and set model properties.
if validateModel(obj, modelObj, errType)
    obj.modelProperties.method      = modelObj.method;
    obj.modelProperties.estimation  = modelObj.estimation;
    obj.modelProperties.forecast    = modelObj.forecast;
    
    % Set the default save path:
    obj.savePath                    = modelObj.savePath;
    
    % Extract the number of allowable forecast horizons.
    obj.allowableProperties.nForecastHorizon = ...
        modelObj.estimation.nlag;
    
    % Extract the allowable variable names.
    obj.allowableProperties.vblNames = ...
        modelObj.estimation.namesY.xNonEmpty;
    
    % TODO: Store individual model name - see issues #68/#69.
    
    if strcmpi( class(modelObj.estimation), 'Estimationcombination')
        obj.allowableProperties.modelNames = {['Combo: ', ...
            strjoin( modelObj.estimation.namesA.xNonEmpty, ', ')]};
        
        
    else
        obj.allowableProperties.modelNames = ...
            {'Individual Model'};
        
    end
    
    
end


