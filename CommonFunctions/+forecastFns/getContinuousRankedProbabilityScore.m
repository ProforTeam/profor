function crps = getContinuousRankedProbabilityScore(forecasts, obs, method)
% getContinuousRankedProbabilityScore Return Continuous-Ranked Probability Score
%   CRPS = PSCRPS(FORECAST, OBS) obtains the CRPS for a given vector of
%   observations in OBS, with associated empirical probability forecasts given
%   in the matrix FORECASTS. Each row of FORECASTS contains an empirical
%   distribution for each element of OBS. Output parameter is the CRPS value.
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

if nargin == 2
    method = 'method1';
end

if isnan(obs)
    
    crps = nan;
    
else
    
    [M, S]  = size(forecasts);
    N       = length(obs);
    
    if (M ~= N)
        error([mfilename ':input'],'Length of OBS must match number of rows in FORECASTS');
    end
    
    switch method
        
        case{'method1'}
            
            crps_individual = methodOneComp(forecasts, obs, N, S);
            
        case{'method2'}
            
            crps_individual = methodTwoComp(forecasts, obs, N);
            
    end
    
    % Take the mean across horizons
    crps = mean( crps_individual );
    
end
end



function crps_individual = methodOneComp(forecasts, obs, N, S)
% methodOneComp - Closed form expectation using iterates
%   Again from mike smith looks like.
%
% Input:
%   forecasts       [NxS] forecast densities
%   obs             outturns
%   N               Number of observables
%   S               Number of iterates
%
% Output:
%   crps_individual
%
% (cc) Max Little, 2008. This software is licensed under the Attribution-Share
% Alike 2.5 Generic Creative Commons license:
% http://creativecommons.org/licenses/by-sa/2.5/
% If you use this work, please cite:
% Little MA et al. (2008), "Parsimonious Modeling of UK Daily Rainfall for
% Density Forecasting", in Geophysical Research Abstracts, EGU General
% Assembly, Vienna 2008, Volume 10.

crps_individual = zeros(1, N);
for i = 1 : N
    crps1               = mean( ...
        abs( forecasts(i, :) - obs(i) ) ...
        );
    crps2               = mean( ...
        abs( ...
        diff( forecasts(i, randperm(S)) ) ...
        ));
    
    crps_individual(i)  = crps1 - 0.5*crps2;
end

end



function crps_individual = methodTwoComp(forecasts, obs, N)
% methodTwoComp Seems to be Mike Smiths code - see contributions.
%   For numerical integration. 
% Input:
%   forecasts
%   obs
%   N
%
% Output:
%   crps_individual


crps_individual = zeros(1, N);

J       = 10000;
step    = 1/J;
a1      = step;
a2      = 1 - a1;
a       = a1 : step : a2;   %   a(1),...,a(J)

for i = 1 : N
    
    x       = forecasts(i,:)';
    xobs    = obs(i);
    
    % Take the forecast and sort into ascending order, difference to find points
    % that very close to one another.
    x       = sort(x);
    xdiff   = diff(x);
    eps     = mean(xdiff)*0.00001;
    k       = find(xdiff <= eps);
    
    % jitter observations by eps - I think so as not to muck up the empirical
    % pdf.
    if ~isempty(k)   
        jitter  = normrnd(0, 10*eps, size(k));  
        x(k)    = x(k) + jitter;
    end
    
    % Fit an empirical CDF to x, with pareto tails - but as upper and lower 
    % limits set to 0 and 1, just using the empirical distribution without the
    % Generalised Pareto Distribution on the tails.
    obj     = paretotails(x, 0, 1, 'ecdf');  
    
    % Returns an array q of values of the inverse CDF (icdf) for the piecewise 
    % distribution object OBJ, evaluated at the values in the array a
    q       = icdf(obj, a);  
    
    % Numerical integrate out (F(y) - I(q > y))^2 using rectangular integration.
    qsval   = qs(q, a, xobs);  
    
    crps_individual(i) = mean(qsval);        
end

end



function [ val ] = qs( q, a, y )
%qs Vector of Quantile Scores
%   Numerical integrates (F(y) - I(q > y))^2, or 2 * (F(y) - I(q > y))
%
% Inputs: 
%   a = (a(1),....,a(J))        Grid [0,1]
%   q = (q(1),..,q(J)           PDF on the grid in a
%   y                           Observation / outturn
% 
% Output: 
%   val = (QS(1),...,QS(J)) 
%       where, QS(j) = 2 * [ I(y < q(j)) - a(j)] * (q(j) - y)

J = size(q, 1);
if(size(a, 1) ~= J)
    error([mfilename ':input'],'q and a have to be same size');
end

idx         = zeros(J, 1);
idx(q > y)  = 1;
% Twice the rectangular integration as taking its square.
val         = 2*(idx - a).*(q - ones(J, 1)*y);

end

