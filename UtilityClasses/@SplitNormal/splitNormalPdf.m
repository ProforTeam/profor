function pdfvalue = splitNormalPdf(obj, x)
% splitNormalPdf - Split-Normal probability density function (pdf). Constructed by
%                combining two normal densities.
%   Calculated according to Wallis (2004) Box A, eq A1.  
%
% Input:
%   obj         [SplitNormal]
%   x           [numeric]       Vector / Matrix
%
% Output: 
%   pdfvalue    [numeric]
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

% Initialise the output pdf.
pdfvalue    = zeros( size(x) );

% Extract and construct convenient parameters.
sigma1      = obj.sigma1Sq^0.5;
sigma2      = obj.sigma2Sq^0.5;

% As we will use the normpdf with (x, mu, sig1 / sig2 ) we need to renormalise
% to get the common value of A = sqrt(2 / pi) * ( sig1 + sig2)^-1 as in A1.
leftNormA      = 2 * sigma1 / (sigma1 + sigma2);
rightNormA     = 2 * sigma2 / (sigma1 + sigma2);

% Assertain which side of the mode the input values are.
idxLeft     = x <= obj.muMode;

% Evaluate the densities either side of the mode.
pdfvalue(  idxLeft) = normpdf( x(  idxLeft ), obj.muMode, sigma1) * leftNormA;
pdfvalue( ~idxLeft) = normpdf( x( ~idxLeft ), obj.muMode, sigma2) * rightNormA;

end
