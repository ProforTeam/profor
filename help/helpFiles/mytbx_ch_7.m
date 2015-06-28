%% Subtle Considerations

%% Subtle considerations 
%
% Some features of the toolbox that are somewhat subtle, but worth knowing.
% 
%

%% dataSettings
%
% In the batch objects for the different models there is a property called
% dataSettings. The dataSettings property for the individual models defines
% which transformations will be used for that particular model
% 
% Likewise, the dataSettings property for the combination batch file
% defines which transformations will be used in the combination,
% i.e., when evaluating the individual models and constructing a combined
% forecast.
%
% Thus, the dataSettings for the individual models and the combination can
% differ.
%
% The dataSettings property does not need to be defined. Then, its state is
% default, and no transformations will be performed on the data when running
% models and combination. This means that the researcher can only report
% the forecasts in the same form as the raw data read into the models.
%
% When the dataSetting property is not at its default, PROFOR will
% transfrom the data in "real time" according to this ordering:
%
% sesAdjData; convertData; transformData; trendAdjData;
%
% After the second transformation: convertData, the Tsdata object is saved.
% Why? To be used when level information required to construct forecasting
% objects. The file is saved as:
% save(fullfile(proforStartup.pfRoot,'temp',obj.links.tag,'historyDataForForecasting.mat'),
% 'E');
% 

%% xDomain
%
% The xDomain setting in densityScoreSettings defines the manner in which the
% densities are approximated. PROFOR uses the built-in MATLAB ksdensity
% function to do this.  If the researcher does not
% specify an xDomain, then PROFOR automatically defines one.
% The default xDomainLength is 500.
%
% As the number of grid points increases (i.e., a finer grid), the accuracy
% of the approximation improves.  If the start and end points are too
% close, the pdfs will not integrate to 1. Setting the start and end far
% apart is safer, but at the cost of increased computation time.

%% Parallel computing 
%
% The PROFOR toolbox uses the parfor function from the built-in Matlab
% Parallel Computing Toolbox. This speeds up computations when looping
% across individual models, when controlling, loading and evaluating
% individual models and when combining forecasts.  Absent the Parallel
% computing toolbox, the run time on many PROFOR computations increases,
% but it still runs. By default, the proforStartup() command starts a
% number of local workers in MATLAB. The number of workers started depends
% on the researcher's MATLAB and computer settings.
%
% For example, by running the command, the researcher tells PROFOR to
% utilize 2 workers:
nWorkers = 2;
proforStartup(nWorkers)
 
%% Setting samples 
%
% Sample commands perform a number of functions within PROFOR.  The exact
% meaning of a sample commmand depends on where the command is given.
% Consider the use of the sample command for parameter estimation. Suppose,
% the researcher specifies the sample in the batch for the individual
% model. For example, using an AR model:
% 

b               = Batchvar;
b.selectionY    = {'ironP'};
b.sample        = '2007.01 - 2014.03';
%%
% The first date is the first observation included for parameter
% estimation, here 2007.01, and the second date is the last observation
% included for parameter estimation, in this case 2014.03.  
%
% The Tsdata object will override this sample for paramerter estimation iff
% there are insufficient observations in that instance.  For example,
% suppose the researcher first specifies the variable `ironP' as follows:
%

ironP = [124 62 61 52 73 82 120 147 126 148 172 169 167 129 135 133 106 113 141 118 122 122 111 94 81];
freq        = 'q';
mnemonic    = 'ironP';
dates       = latttt(2008,2014,3,3,'freq',freq);
d1 = Tsdata(dates,ironP','q', mnemonic);

%% 
% Now, suppose the researcher follows the above with more script to set up
% the batch for the AR (Batchvar), again defining the sample as running
% from 2007.01 to 2014.3 using the sample command in the AR batch.  Then
% PROFOR will use the shorter (truncated) sample for parameter estimation.
% This feature is handy when forecasting with competing models, or
% combining models based on out of sample performance, because the sample
% used for parameter estimation can differ across models.
%
% However, when using the Batchcombination, the sample command takes on a
% different meaning.  In this case, the sample command refers to the data
% vintages used to construct the weights for forecast combinations and
% evaluations.  Put differently,  the sample command in this context
% defines the `out of sample' evaluation period! Worth noting too that data
% vintages dated time t have observations up to t-1 (macro data are
% released with a one period time lag) so the data
% vintages define the forecast origins.  
%
% Consider the following example:

b                                   = Batchcombination;
b.selectionY                        = {'ironP'};
b.selectionA                        = {'AR1', 'M2'};
b.forecastSettings.nfor             = 8;
b.sample                            = '2012.01 - 2014.04';
%%
% This defines the out of sample evaluation period on forecast origins 
% from 2011.04 to 2014.03.  This features helps when working with ragged
% edge data.  Different models, with different variables are compared
% (combined) based on common information sets.
%
% As an example, suppose the researcher wishes to forecast GDP growth with
% an AR(1) model and a bivariate VAR in (lags of) GDP growth and spreads.
% The researcher wants to exploit the timeliness of the
% spreads, published daily, but this introduces a ragged edge problem
% because GDP releases are quarterly. Suppose the researcher has spread data
% including all days in 2000.02, but the last available observation for GDP
% is 2000.01. And the researcher wishes to make a forecast from, say, 
% end May 2002. The 2000.02 data vintage contains the last observations 2000.01 
% and 2000.02 for GDP growth and spreads, respectively. So, in effect
% the two models have distinct forecast origins, but a common information
% set date -- the data vintage dated 2000.02. The VAR will contain a missing 
% observation for GDP growth, which is extrapolated using the Kalman Filter, to 
% give a first forecast target of, say, 2000.03.  Note, that this is a two step
% ahead forecast from the perspective of the AR(1) model for GDP growth, but 
% only one step ahead for the VAR, dealing with the ragged edge. 
%
% If the data do not have a ragged edge issue, things are simple.  The
% sample command in the batch for the combination just gives the data
% vintage dates (information sets) and the forecast origins are taken to be
% one period before each forecast origin, to allow for a one period lag in
% the release of macro data. For example, suppose a VAR in inflation and GDP
% growth is used to forecast, along with an AR(1) for each variable, going
% one step ahead.  Then the quarterly data contained in vintage 2000.02
% contains the forecast origin of 2000.01 for all variables and the first
% target to be forecasted is 2000.02.
%
% Another consideration when using the Profor batch (that is, the actual
% forecast evaluation and combination step), the researcher sets the END
% date and this overides the end date in the sample command in the batch
% for the individual models (and combinations). This way, PROFOR can
% generate updated forecasts easily as new data vintages come it, without
% the researcher having to change all the sample statements.
% In contrast, the Profor batch does not overide the start of the sample
% specified previously for individual models and combinations
% -- so that different models can use different start dates for
% estimation).
% 
% One final issue, sometimes the researcher wishes to set a ``training
% sample'' to initialize the weights in combinations.  This is to some
% extent arbitrary but circumvents instability in the weights with 
% few out of sample observations.  If a training sample isn't
% specified by the researcher, the initial weights will be 1/N, where N is
% the number of models combined. To set a training sample, insert the
% following with the script controllling the Batchcombination:

b.trainingPeriodSample              = '2012.01 - 2013.04';

%%
% This fixes the data vintages to be used for training the weights.  The
% vintage dates specified must be a subset of those used for combination.
% In effect, the command tells PROFOR to generate weights and other metrics
% only after the 2011.04 vintage. But note that the weights always use the
% information in the training period.  That is, the default setting uses an
% expanding window to construct the weights, with the training period
% always included.
%
% An altenative approach uses a rolling window of observations to construct
% the weights for combinations.  Invoke this approach by including the
% script below just after specifiying the training window in the batch
% combination.  Notice that the rolling widow is the the length of the
% training sample, and the training sample command must be included.
% Default is false -- expanding window.

b.isRollingWindow = true

