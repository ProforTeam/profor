function crps = getGauassianAnalyticCRPS(mu, sigma, outturn)
% getGauassianAnalyticCRPS  Returns the analytic value of CRPS for a Gaussian
%                           predictive density.
%   CRPS: Continous ranked probability score
% 
% Inputs:
%   mu              forecast_mean
%   sigma           forecast_variance
%   outturn         Value of the observable
% 
% Outpus:
%   crps
% 
% References:
%   Gneiting, T. and M. Katzfuss (2014). "Probabilistic forecasting". Annual 
%   Review of Statistics and Its Application 1(1), 125?151.



errType = ['forecastFns:', mfilename];

%% Validate
narginchk(3,3)

%% Calculate the theoretical CRPS 

norm_outturn = (outturn - mu) / sigma;

crps = 2 * normpdf( norm_outturn ) - 1 / sqrt(pi) + ...
    sigma * ( norm_outturn * ( 2 * normcdf( norm_outturn ) - 1 ));