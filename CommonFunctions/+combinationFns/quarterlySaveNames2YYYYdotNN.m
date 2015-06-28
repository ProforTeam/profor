function dates = quarterlySaveNames2YYYYdotNN( saveNames )
% quarterlySaveNames  -  Makes a cellstr with quarterly save names. Useful for
%                       RecursiveEstimation
% 
% Input:
%
% saveNames         [Cell]
%                   See QUARTERLYSAVENAMES
%
% Ouput:
%
% dates             [Vector]
%                   With dates in the cs format YYYY.NN
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

dates_cell   = regexprep( saveNames, '_(.)', '');
dates        = str2double(dates_cell);



