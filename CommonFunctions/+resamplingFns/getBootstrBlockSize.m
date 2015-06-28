function [b,draws]=getBootstrBlockSize(T,lowerLimitDraws)
% PURPOSE: Get block size for moving block size 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%
%   T = sample size. integer
%
%   lowerLimitDraws = lower limit for number of draws. If not provided, 
%   default=5. 
%
% Output:
%
%   b = integer. Block size. 
%
%   draws = integer. Number of draws that can be made from a ordered moving
%   block residual matrix such that draws=T/b, i.e. b*draws=T. Note: The
%   equalities only hold approximately, and draws is rounded upwards. 
%
% Usage:
%   b=getBootstrBlockSize(T,lowerLimitBlocks)
%   b=getBootstrBlockSize(T)
%
% Note: Program has a lower and upper limit for number of blocks on 5 and
% 25. If lowerLimitDraws if not provided as input, lowerLimitBlockSize will 
% be used as the defining criterion. If lowerLimitDraws is provided, this
% will be used as the defining criterion. 
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

import resamplingFns.*

b=200;
lowerLimitBlockSize=5;
upperLimitBlockSize=25;
if nargin==1
    lowerLimitDraws=5;    
end;
if T<lowerLimitDraws
    lowerLimitDraws=T/2;
end;

draws=ceil(T/b);
while draws<lowerLimitDraws        
    b=b-1;    
    draws=ceil(T/b);    
    if nargin==1
        if b==lowerLimitBlockSize
            %warning('getBootstrBlockSize:lowerLimit','Your block size is less than %d',lowerLimitBlockSize)
            return
        end;        
    end;
end;

% Ensure that upperLimit of block size is not exceeded. 
if b>upperLimitBlockSize
    lowerLimitDraws=lowerLimitDraws+1;
    [b,draws]=getBootstrBlockSize(T,lowerLimitDraws);
end;


