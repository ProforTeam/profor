%% Import External Forecasts 

%% Using external empiric forecasts
% This script shows the form in which forecasts generated
% outside the PROFOR Toolbox are imported. 
% Externally-generated forecasts can be integrated into the Model class 
% based framework of PROFOR in two forms:
%
% # ExternalAnalytic
% # ExternalEmpiric
%
% An example of how to use an ExternalAnalytic forecast benchmarked against
% an AR(1) is provided in, see the  <./bankOfEnglandExample.html external analytic example.>
%

%% ExternalAnalytic
% Currently, only the split-Normal distribution is supported and the raw 
% forecast data must be supplied in the following format:
help loadSplitNormalDataFromCsv

%% ExternalEmpiric
% The raw forecast data must be supplied in the following format:
help loadEmpiricForecastFromCsv

