%% Making Reports Using Report Functionality

%%
% 
% The reporting functionality works on two types of object:
%
% 1. Model
%
%  (a) estimation: Estimation
%
%  (b) estimation: Estimationcombination
%
% 2. Profor
%
% Prerequisite:
%  First run proforExample.m, i.e. the Real-Time Data profor example, 
% <matlab:edit(fullfile('proforExample.m')) matlab code>.
%
% See the
% <matlab:edit(fullfile('makingReportsExample.m')) matlab code>
% corresponding to edit and run this Using Report Functionality help file.
%
%
%% Introduction
%
% Initialize screen output:

format long
%%
% For an overview of the Reporting functionality, type:

help Report

%%
% In general, for each of the methods of the Report class, checking the
% help documentation tells what must be specified by the researcher.  For
% example, to plot the density forecast fan chart, type:

help Report.plotDensityForecast

%% 1(a) Individual models (estimation: Estimation)
%
% Load an individual model for a particular data vintage (not necessarily
% the last):

m1 = Model.loado(fullfile(proforStartup.pfRoot, 'help', 'helpFiles', ...
    'htmlexamples', '+results', 'resultsProfor', 'models', 'M2', 'results', ...
    '2004.01_1', 'm'));

%%
% First, construct the Report object:

r1 = Report(m1);

%%
% Check out the settings, to change the way things look:

disp(r1)

%%
% Check the methods of the Report object:

methods(r1)

%% Plot point forecasts
%
% Plot a point forecast using 'r1.plotPointForecast' with the given variable, 
% specifying the number of periods before the
% evaluation period starts 'nEstimationDatesToInclude'.

nEstimationDatesToInclude = 10;

%%
% Plot individual series:

variableToPlot = 'gdp';
r1.plotPointForecast( variableToPlot, nEstimationDatesToInclude)

%%
% Or plot a list of series:

variableToPlot = {'gdp', 'gdpctpi'};
r1.plotPointForecast( variableToPlot, nEstimationDatesToInclude)

%% Plot density forecasts
%
% Density forecasts can be plotted for a given variable, displaying  
% a number of observations prior to the forecast origin.
%
% Set the colour of the density map by using the 'plotOptions' settings.
% For example, to get something similar to the Bank of England charts:

r1.plotOptions.densityColor = {'r'};

%%
% To control the quantiles used in the density forecast, set the
% option in 'Reports.plotOptions':

r1.plotOptions.quantiles = [0.10; 0.30;  0.70; 0.90] .* 100;
r1.plotDensityForecast({'gdp'}, nEstimationDatesToInclude)

%%
% For the Norges Bank style colours in the charts:

r1.plotOptions.densityColor = {'f'};
r1.plotDensityForecast({'gdp'}, nEstimationDatesToInclude)

%% 1(b) Combination models (estimation: Estimationcombination)
%
% For a combination model:

cm = Model.loado(fullfile(proforStartup.pfRoot, 'help', 'helpFiles', ...
    'htmlexamples', '+results', 'resultsProfor', 'models', 'Combination_gdp', ...
    'results', '2004.01_1', 'm'));

%%
% Construct a Report object with the combination model:

r2 = Report(cm);

%%
% Plot the point and density forecasts in the same manner as for
% individual models. Note, this uses the new Report object 'r2', which
% refers to the combined forecast.

r2.plotPointForecast( {'gdp'}, nEstimationDatesToInclude)
r2.plotDensityForecast({'gdp'}, nEstimationDatesToInclude)

%% Plot the weights and scores
%
% Using 'plotWeightsorScores', choose the weights (or scores), the model
% names and the forecast horizons:

forecastHorizonToPlot = 1;
r2.plotWeightsOrScores('weights', {'M1','M2', 'M3'}, forecastHorizonToPlot)

%% 2) PROFOR objects
%
% This works with the output from 'proforExample'. Therefore, the
% researcher must point to the location of the batch files and results
% folder from a PROFOR experiment:
 
p                   = Profor;
p.savePath          = fullfile(proforStartup.pfRoot, 'help', 'helpFiles', ...
    'htmlexamples', '+results', 'resultsProfor');
p.modelSetupPath    = fullfile(proforStartup.pfRoot, 'help', 'helpFiles', ...
    'htmlexamples', '+batchFiles', 'batchFilesProfor');

%%
% Generate a report using:

r3 = Report(p);

%% Plot Total Economic Loss (TEL)
%
% Check the help settings for Total Economic Loss (TEL) 
% in order to set the options for the function:

help Report.plotTotalEconomicLoss

%%
% Set the inputs for the TEL plot.  The researcher selects the threshold
% for the event of interest, the variable name, the benchmark model, the
% models to be compared, and the forecast horizon, respectively. Note, the
% same eventThreshold must be included in the Profor experiment before
% generating the report -- here the experiment was run with proforExample.m.

eventThreshold      = 1.0;
vblName             = 'gdp';
defaultModelName    = 'M1';
modelNames          = {'M1', 'M2', 'M3'};
forecastHorizon     = 1;

%%
% Plot TEL against relative cost, R=C/L, where 0<R<1.  Note that
% 'leftHandSide' tells PROFOR to define the event below the threshold, e.g.
% GDP < 1.0 event. (And, rightHandSide means above the threshold e.g. GDP >
% 1.0 event).
%
% TEL is plotted relative to the benchmark here.  So, a 40 on the plot
% y-axis indicates a 60 percent improvement over the benchmark, normalized
% to 100.
%
% TEL is evaluated against the last available vintage of data using the
% real time latest available forecasts. 
% 
% By default, the outturns for forecast evaluations are set to the latest 
% available vintage with the reporting functionality. 

r3.plotTotalEconomicLoss(vblName, eventThreshold, {'M1', 'M2', 'M3'}, ...
    defaultModelName, forecastHorizon, 'leftHandSide')

%% Plot the probability of these events
% 
% Plot the time series of forecast probabilities (for the same event):

r3.plotProbabilityEventThreshold(vblName, eventThreshold, {'M1', 'M2', 'M3'}, ...
    forecastHorizon, 'leftHandSide')

%% Plot the Relative Operating Characteristics (ROCs)
% The researcher controls the plot via the same imputs as the TEL plot and the
% probability plot (described above). The help provides a description and
% a reference paper for ROCs:

help  plotRelativeOperatingCharacteristics

%%
% 
% A well-performing model will lie above the 45 degree line on the ROC
% plot. To generate the ROC plot, with critical probability 0.5, run the
% following script:

r3.plotRelativeOperatingCharacteristics(vblName, eventThreshold, {'M1', 'M2', 'M3'}, ...
    defaultModelName, forecastHorizon, 'leftHandSide')

%% Real-time tables of scores or weights
%
% Profor can recursively evaluate the real-time models when a new data
% vintage is released.
% 
% The results of this evaluation can be examined in MATLAB's table format.
% Check the help for this method:

help Report.getRealTimeTable
 
%%
%
% To understand realTimeTableType, consider an example of a full table. 

scoreMethod         = {'logScoreD'};
outType             = 'scores';
realTimeTableType   = 'full';
out = r3.getRealTimeTable(vblName, {'M1'}, forecastHorizon, ...
    scoreMethod, outType, realTimeTableType, []);
out{1}

%%
%
% This displays the scores of the real-time models evaluated using
% different data vintages. Note, that the `current' data vintage never
% includes the `current' time series observation -- macro data are released
% with a one period lag.

%%
%
% Run the table with 'realTimeTableType   = 'full';' this delivers all NaNs
% because of the data release lag issue.

%% 
%
% Run this again for the weights, with equal weights for the last
% observation (which can't be evaluated):

outType             = 'weights';
out = r3.getRealTimeTable(vblName, {'M1'}, forecastHorizon, ...
    scoreMethod, outType, realTimeTableType, []);
out{1}



%% Produce tables for various scoring methods 
%
% The researcher should experiment with the tables directly. However,
% PROFOR provides a helper method to break down the tables into different
% chunks. Check this against the real-time table above -  the two
% correspond.

scoreMethod         = {'logScoreD'};
requestedVintage    = 2003.04;
startPeriod         = 2000.01;
endPeriod           = 2003.02;
defaultModelName    = 'M1';

scoreTable = r3.getDensityForecastScoreTable(vblName, {'M1', 'M2', 'M3'}, ...
    forecastHorizon, scoreMethod, requestedVintage, startPeriod, ...
    endPeriod, defaultModelName, [])

%% Plot the Probability Integral Transforms (PITs)
%
% Well-calibrated forecast densities give a uniform distribution to the
% PITS.  A tough ask in small samples, typically. This feature of the
% reporting functionality uses the set of first measurements for forecast
% evaluations -- the diagonal of the real-time data matrix.
% 
%
% A good reference is: F. X. Diebold, T. Gunther, and A. S. Tay. Evaluating
% density forecasts, with applications to financial risk management.
% International Economic Review, 39:863?883, 1998. 

r3.plotProbabilityIntegralTransforms(vblName, {'M1', 'M2', 'M3'}, ...
    forecastHorizon, 'logScoreD', [])

%% View the table of tests based on the PITs
%
% Sometimes the PITS are evaluated at the end of the evaluation period,
% using a battery of one-shot tests.  Low probability values are bad news
% here - meaning that the null of 'no calibration failure' can be rejected.
% In which case, the PITS are not uniform and/or are serially corellated.
%
% An application of these tests is provided by 'Real-Time Inflation Forecast
% Densities from Ensemble Phillips Curves' by Garratt, Vahey and Wakerly,
% North American Journal of Economics and Finance, 2012.  Also, earlier
% version is CAMA Working Paper 34/2010.
%
% The goodness of fit tests employed include: 1) The Likelihood Ratio (LR)
% test proposed by Berkowitz (2001); a three degrees of freedom variant
% with (for h=1 only) a test for independence, where under the alternative $z_{\tau}$
% follows an AR(1) process. 2) The Anderson-Darling (AD) test for
% uniformity, a modification of the Kolmogorov-Smirnov test, intended to
% give more weight to the tails. 3) Following Wallis (2003), a Pearson chi-squared test 
% ($\chi^{2}$) which divides the range of the $z_{\tau}$ into eight equiprobable
% classes and tests for uniformity in the histogram. 4) The test for
% independence of the PITS is a Ljung-Box (LB) test, based on (up
% to) fourth-order autocorrelation.
%
% To generate a table of these PITS-based tests (with the average
% logarithmic score also computed), using the set of first measurements for forecast
% evaluations, run:

scoreMethod         = {'logScoreD'};
r3.getProbabilityIntegralTransformsTests(vblName, scoreMethod, {'M1', 'M2', 'M3'}, ...
    defaultModelName, forecastHorizon, [])

%% Produce MSPE for point forecasts 
%
% This produces the Mean Squared Prediction Error, based on the median
% of the forecast density:

scoreMethod         = {'mse'};
scoreTable = r3.getDensityForecastScoreTable(vblName, {'M1', 'M2', 'M3'}, ...
    forecastHorizon, scoreMethod, requestedVintage, startPeriod, ...
    endPeriod, defaultModelName, [])


%% Evaluate point forecasts 
% 
% This produces a table with a robust DM test statistic (small sample
% corrected), with the default model (deafultModelName) as a benchmark:

out = r3.evaluatePointForecast(vblName, scoreMethod, {'M1', 'M2', 'M3'}, ...
     defaultModelName, forecastHorizon, []);
out{1} 




