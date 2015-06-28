function constructAndStoreBatchFilesSimulatedDataExample(saveBatchPath)
%% Constructing batch files for a Profor experiment with rolling windows

%%
% This function defines several batch objects: three for individual models,
% and one for the combination. All batch files are saved to a directory
% defined saveBatchPath.
%
% In this example, simulated data are used to estimate the models. The
% `true' DGP is a VAR with four lags, VAR(4). The models estimated are:
% an AR(1), a BVAR (where the priors are set to the true parameters), 
% and a BVAR with time-varying parameters and stochastic volatility.
% 
% The combination uses a rolling window to compute the weights. See the setting
% of the batch file for the combination below.
%
% See the description in constructAndStoreBatchFilesExample for more
% detailed information. 
%
% Note that with these batch files in the experiment defined
% in proforExampleSimulatedData, where data are supplied directly to the
% Profor object, no loadDataPath statements are required in the individual
% batch files. 
%

%% Prelim 
%
% Load the data with the true parameters:

B = load(fullfile(proforStartup.pfRootHelpData,'varData.mat'));

%% 1) AR(1)

b               = Batchvar; 
b.nlag          = 1;        
b.selectionY    = {'y1'};            
b.sample        = '1983.01 - 2004.04'; 
b.freq          = 'q'; 

%%
% Set the transf property of the data = 0, meaning no
% transformation. This gives the researcher scope to evaluate the 
% forecasts using various transformations.
% See setting of Batchcombination below.

seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = {seti};

b.modelName     = 'M1';
b.savePath      = saveBatchPath;
b.saveo;

%% 2) BVAR

b               = Batchbvar;
b.nlag          = 4;
b.selectionY    = {'y1','y2','y3','y4'};
b.sample        = '1983.01 - 2004.04';
b.freq          = 'q';

%% See AR(1) above:
%
seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = {seti,seti,seti,seti};

%%
% Apply very tight priors around the true parameters:

b.priorSettings.tr.v = 300;
b.priorSettings.tr.V = diag(repmat(0.001,[(4*4+1)*4 1]));

b.priorSettings.tr.T = B.beta;
b.priorSettings.tr.Q = B.sigma;

%%
% The simulationSettings define the number of draws employed to construct
% the posteriers. The nburn property of simulationSettings defines the
% burn-in:

b.simulationSettings.nBurnin = 100;

b.modelName     = 'M3';
b.savePath      = saveBatchPath;
b.saveo;

%% 3) BVARTVPSV

b               = Batchbvartvpsv;
b.selectionY    = {'y1'};
b.sample        = '1983.01 - 2004.04';
b.nlag          = 1;
b.freq          = 'q';

%% 
% Gibbs settings:
%
b.simulationSettings.nSaveDraws     = 1000;
b.simulationSettings.nBurnin        = 100;
b.simulationSettings.nStep          = 1;

%%
% See AR(1) above:

seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = {seti};


%%
% Set priors based on `true' parameters
% Here B.sigma is the residual covariance matrix of the VAR

[Sigma_ols, A0_ols] = resamplingFns.getSigmaAndA0( B.sigma ); 

%%
% A0 is not used for an AR model (always = 1). Thus, all the priors are set
% to nan 

b.priorSettings.a0s.a0        = nan;
b.priorSettings.a0s.p0        = nan;
b.priorSettings.a0s.v         = nan;
b.priorSettings.a0s.S         = nan;

%% 
% SIGMA 

b.priorSettings.sigmab.a0     = Sigma_ols(1,1);
b.priorSettings.sigmab.p0     = 10;
b.priorSettings.sigmab.v      = 100;
b.priorSettings.sigmab.S      = 1./100;

%% 
% TG

b.priorSettings.tg.a0     = B.beta(1, 1:2)';
b.priorSettings.tg.p0     = eye(numel(b.priorSettings.tg.a0)).*5;
b.priorSettings.tg.v      = 100;
b.priorSettings.tg.S      = eye(numel(b.priorSettings.tg.a0))./100;

b.modelName     = 'M4';
b.savePath      = saveBatchPath;
b.saveo;

%% 4) Combination

b                                   = Batchcombination;
b.selectionY                        = {'y1'};
b.selectionA                        = {'M1', 'M3', 'M4'};
b.forecastSettings.nfor             = 4; 
b.sample                            = '1995.01-2004.01';
b.freq                              = 'q';

%% 
% This defines the location of the batch files for the
% individual models. I.e., the same path used above to save the individual
% batch files. 

b.pathA                             = saveBatchPath;

%% 
% Define a scoring method (this can be updated after having run the model)

b.densityScoreSettings.scoringMethods = {'logScoreD'};
%% 
% Define the xDomainLength. The xDomainLength defines the length of the 
% xDomain on which the densities should be approximated using the empirical 
% densities. The program uses the built-in Matlab ksdensity function to do this. 
% The program needs to do this to generate the density scores 
% (and to combine the density forecasts). If an xDomain isn't specified, 
% PROFOR automatically defines one. 
% Note: More grid points (i.e., a finer grid), results in better approximation 
% (but be sure to choose the start and end points well. If not, the pdfs might
% not integrate to 1). Also, a larger domain requires more memory and takes 
% longer to compute. 
% The default xDomainLength is 500. By not defining a xDomain, the program
% automatically generates one, but now with 1000 as its length. 

b.densityScoreSettings.xDomainLength  = 1000;

%%
% Set the rolling window option to be true. This indicates that the weights
% should be computed over a rolling window.

b.isRollingWindow                   = true;

%%
% When this is true, the trainingPeriodSample controls
% the length of the rolling window.
b.trainingPeriodSample              = '1995.01 - 2000.01';

%%
% Which in this case is 5 years. The training sample  must be a subset
% of the sample vintages specified in the batch combination. In this
% example, the weights for vintage 2000.01 will be based on the scores
% from data vintages 1995.01 - 2000.01. Then, in data vintage 2000.02, scores
% from vintages 1995.02 - 2000.02 will be used to construct weights etc.
%
% Define the number of simulations to be used for constructing densities:

b.simulationSettings.nSaveDraws     = 1000;

%%
% The PROFOR toolbox allows the researcher to estimate the models using one
% transformation, but then evaluate the forecasts using a different type of
% transformation. In the individual models, transf = 0, but below the researcher 
% could select the growth rate, by swapping the 0 to a 3, or 'gr', in the
% script:

seti                                = DataSetting;
seti.doTransfTo                     = 0;
b.dataSettings                      = {seti};

b.savePath      = saveBatchPath;
b.saveo;

