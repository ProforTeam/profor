function outRand = randMixedNormal( obj, outDim, draw_type)
% randSplitNormal - Mixed-Normal distributed pseudorandom numbers.
%   Generated in two steps with two possible methods.
%       1. Randomly choose from which component to sample from using either:
%           a. Uniform - Generate uniform random number and take the cumsum of
%                        the prob of each mixture component (prob_error).
%           b. Multinomal - Standard multinomal sample from the prob of each
%                           mixture component (prob_error).
%       2. Sample N times from the appropriate Normal component.
%
% Input:
%   obj             [MixedNormal]
%   outDim          [numeric]       Size of the output matrix, default 1.
%   draw_type       [str]           Type of 1st stage sampling, default
%                                   multinomal.
%
% Output:
%   outRand         [double]
%
% Usage:
%   outRand = mixedNormalObj.randMixedNormal(outDim)             
%   e.g
%   outRand = mixedNormalObj.randSplitNormal([10, 1000, 5])                                                            
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


%% Validation.
narginchk(1, 3)

% If no output dimensions provided then return a random scalar.
if ~exist('outDim', 'var') 
    outDim = 1;
end
if ~exist('draw_type', 'var') 
    draw_type = 'multinomal';
end

%% Extract usefult parameters 
alfa        = obj.alfa;
h           = obj.h;
prob_error  = obj.prob_error;
    
% Calculat the total number of draws
n_draws     = prod(outDim);

outRand     = generateMixtureError(alfa, h, prob_error, n_draws, draw_type);

% Reshape output if required.
if length(outDim)>1
    outRand       = reshape(outRand, outDim);
end

end
