function xx = checkBatchAgainstData(obj, data)
% checkBatchAgainstData

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

xx  = false;

% Check selection (can not check sample because different
% estimation methods might make different sample work becasue
% of lags etc.)

cc  = intersect( obj.selectionY.x, {data.mnemonic} );

if numel(cc) ~= obj.selectionY.numc
    r   = ismember(obj.selectionY.x, cc);
    error([mfilename ':checkBatchAgainstData'], ...
        ['You try to select data that is not in the data object!\n',...
        'The following variables where not found: %s\n'], ...
        obj.selectionY.x{r==0});
end

cc  = intersect( obj.selectionX.x, {data.mnemonic,'const'});

if numel(cc) ~= obj.selectionX.numc
    r   = ismember( obj.selectionX.x, cc );
    error([mfilename ':checkBatchAgainstData'], ...
        ['You try to select data that is not in the data object!\n',...
        'The following variables where not found: %s\n'], ...
        obj.selectionX.x{r==0});
    
else
    xx  = true;
end
end
