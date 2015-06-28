function outCell = numbers2mnemonics(data, inCell, blocksIdx)
% numbers2mnemonics - Get menmonics from Tsdata object based on block 
% information in a cell. 
%
% Input:
%
%   data = Tsdata object
%
%   inCell = cell with either number (index) for series in data or block
%   (index) for series in data.
%
%   blocksIdx = logical. I true, inCell refers to blocks, otherwise
%   numbers.
%
% Output:
%
%   outCell = cell, same numel as inCell, but with data menmonics in place
%   of block or numbers. 
%
% Usage:
%   outCell=numbers2mnemonics(data,inCell,blocksIdx)
%   e.g.
%   outCell=numbers2mnemonics(data,{1,[2 3 4]},true)
%   or 
%   outCell=numbers2mnemonics(data,{1,(1:50)},false)
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

n       = numel(inCell);
outCell = cell(1, n);
if blocksIdx
    inCell = block2numberSel(data, inCell, n);
end

for i = 1 : n
    inCellI = inCell{i};
    m       = numel(inCellI);     
    ouCellJ = cell(1, m);
    for j = 1 : m          
        dd              = findobj(data, 'number', inCellI(j));                                 
        ouCellJ{1, j}    = dd.mnemonic;
    end
    outCell{i} = ouCellJ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = block2numberSel(data, inCell, n)
% PURPOSE: Convert a factor selection index with block entires to a
% cellstr with values. I.e. use block and number fields in data

x = cell(1, n);
for i = 1 : n
    blockDat = inCell{i};
    numberId = [];
    for j = 1 : numel(blockDat)
        idx = [data.block] == blockDat(j);
        y   = [data.number];
        if numel(y) ~= numel(unique(y))
            error([mfilename ':block2numberSel'], 'You do not have unique number properties in your data object')
        end
        numbers     = y(idx);
        numberId    = cat(2, numberId, numbers);
    end;                                        
    x{i} = numberId;
end

        

