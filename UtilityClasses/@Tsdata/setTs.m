function ts = setTs(dates, data)
% setTs - 
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


if isempty(dates) || isempty(data)
    error([mfilename ':input'],'dates and data can not be empty')
else
    if ~isnumeric(dates) || ~isnumeric(data)
        error([mfilename ':input'],'dates and data must be numeric')
    else
        [rd, cd]   = size(data);
        [rdd, cdd] = size(dates);
        if cd > 1 || cdd > 1
            error([mfilename ':input'],'dates and data must be (t x 1) vectors')
        end                                                                        
        if sum(isnan(data)) == rd
            error([mfilename ':input'],'The data property contains all nans')
        end
        if rd ~= rdd
            error([mfilename ':input'],'The length of dates and data is not equal')
        end
        % Find first and last obs in panel. Then remove nans. Do
        % not want to carry around lots of these...                                        
        [mi, ma]    = minmaxPanel(data);           

        keySet      = dates(mi:ma, 1);
        valueSet    = data(mi:ma, 1);

        if ~isreal(valueSet)
            error([mfilename ':input'],'The data property is not real valued')                                             
        end                        

        % Construct a mapping between dates and values and
        % stor in ts property
        ts      = containers.Map(keySet,valueSet);
    end

end