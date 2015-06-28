function X = doDataTransformation(data, transf, freq, varargin)
% doDataTransformation - Transforms data according to the specification in the 
% inputs. The size of the output matrix or vector is the same as the input data
% (NaNs are put in at the beginning).
%
% Input:
%   data = vector or matrix with original data. (t x n) where t is time and
%   n is number of series.
%
%   transf  = vector with tranformation specifications. Note: The examples
%   are shown for quarterly frequency.
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
%   freq    = string. Frequency of the variables. One of the following is
%             acceptable: 'a','q','m','d'. The input data (if a matrix)
%             need to be the same frequency.
%
% Output:
%
%   X = datamatrix with correct transformation; SAME DIMENSION AS data,
%   missing observations replaced with NaNs when data lost due to
%   transformations.
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

if nargin == 0
    % Display list of possible transformations
    fprintf([...
        '0 = no transformation\n', ...
        '1 = log                        eg. log(x)\n',...
        '2 = diff                       eg. x(2)-x(1)\n',...
        '3 = growth                     eg. (x(2)-x(1))/x(1)*100\n',...
        '4 = growth diff growth         eg. (x(3)-x(2))/x(2)*100 - (x(2)-x(1))/x(1)*100\n',...
        '5 = log diff                   eg. log(x(2))- log(x(1))\n',...
        '6 = log growth                 eg. (log(x(2))-log(x(1)))*100\n',...
        '7 = log growth diff growth     eg. (log(x(3))-log(x(2)))*100 - (log(x(2))-log(x(1)))*100\n',...
        '8 = diff yoy                   eg. x(5)-x(1)\n',...
        '9 = growth yoy                 eg. (x(5)-x(1))/x(1)*100\n',...
        '10= growth diff growth yoy     eg. (x(6)-x(2))/x(2)*100 - (x(5)-x(1))/x(1)*100\n',...
        '11= log diff yoy               eg. log(x(5))- log(x(1))\n',...
        '12= log growth yoy             eg. (log(x(5))-log(x(1)))*100\n',...
        '13= log growth diff growth yoy eg. (log(x(6))-log(x(2)))*100 - (log(x(5))-log(x(1)))*100\n',...
        ]);
    return
end

defaults    = {'initialValues', NaN, @isnumeric};
options     = validateInput(defaults, varargin);

% Preliminaries
[T, numberOfSeries]     = size( data );
freq                    = convertFreqS( freq );
X                       = ones(T, numberOfSeries).*options.initialValues;


if freq == 12
    addTo   = 8;
    
elseif freq == 365
    addTo   = 0;
    disp('yoy transformations are not supported for daily frequency')
    
else
    addTo=0;
end

% loop over variables
for j = 1 : numberOfSeries
    
    % Apply transformations. See doc string.
    if transf(j) == 0           % No transformation
        X(:,j)          = data(:, j);
        
    elseif transf(j) == 1       % log
        X(:,j)          = log(data(:,j));
        
    elseif transf(j) == 2       % Diff
        X(2 : end, j)   = data(2 : end, j) - data(1 : end - 1, j);
        
    elseif transf(j) == 3       % Growth
        X(2 : end, j)   = (data(2 : end, j) - data(1 : end - 1, j)) ...
            ./ data(1 : end - 1, j) * 100;
        
    elseif transf(j)==4         % Growth diff growth
        X(3 : end, j)   = (...
            (...
            ( data(3 : end, j) - data(2 : end - 1, j) ) ...
            ./ data(2 : end - 1, j) * 100 ...
            ) ...
            - (...
            ( data(2 : end - 1, j) - data(1 : end - 2, j) ) ...
            ./ data(1 : end - 2, j) * 100 ...
            )...
            );
        
    elseif transf(j) == 5         % log diff
        X(2:end,j)      = log( data(2 : end, j) ) - log( data(1 : end - 1, j));
        
    elseif transf(j) == 6         % log growth
        X(2 : end, j)   = ( log(data(2 : end,     j)) - ...
            log(data(1 : end - 1, j)) ) * 100;
        
    elseif transf(j) == 7         % log growth diff growth
        X(3 : end, j)   = ( log(data(3 : end,   j)) - ...
            log(data(2 : end-1, j)) ) * 100 - ...
            (log(data(2 : end - 1, j)) - ...
            log(data(1 : end - 2, j)) ) * 100;
        
        %% yoy computation starts. Note: freqeuncy will affect
        
    elseif transf(j) == 8         % diff yoy
        X(5 + (addTo) : end, j)     = ...
            data(5 + (addTo) : end, j) - data(1 : end - (4 + addTo), j);
        
    elseif transf(j) == 9         % growth yoy
        X(5 + (addTo) : end, j)     = ...
            (data(5 + (addTo) : end, j) - data(1 : end - (4 + addTo), j))...
            ./ data(1 : end - (4 + addTo), j) * 100;
        
    elseif transf(j)==10        % growth diff growth yoy
        X(6 + (addTo) : end, j)     = ...
            (((data(6 + (addTo) : end, j) - data(2 : end - (4 + (addTo)), j))...
            ./ data(2 : end -(4 + (addTo)), j) * 100) - ...
            ((data( 5 + (addTo) : end - 1, j) - data(1 : end - (5 + (addTo)), j)) ...
            ./ data(1 : end - (5 + (addTo)), j) * 100));
        
    elseif transf(j) == 11        % log diff yoy
        X(5 + (addTo) : end, j)     = ...
            log(data(5+(addTo):end,j))-log(data(1:end-(4+(addTo)),j));
        
    elseif transf(j) == 12        % log growth yoy
        X(5 + (addTo) : end, j)     = ...
            (log(data(5+(addTo):end,j))-log(data(1:end-(4+(addTo)),j)))*100;
        
    elseif transf(j) == 13        % log growth diff growth yoy
        X(6 + (addTo) : end, j)     = ...
            (log(data(6+(addTo):end,j))-log(data(2:end-(4+(addTo)),j)))*100 ...
            - (log(data(5+(addTo):end-1,j))-log(data(1:end-(5+(addTo)),j)))*100;
        
    else                          % nothing
        X(:, j)                     = data(:, j);
        
    end
    
    
end

end


