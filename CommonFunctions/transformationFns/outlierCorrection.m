function [data, idi] = outlierCorrection(data, varargin)
% outlierCorrection - Correct for putlier in a data matrix. Either interquantile 
%                     range or sigma detection
%
% Input:
%
%   data = vector or matrix with original data. (t x n) where t is time and
%   n is number of series.
% 
%   varargin = optional input. One or more of the following
%       outlierCorr = string followed by a number. The number define outliers 
%       as those obs. that exceed the number times the interquartile distance.
%       (or number of times from standard deviations of series)
%       Default=0, eg no outlier correction.
%
%       method = string followed by string. The method can either be:
%       interquartile or sigma. interquartile uses inter quantile range to
%       detect outliers. Sigma uses standard deviations. 
%
% Output:
%
%   x =  vector or matrix with corrected data. (t x n) where t is time and
%   n is number of series.
%
%   idi = vector or matrix with zeros and ones. (t x n) where t is time and
%   n is number of series. Ones will be placed where corrections have been 
%   done
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

[t, n]  = size(data);
idi     = zeros(t, n);

default = {...
    'setoutlieras',     3,                  @isnumeric,...
    'outlierMethod',    'interquartile',    @(x)any(strcmpi(x,'interquartile') || strcmpi(x,'sigma'))...
    };

% overwrite defautlts id varargin provided
options = validateInput(default, varargin(1:nargin-1));

for j = 1 : n
    [X_corr, Jout] = outliers_correction(...
        data(isnan(data(:,j)) == 0, j), options.setoutlieras,...
        options.outlierMethod...
        );
    
    % Restore missing values!
    % X_corr(isnan(X(:,j)),j)=NaN; %% Restore the missing numbers that have been filled during the outliers corrections    
    data(isnan(data(:, j)) == 0, j) = X_corr; 
    idi(isnan(data(:, j)) == 0, j)  = Jout; 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Z, Jout, Jmis] = outliers_correction(X, outcorr, method)

T       = size(X,1);
Jmis    = isnan(X);
a       = sort(X);

if strcmpi(method, 'interquartile')    
    %%% define outliers as those obs. that exceed #(outcorr) times the interquartile
    %%% distance
    Jout = (abs(X-a(round(T/2))) > outcorr*abs(a(round(T*1/4))-a(round(T*3/4))));
elseif strcmpi(method, 'sigma')    
    % ...or define them as outcorr*std 
    me      = mean(X);
    st      = std(X);
    Jout    = abs(X - repmat(me,[T 1])) > outcorr*st;
end;

Z = X;
%Z(Jmis) = a(round(T/2)); %% put the median in place of missing values
%Z(Jout) = a(round(T/2)); %% put the median in place of outliers
%Zma = MAcentered(Z,3);
%Z(Jout) = Zma(Jout);
%Z(Jmis) = Zma(Jmis);

outindx = sum([Jmis Jout], 2) > 0;
xv      = (1:length(Z))';
inty    = interp1(xv(outindx == 0),Z(outindx == 0), xv(outindx), 'spline');
yy      = Z;
yy(outindx) = inty;
Z       = yy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x_ma = MAcentered(x, k_ma)
xpad = [x(1,:).*ones(k_ma,1); x; x(end,:).*ones(k_ma,1)];
for j = k_ma+1:length(xpad)-k_ma;
    x_ma(j-k_ma,:) = mean(xpad(j-k_ma:j+k_ma,:));
end;