function [idxa, idxb] = cellObjCompare(cellObja, cellObjb)
% cellObjCompare - Compares content of two CellObj objects. These must be of the
% same type, but need not be of same size. Returns the result from a
% intersect operation. Only works for CellObj type 1 and 2
%
% Input: 
%
%   cellObja = CellObj
%
%   cellObjb = CellObj
%
% Output:
%
%   idxa = logical, (1 x n), where n is the same size as CellObja.numc and
%   where each element that also can be found in CellObjb is true, else
%   false. 
%
%   idxb = logical, (1 x m), where m is the same size as CellObjb.numc and
%   where each element that also can be found in CellObja is true, else
%   false. 
%
% Usage:
%   [idxa,idxb]=cellObjCompare(cellObja,cellObjb)
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

if cellObja.type ~= 1 && cellObja.type ~= 2
    error([mfilename ':input'],'cellObjCompare only works for type 1 and 2')
end;
if cellObja.type ~= cellObjb.type
    error([mfilename ':input'],'CellObj inputs needs to be of same type')
else
    nums = cellObja.numc;
    idxa = false(1, nums);
    idxb = false(1, cellObjb.numc);
    for i = 1 : nums
        if cellObja.type == 1        
            ib = strcmpi(cellObja.getX(i), cellObjb.getX);
            if any(ib)
                ia = true;
            else
                ia = [];
            end
        else
            [~, ia, ib] = intersect(cellObja.getX(i), cellObjb.getX);                                    
        end;
        if ~isempty(ia)
            idxa(i)  = true;
            idxb(ib) = true;
        end   
    end
end