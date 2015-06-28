function X = redoDataTransformation(data, transf, freq, varargin)
% redoDataTransformation - Transform variables back to original frequency
%
% Input:
%
%   data = vector or matrix with original/transformed data. (t x n) where t 
%   is time and n is number of series. The data is assumed to have been 
%   transformed in accordance with the transf argument described below
%
%   transf  = vector with tranformation specifications. One element for each
%   column in the data matrix. See loadData function for more information. 
%
%   0 = no transformation
%   1 = log                       eg. log(x)
%   2 = diff                      eg. x(2)-x(1)
%   3 = growth                    eg. (x(2)-x(1))/x(1)*100
%   4 = growth diff growth        eg. (x(3)-x(2))/x(2)*100 - (x(2)-x(1))/x(1)*100
%   5 = log diff                  eg. log(x(2))- log(x(1))
%   6 = log growth                eg. (log(x(2))-log(x(1)))*100
%   7 = log growth diff growth    eg. (log(x(3))-log(x(2)))*100 -
%                                           (log(x(2))-log(x(1)))*100
%   8 = diff yoy                  eg. x(5)-x(1)
%   9 = growth yoy                eg. (x(5)-x(1))/x(1)*100
%   10= growth diff growth yoy    eg. (x(6)-x(2))/x(2)*100 - (x(5)-x(1))/x(1)*100
%   11= log diff yoy              eg. log(x(5))- log(x(1))
%   12= log growth yoy            eg. (log(x(5))-log(x(1)))*100
%   13= log growth diff growth yoy eg. (log(x(6))-log(x(2)))*100 -
%                                           (log(x(5))-log(x(1)))*100
%
%   freq    = string. The frequency of the variables. All the data in the 
%   data matrix (if a matrix) need to be in the same frequency. 
%   One of the following is acceptable: 'a','q','m','d'
%
%   varargin = optional input. string followed by argumnet/value. One or 
%   more of the following:
%       'fig',false = logical. If true, a figure will be produced for each 
%       variable, showing the transformed variable. Program pauses for each 
%       figure! Default=false
%
%       'X',[] = vector/matrix. If provided this should be a matrix/vector
%       the same sixe as the data matrix with the data in levels. The
%       program recurively moves to the timeseries and transforms the
%       growth data (transformed data in data matrix) back to levels.
%       Strictly speaking you do not need more than a starting values of
%       the levels in the X matrix for the program to work, eg data=[nan 2 3
%       4 5 6]', X=[10 nan nan nan nan nan]' and transf=3, will give you 
%       the following output; [10.00 10.20 10.51 10.93 11.47 12.16]. (The X
%       matrix/vector does not acutally need to be padded with nans). If
%       the X is not provided the program sets the predefined levels to
%       100. Default=[].
%       
% Output:
%
%   X = datamatrix with correct transformation; SAME DIMENSION AS data
%   input matrix/vector
% 
% Usage:
%
%   transf=[1 2 3 4 5 6 7 8 9 10 11 12 13];
%   dataSet=repmat((5:104)',[1 13])+randn(100,13);
% 
%   X=doDataTransformation(dataSet,transf,'m');  
%   dataSetRe=redoDataTransformation(X,transf,'m','X',dataSet);
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

defaults    = {'X', [], @isnumeric};
options     = validateInput(defaults,varargin(1:nargin-3));

% convert freq ar
freq = convertFreqS(freq);

if freq == 12
    addTo = 8;
elseif freq == 365
    addTo = 0;
    disp('yoy transformations are not supported for daily frequency')
else   
    addTo = 0;
end

% Preliminaries
[T, numberOfSeries] = size(data);
X                   = ones(T,numberOfSeries)*100;

% if X is provided, overwrite  X
if ~isempty(options.X)
        
    X = options.X;    
    
end

% loop over variables
for j = 1 : numberOfSeries    
    
    % ensure that the loop does not exceed the size of the X matrix
    if any(transf(j) == [2 3 5 6])
        idi = 1;
    elseif any(transf(j) == [4 7])        
        idi = 2;
    elseif any(transf(j) == [8 9 11 12])         
        idi = 4 + addTo;
    elseif any(transf(j) == [10 13])                 
        idi = 5 + addTo;
    else        
        idi = 0;
    end
    
    for t = 1 : T - idi    
        
        % get correct transformation   

        if transf(j) == 0 % nothing
            X(t, j) = data(t, j);

        elseif transf(j) == 1 % log.
            X(t, j) = exp(data(t, j));
        elseif transf(j) == 2 % diff
            X(2+t-1, j) = X(1+t-1, j) + data(2+t-1, j);      
        elseif transf(j) == 3 % growth
            X(2+t-1, j) = X(1+t-1, j)*(1+data(2+t-1, j)/100);
        elseif transf(j) == 4 % growth diff growth
            X(3+t-1, j) = X(2+t-1, j)*[X(2+t-1, j)/X(1+t-1, j) + data(3+t-1, j)/100];
        elseif transf(j) == 5 % log diff        
            X(2+t-1, j) = X(1+t-1, j)*exp(data(2+t-1, j));
        elseif transf(j) == 6 % log growth                 
            X(2+t-1, j) = X(1+t-1, j)*exp(data(2+t-1, j)/100);
        elseif transf(j) == 7 % log growth diff growth                  
            X(3+t-1, j) = (X(2+t-1, j)^2/X(1+t-1, j))*exp(data(3+t-1, j)/100);

        %% yoy computation starts. Note: freqeuncy will affect        

        elseif transf(j) == 8 % diff yoy             
            X(5+(addTo)+t-1, j) = X(1+t-1, j) + data(5+(addTo)+t-1, j);                 
        elseif transf(j) == 9 % growth yoy
            X(5+(addTo)+t-1, j) = X(1+t-1, j)*(1+data(5+(addTo)+t-1, j)/100);   
        elseif transf(j) == 10 % growth diff growth yoy     
            X(6+(addTo)+t-1, j) = X(2+t-1, j)*((X(5+(addTo)+t-1, j)/X(1+t-1, j))+(data(6+(addTo)+t-1, j)/100));
        elseif transf(j) == 11 % log diff yoy 
            X(5+(addTo)+t-1, j) = X(1+t-1, j)*exp(data(5+(addTo)+t-1, j));   
        elseif transf(j) == 12 % log growth yoy          
            X(5+(addTo)+t-1, j) = X(1+t-1, j)*exp(data(5+(addTo)+t-1, j)/100);
        elseif transf(j) == 13 % log growth diff growth yoy               
            X(6+(addTo)+t-1, j) = (X(2+t-1, j)*X(5+(addTo)+t-1, j))/X(1+t-1, j)*exp(data(6+(addTo)+t-1, j)/100);                        
        else

            X(t, j) = data(t, j); % nothing        

        end                                     
        
    end
       
end

