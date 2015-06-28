%% VAR Example
% This script shows how a simple VAR model can be set up and estimated using the 
% Model framework of the PROFOR Toolbox.

%%
% See the
% <matlab:edit(fullfile('runningModelsExample.m')) matlab code> 
% corresponding to this help file to run examples directly in MATLAB.
%

%% 1) Load data
% First, we load some simulated data, stored as Tsdata objects.
load(fullfile(proforStartup.pfRootHelpData,'varData.mat'));

%% 2) Initializing a Model object
% All individual time series models supported by the PROFOR Toolbox can be
% initialized as follows:
m = Model('var');
%%
% Here, the input 'var' defines that the researcher wishes to work with a VAR.
%
% The instance of the VAR Model class is 'm'. 'm' works as a container for
% all the information we have about (and will put into) our model, i.e.:

m
%%
% Typing 'm.state' will give the state of the Model object.  Before
% estimation and forecasting, this state has to be 'true' (MATLAB logical),
% i.e. 1.
m.state

%%


%% 3) Setting Tsdata
% The only Model properties set directly are the data and batch 
% properties. 
%
% First, supply data to the model. The estimation and forecasting
% properties are populated when the model is estimated and then used to
% forecast.
%
% To supply the model with data, type:  
m.data = d;


%% 4) Setting the Batch 
% The Model also needs some information about the estimation method, the
% variables to include, the sample used for parameter estimation, etc.  For
% most settings, there are defaults, but some have to be set by the
% researcher.
%
% In the following example, the first three settings relate to the number
% of lags, the sample for parameter estimation and the frequency of the
% data. The subsequent settings are:
%
% (i) 'selectionY' which defines the endogenous variables in the Model.
% These will be supplied in the order in which they are specified in
% {d.mnemonic}.
%
% (ii) 'forecastSettings.nfor' which defines the (longest) forecasting
% horizon.
%
% (iii) 'simulationSettings.nsave' which defines the number of simulation reps
% used to construct the forecast densities.

m.batch.nlag                                = 2;
m.batch.sample                              = '1985.01 - 2004.03';
m.batch.freq                                = 'q';
m.batch.selectionY                          = {d.mnemonic};
m.batch.forecastSettings.nfor               = 4;
m.batch.simulationSettings.nSaveDraws       = 1000;

%%
% 

%% 5) Running the Model 
% When the state of the batch file is 'true' (you can check this by typing
% 'm.batch.state'), we are ready to run the Model. 

m.runModel
%%
% If the 'm.batch.state' had been false (or the 'm.state' had been false),
% the Model won't run.


%% 6) Looking at the output
% Once the Model has completed estimation and forecasting, 
% 'm.estimation' and 'm.forecasting' are populated with output.

m.estimation
%%
m.forecast
%%
% To obtain graphs and tables etc., use the Report class.  For example, 
% 'Report(m)'.

%% 7) Alternative initalization
% If a batch file 'b' has already been defined, e.g. as:

b = Batchvar;
%%
% and some data 'd' too, the Model object initialization can take the form:

m = Model('var',b,d);