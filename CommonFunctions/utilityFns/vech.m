function q = vech(Q)
% vech - Perform half-vectorization of a n x n matrix Q
%
% Input:
%
%   Q = matrix, (n x n)
%
% Output:
%
%   qvec = vector, (n(n+1)/2 x 1). Lower triangular part of Q
%
% Usage:
%
%   q=vech(Q) 
%   (Typically Q is a symmetric matrix (e.g. a coveraince))
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

[r, c] = size(Q);
if r ~= c
    error([mfilename ':size'], 'The Q matrix must be square')
end
q = tril(ones(r));
q = Q(q == 1);

