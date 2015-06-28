%% Import External Forecasts, Bank of England Example

%% Import External Forecasts, Bank of England Example
% This example shows how to use external analytic forecasts. The researcher
% imports the key parameters of the Bank of England's two-piece Normal
% forecast densities for inflation. These are compared with the forecasts
% from an AR(1) benchmark.  Note that a report can be constructed to
% display a selection of forecast evaluation metrics.

clear all; 
%% 1) Initialize 
% Initialize the Profor object:

p               = Profor;

%% 2) Set the path locations
% Set the directory to store the results:

p.savePath          = fullfile(proforStartup.pfRoot,'help','helpFiles',...
    'htmlexamples', '+results', 'bankOfEnglandExample');


%%
% Set the directory where the model setup files will reside:

p.modelSetupPath    = fullfile(proforStartup.pfRoot,'help','helpFiles', ...
    'htmlexamples', '+batchFiles', 'bankOfEnglandExample');

%%
% Set the directory to load the data: In this experiment we use CPI data,
% and load it directly into the p object. There are no data revisions in the CPI
% so no reason to use real time data in the evaluation - just load the most 
% recent vintage of data:

loadDataPath    = proforStartup.pfRootHelpData;
d               = loadRealTimeDataFromCsv(20140101, loadDataPath, 'cpi', 'q');
p.data          = d;

%% 3) Construct batch file for AR(1) benchmark, then another for BOE forecasts
% Note that the sample commands set the start and end observations for
% parameter estimation in the case of the AR(1).  The BOE forecasts require
% no estimation and the sample dates here just specify the forecast target
% dates.  The BOE forecasts are one step ahead here.

b               = Batchvar;
b.nlag          = 1;       
b.selectionY    = {'cpi'};
b.sample        = '1993.01 - 2014.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = { seti };
b.modelName     = 'M1';
b.savePath      = p.modelSetupPath;
b.saveo;
%%
% Next, import the external forecasts from the BoE using the External
% Analytic batch. Note that we here need to specify a path for the data -
% namely the path to the external forecast data (for convenience these are
% in this experiment placed in the same folder as used above, but they do
% not have to be!): 

b               = Batchexternalanalytic;
b.selectionY    = {'cpi'};
b.sample        = '1993.01 - 2014.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = { seti };
b.dataPath      = loadDataPath;
b.modelName     = 'M2';
b.savePath      = p.modelSetupPath;
b.saveo;

%% 4) Construct a batch file for the combination and evaluation 
% (Even though the researcher won't use the combination here.)  Note that
% the sample command in the combination batch refers to data vintages.  With a
% one-period lag in the publication of macro data, the forecast origins are
% therefore 2003.04 through 2013.04. With one step ahead forecasts in this
% example, the forecast targets are therefore 2004.01 through 2014.01.

b                                   = Batchcombination;
b.selectionY                        = {'cpi'};
b.selectionA                        = {'M1', 'M2'};
b.forecastSettings.nfor             = 1;
b.sample                            = '2004.01 - 2014.01';
b.freq                              = 'q';


%%
% Set the method to score the densities, e.g the average log score over the
% out of sample evaluation period (defined by the forecast targets):

b.densityScoreSettings.scoringMethods                    = {'logScoreD'};

%%
% Now define the xDomain over which the densities will be approximated.
% PROFOR uses the built-in Matlab ksdensity function to do this. More grid
% points (i.e., a finer grid) results in better approximations. Set the
% start and end points far apart to be sure that the mass integrates to 1.
% But, a larger spread in the domain has a cost in terms of computational speed.

b.densityScoreSettings.xDomain                           = {linspace(-5,5,500)'};

%%
% Set the number of iterates used to construct the empirical densities:

b.simulationSettings.nSaveDraws     = 1000;
b.simulationSettings.showProgress   = false;

%%
% Define some paths and settings for the Profor stage:

b.pathA                             = p.modelSetupPath;
seti                                = DataSetting;
seti.doTransfTo                     = 0;
b.dataSettings                      = {seti};
b.savePath                          = p.modelSetupPath;
b.saveo;

%% 4) Run Profor
% When the paths have been defined and set, run Profor stage. This loads
% each batch file (for the individual model and external forecasts), and
% then estimates the model parameter (if necessary).  PROFOR constructs the
% forecasts recursively through the evaluation sample. 

p.runProfor;

%% 5) Check output
% No output is stored in p. It tells the researcher whether 
% everything worked as intended or not.

% To access output, go to the output folder directly (defined by
% saveResultPath). Or construct a Report(p).




