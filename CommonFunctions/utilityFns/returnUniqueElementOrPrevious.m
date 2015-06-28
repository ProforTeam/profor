function out = returnUniqueElementOrPrevious(inCell, previousValue, loopCounter)
% returnUniqueElementOrPrevious - Helper fn to return a unique populated element
%                                 from a cell or its previous value.
%
% Input:
%   inCell          [cell]
%   previousValue   [Can be any class]
%
% Output:
%   out             [Can be any class]
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

outIdx     = isCellNonEmpty( inCell );
if sum(outIdx) == 1
    out        = inCell{outIdx};
    
elseif sum( outIdx ) > 1
    error(errType, 'Multiple instances of year found within one block of data')
    
else
    if loopCounter == 1
        error(errType, 'First block of data does not contain year info')
        
    elseif isempty( previousValue )
        error(errType, 'The previous block/blocks of data do not contain year info')
        
    else
        % Return the previous value.
        out     = previousValue;
        
    end
end
end