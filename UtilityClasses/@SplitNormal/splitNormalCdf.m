function cdfValue = splitNormalCdf(obj, x)
% splitNormalCdf - Split-Normal cumulative density function (cdf). Constructed by
%                combining two normal cdf.
%   Calculated according to Wallis (2004) Box A, eq A1. Take the two PDFs and
%   use a corrected form of their CDFs taking into account the constant. 
%
% Input:
%   obj         [SplitNormal]
%   x           [numeric]
%
% Output:
%   cdfValue    [numeric]
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

% Initialise the output cdf.
cdfValue    = NaN( size(x) );

% Extract and construct convenient parameters.
sigma1      = obj.sigma1Sq^0.5;
sigma2      = obj.sigma2Sq^0.5;

% Assertain which side of the mode the input values are.
idxLeft     = x <= obj.muMode;

% Evaluate the densities either side of the mode, applying the appropriate
% correction from eq A1.
cdfValue(idxLeft)   = 2 * sigma1 / (sigma1 + sigma2) * ...
    normcdf( ( x(idxLeft) - obj.muMode ) / sigma1, 0, 1) ;

cdfValue(~idxLeft)  =  2 * sigma2 / (sigma1 + sigma2) * ...
    normcdf( ( x(~idxLeft) - obj.muMode ) / sigma2, 0, 1);

end


