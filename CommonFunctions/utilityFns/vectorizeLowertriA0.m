function A0vec = vectorizeLowertriA0( A0 )
% vectorizeLowertriA0 - Vectorize a lower triangular A0 matrix (with ones on the
% diagonal) disregarding the diagonal. 
%
% Input:
%
%   A0      [matrix]
%           (n x n), lower triangular with ones on the diagonal
%
% Output:
%  A0vec     [vector}
%           (n*(n-1)/2 x 1), where the diagonal elements of A0 are
%           disregarded and the vectorization is done row by row
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

n       = size(A0, 1);
Q       = tril(ones(n), -1)';
A0tr    = A0';
% Output
A0vec   = A0tr(Q == 1);

