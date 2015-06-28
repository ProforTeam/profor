function xx = checkInitialization(obj, obje)
% checkInitialization

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

st      = max( obje.yInfo.minPanel );
en      = min( obje.yInfo.maxPanel );
y       = obje.y(st : en, :);
x       = obje.x;

xx = false;
if any(isnan(y))
    error([mfilename ':checkInitialization'],'y matrix contains nans for the estimation sample. This is not allowed for this model')
end

if ~isempty(x)
    if any(isnan(x))
        error([mfilename ':checkInitialization'],'x matrix contains nans. This is not allowed for this model')
    end
end

xx = true;
end
