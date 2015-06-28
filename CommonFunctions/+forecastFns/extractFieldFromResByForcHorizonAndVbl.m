function out = extractFieldFromResByForcHorizonAndVbl(fieldName, resultCell, iHorizon, ...
    iVbl)
% extractFieldFromResByForcHorizonAndVbl - 
%   Helper fn that extracts the latest field from the result cell by forecast
%   horizon and vbl.
%
% Input:
%   fieldName       [str]
%   resultCell      [cell]
%   iHorizon        [int]
%   iVbl            [int]
%
% Output:
%   out             [numeric]
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

errType = [mfilename, ': '];

% Extract the field by forecast horizon and variable, group cases by the
% dimension of their output. 
switch lower(fieldName)
    case lower({'simulations', 'densities'})
        extractFieldByForecastHorAndVbl ...
            =  @(y)( squeeze( y.(fieldName)(iHorizon, iVbl, :) ) );        
        
    case lower({'xDomain'})
        extractFieldByForecastHorAndVbl ...
            =  @(y)( squeeze( y.(fieldName)(:, iVbl) ) );                
        
    case lower({'dates', 'predictions'})
        extractFieldByForecastHorAndVbl ...
            =  @(y)( squeeze( y.(fieldName)(iHorizon, iVbl) ) );
        
    otherwise
        error(errType, 'Unrecognised field in resultCell')
end

% Define helper fn that extract the forecast simulation from a result cell
% by forecast horizon and variable.            
extractFieldFromResultCell ...
    = @(x) cell2mat( ( cellfun( extractFieldByForecastHorAndVbl, ...
    x, 'uniformoutput', false) ) );

% Extract the 'fieldName' for given forecast horizon and variable.
out = cell2mat( cellfun( extractFieldFromResultCell, ...
    resultCell, 'uniformoutput', false))';

end