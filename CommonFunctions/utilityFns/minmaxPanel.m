function [minPanel, maxPanel, varargout] = minmaxPanel(data)
% minmaxPanel - Find first and last entry (not nan's) of a data set 
%
% USAGE: [minPanel,maxPanel,onesMat]=minmaxPanel(data)
%
% Input:
%
%   data = (t x n) matrix with data and possibly nans
%
% Output:
%
%   minPanel = (1 x n) vector with the first observation (tm for each
%   column in data, i.e. the row where data starts for each data column
%
%   maxPanel = (1 x n) vector with the last observation (tma for each
%   column in data.
%
%   onesMat = (t x n) matrix with ones and zeros: ~isnan(data)
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

onesMat             = ~isnan(data);                       
[rDat, cDat]        = size(data);
index               = onesMat == 0;
counterMat          = repmat((1 : rDat)', [1 cDat]);
counterMat(index)   = nan;
minPanel            = min( counterMat ); 
maxPanel            = max( counterMat );

varargout{1}        = onesMat;