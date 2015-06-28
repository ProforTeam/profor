%% Mixture model example
% This script shows how a simple mixture model can be set up and estimated 
% using the Model framework of the PROFOR Toolbox. The data, priors, and
% estimation performed in this example mirrors the example given in Koop
% 2003. 

%%
% See the
% <matlab:edit(fullfile('runArMixtureModelExample.m')) matlab code> 
% corresponding to this help file to run examples directly in MATLAB.
%

%% 0) Generate mixture errors
alfa            = [1.0; 1.0];
h               = [1.0; 1.0];
prob_error      = [0.5; 0.5];
n_simulations   = 20;

y = generateMixtureError(alfa, h, prob_error, n_simulations, 'multinomal')

%% 1) Load data
% First, we load some simulated data, stored as Tsdata objects.
load(fullfile(proforStartup.pfRootHelpData,'mixtureData.mat'));

%% 2) Initializing a Model object
% All individual time series models supported by the PROFOR Toolbox can be
% initialized as follows:
m = Model('barmixture');

%% 3) Setting Tsdata
% Here we supply the model with data. 
m.data = d;


%% 4) Setting the Batch 
% As for other models, we need to specify some batch settings. 
% We use the 3rd element in the loaded Tsdata object as the dependent variable.  
% This corresponds to data generated from a 3 component
% mixture process: y_{t} = e_{t}, where the distribution of the error term
% comes from a three component normal distribution. Setting
% mixtureNormalOnly = true, implies a model of the form: 
% y_{t} = e_{t}
%

m.batch.selectionY                          = {'y3'};
m.batch.sample                              = d(3).getSample;
m.batch.freq                                = 'q';
m.batch.forecastSettings.nfor               = 4;
m.batch.simulationSettings.nSaveDraws       = 5000;
m.batch.simulationSettings.nBurnin          = 1000;
m.batch.simulationSettings.nStep            = 1;
m.batch.mixtureNormalOnly                   = true;

%%
% We also have to set some priors: here we follow the choices used in Koop
% 2003. First, for the particular model specification choosen here, with 
% mixtureNormalOnly = true, some of the tr object properties are not used,
% i.e.: V and T. Still, they have to be
% set...bad...Thus, we simple initialize them as follows: 
%

m.batch.priorSettings.tr.v = 0.01;
m.batch.priorSettings.tr.Q = 1;
m.batch.priorSettings.tr.V = 1;
m.batch.priorSettings.tr.T = 1;
%%
% The priors for the mixture stuff are set in the mix object. Note that the
% sizes used here defines how many components to be estimated
m.batch.priorSettings.mix.p = ones(3, 1);
m.batch.priorSettings.mix.a = zeros(3, 1);
m.batch.priorSettings.mix.V = 10000^2*eye(3);


%% 5) Running the Model 
% When the state of the batch file is 'true' (you can check this by typing
% 'm.batch.state'), we are ready to run the Model. 

m.runModel

%% 6) Run AR(1) mixture
% We can easily estimate a AR(p) model with mixture innovations by setting 
% mixtureNormalOnly = false (which is the default), and specify the appropriate 
% lag length 
m.batch.mixtureNormalOnly       = false;
m.batch.nlag                    = 1;

%%
% Now, we have to update the tr priors. Remember, a constant is
% automatically included
m.batch.priorSettings.tr.V = eye(2);
m.batch.priorSettings.tr.T = zeros(1,2);


%% 
% Running the model with the updated setting
m.runModel


%% 7) Looking at the output
% Once the Model has completed estimation and forecasting, 
% 'm.estimation' and 'm.forecasting' are populated with output.

m.estimation
%%
m.forecast
%%
% To obtain graphs and tables etc., use the Report class.  For example, 
% 'Report(m)'.

