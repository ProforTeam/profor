function constructAndStoreBatchFilesExample(loadDataPath, saveBatchPath)
%% Constructing  batch files for a Profor experiment

%%
% This function defines three batch objects for three individual models. 
% The script also defines a batch file for model combination. All batch files are
% saved to a directory defined by saveBatchPath.
%
% Each batch object also contains a path identifier for where the model can 
% find data. This is defined by loadDataPath.
%
% This function is an example. The researcher can construct batch files
% for any supported model directly in the MATLAB workspace, or in
% any function desired. In the PROFOR toolbox there are also functions
% that produce a number of batch files and saves them to disk. See 
% CommonFunctions/+constructModels. These functions are useful for constructing
% many batch files in one go, e.g., many VARs with differing lag 
% structures and combinations of variables. 
%
% The important point to remember is that all models that are to be
% included in a PROFOR experiment must be saved to the same directory,
% e.g., saveBatchPath. 
%
% Also, before saving the batch objects it might be a good idea to check
% that the state of the batch is ok. The command b.state allows the researcher to 
% checks that all settings are internally consistent. If b.state is
% true, the batch object is ready to be used for estimation, forecasting
% etc. 


%% 1) AR(1)
%
% First, construct a simple AR(1) batch file, i.e., construct an instance of 
% the VAR batch class:

b               = Batchvar; 
%%
% Define number of lags:

b.nlag          = 1;        

%%
% Define which variable to include in the model. This variable must be
% found as a separate .csv file in the loadDataPath directory. With 
% selectionY a cellstr with one element, this will be an
% AR(1)

b.selectionY    = {'gdp'};            

%% 
% This is the estimation sample. When the model is recursively estimated,
% the start date will be kept, but the end date truncated according to the
% settings for the combination batch.

b.sample        = '1950.01 -2010.01'; 
b.freq          = 'q'; 

%%
% Data settings
%
% These settings can be skipped, but if the data are to be transformed in real
% time, i.e., at each iteration, it is required. DataSetting is a
% class that defines some simple transformation that can be applied to the
% data: 
%
%    transf                     = log differences, growth rates etc. 
%
%    sesAdj                     = to seasonally adjust or not
%
%    trendAdj                   = to trend adjust or not
%
%    conversion and convertTo   = to construct lower frequency variables from 
%                               higher frequency  
%
% The batch object needs one instance of the DataSetting class for each of
% the variables in selectionY. Each instance is stored in the cell
% b.dataSetting:

seti            = DataSetting;
seti.doTransfTo = 3;
b.dataSettings  = {seti};

%%
% File path to find the real time data for gdp (stored as a .csv file):

b.dataPath      = loadDataPath;
%%
% Finally, save the b instance to disk, and give it a name (must be
% unique):

b.modelName     = 'M1';
b.savePath      = saveBatchPath;
b.saveo;

%% 2) VAR(4) 
%
% This does the same as above, but now for a bivariate VAR(4):

b               = Batchvar;
b.nlag          = 4;
b.selectionY    = {'gdp','gdpctpi'};
b.sample        = '1950.01 -2010.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 3;
b.dataSettings  = {seti,seti};
b.dataPath      = loadDataPath;
b.modelName     = 'M2';
b.savePath      = saveBatchPath;
b.saveo;

%% 3) BVAR
%
% The final indiviudal batch object is a BVAR. Most of the settings and
% descriptions from above apply, but now define some
% priors:
b               = Batchbvar;
b.nlag          = 1;
b.selectionY    = {'gdp','gdpctpi'};
b.sample        = '1950.01 -2010.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 3;
b.dataSettings  = {seti,seti};
b.dataPath      = loadDataPath;

%%
% The priors are set and saved in b.priorSettings. The priorSettings 
% have two "fields" .tr and .obs -- for the transition equation and 
% observation equation. For a BVAR the .obs is redundant,
% so the researcher only needs to care about the .tr "field"
% The .tr "field" has four properties v, V, T, and Q. The parameter
% v is the degress of freedom (or weight put on the prior), V is the 
% covariance of the parameters, T is the mean of the parameters,
% and Q is the mean of the covaraince of the errors. 

b.priorSettings.tr.v = 200;
b.priorSettings.tr.V = diag(repmat(0.05,[6 1]));
b.priorSettings.tr.T = [0 0.9 0;
                        0 0 0.9];
b.priorSettings.tr.Q = [0.5 0;0 0.5];
%%
%
% The simulationSettings defines the number of draws employed to construct
% the posterier etc. The nburn property of simulationSettings defines the
% burn-in. 

b.simulationSettings.nBurnin = 100;
b.modelName     = 'M3';
b.savePath      = saveBatchPath;
b.saveo;


%% 4) Combination
%
% Now, the combination file. The batch file for the combination 
% defines which models to evaluate and combine, and which variables to evaluate 
% and combine.  

b                                   = Batchcombination;

%%
% Define two variables to evaluate and combine. Note that the
% combination, when executed, is applied to one variable at a time. So,
% M1 above do not use "gdpctpi". This is ok, PROFOR adjusts to
% this, and uses only M2 and M3 when evaluating and combining "gdpctpi"

b.selectionY                        = {'gdp', 'gdpctpi'};
b.selectionA                        = {'M1', 'M2','M3'};

%%
% Define the number of horizons to evaluate the forecast and to produce
% a combined forecast for:

b.forecastSettings.nfor             = 4; 

%%
% This defines the sample over which the weights should be estimated.
% The individual models are estimated recursively over this sample, then
% evaluated and used in the combination to construct weights,
% scores and a forecast. The out-of-sample forecast will then start for the
% vintage 2004.01.

b.sample                            = '2000.01-2004.01';
b.freq                              = 'q';

%%
% This defines where the program can find the batch files for the
% individual models. The same path used above to save the individual
% batch files. 

b.pathA                             = saveBatchPath;

%%
% Define a scoring method (this can be updated also after having run the
% model):

b.densityScoreSettings.scoringMethods   = {'logScoreD'};

%%
% Set the event thresholds for the Brier Score and economic loss
% evaluations.  If none are provided the default setting is the
% unconditional mean of the estimation period.

b.brierScoreSettings.eventThresholdValue  = [0.75, 1.0, 1.25, 1.5];


%%
% Define the number of simulations to be used for constructing densities:

b.simulationSettings.nSaveDraws     = 1000;
b.simulationSettings.showProgress   = false;
b.dataPath                          = loadDataPath;
seti                                = DataSetting;
seti.doTransfTo                     = 3;
b.dataSettings                      = {seti,seti};
b.savePath      = saveBatchPath;
b.saveo;

