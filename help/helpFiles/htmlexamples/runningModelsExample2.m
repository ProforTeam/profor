%% BVAR Example
% This script shows how a simple BVAR model can be set up and estimated using the 
% Model framework of the PROFOR Toolbox.

%%
% See the
% <matlab:edit(fullfile('runningModelsExample2.m')) matlab code> 
% corresponding to this help file to run examples directly in MATLAB.
%

%% 1) Load data
% First, we load some simulated data, stored as Tsdata objects.
load(fullfile(proforStartup.pfRootHelpData,'varData.mat'));

%% 2) Initializing a Model object
% All individual time series models supported by the PROFOR Toolbox can be
% initialized as follows:
m = Model('bvar');
%%
% Here, the input 'bvar' defines that the researcher wishes to work with a BVAR.
%
% The instance of the BVAR Model class is 'm'. 'm' works as a container for
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
% These will be supplied in the order in which they are specified.
%
% (ii) 'forecastSettings.nfor' which defines the (longest) forecasting
% horizon.
%

m.batch.nlag                                = 1;
m.batch.sample                              = '1985.01 - 2004.03';
m.batch.freq                                = 'q';
m.batch.selectionY                          = {'y1','y2'};
m.batch.forecastSettings.nfor               = 4;

%%
% The simulationSettings defines the number of draws employed to construct
% the posterier etc. The nburn property of simulationSettings defines the
% burn-in. 

m.batch.simulationSettings.nSaveDraws       = 1000;
m.batch.simulationSettings.nBurnin          = 100;

%%
% The priors are set and saved in b.priorSettings. Since the state space
% system is the default, the priorSettings have twoo "fields" .tr and .obs:
% transition equation and observation equation. For a BVAR the obs is redundant,
% so the researcher only needs to care about the .tr "field"
% The .tr "field" has four properties v, V, T, and Q. v is the degress of
% freedom (or weight put on the prior), V is the covariance among the
% parameters of the BVAR (the T matrix), T is the mean of the parameters,
% and Q is the mean of the covariance of the errors. 

m.batch.priorSettings.tr.v = 200;
m.batch.priorSettings.tr.V = diag(repmat(0.05,[6 1]));
m.batch.priorSettings.tr.T = [0 0.9 0;
                              0 0 0.9];
m.batch.priorSettings.tr.Q = [0.5 0;0 0.5];

%% 5) Running the Model 
% When the state of the batch file is 'true' (you can check this by typing
% 'm.batch.state'), the research can run the model. 

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

%% 7) Run the model with a different set of priors
% Above, we estimated the BVAR setting the Normal Whishart priors directly,
% and approximated the posterior using the Gibbs sampler. A more popular
% approach, at least for forecasting, is to use the so called Minnesota
% prior. This can be done by changing the batch settings as below

m.batch.priorSettings.doMinnesota = true;

%%
% That is, we do not need to specify the .tr "fields", but only set 
% doMinnesota = true. The reader with knowledge of the Minnestora prior will 
% recognise the additional options found in the settings for this prior:

m.batch.priorSettings.minnesotaSettings

%% 
% See help MinnesotaPriorSetting for details. Here we continue using the 
% defaults listed above. Note: the Minnesota prior is conjugate, implying
% that the Gibbs sampler isn't required.  
% However, in the toolbox, the Gibbs sample is always invoked in this particular
% class. (Nevertheless, a researcher can create a new conjugate BVAR
% class to circumvent the Gibbs sampler.)
%% 
% Using the priors from the first run:
m.estimation.T.point

%% 
% Running the model again, now with the Minnesota-style priors:

m.runModel

%%
% ...we get:

m.estimation.T.point





