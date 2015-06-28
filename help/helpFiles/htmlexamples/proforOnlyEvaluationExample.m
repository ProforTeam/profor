%% Work with Ragged Edge Data
% This script shows how to use a PROFOR experiment for one model with
% ragged edge data. Since, the combined forecast and individual model
% forecast are the same, running a PROFOR experiment will estimate the
% individual model recursively, and then evaluate its forecast performance.
%
% See the <./proforExample.html PROFOR Example> for background information.
%
%%
% See the
% <matlab:edit(fullfile('proforOnlyEvaluationExample.m')) matlab code> 
% corresponding to this file to run the example directly in Matlab.
%
%% 1) Initialise PROFOR
%
% Initialise the profor object:
p               = Profor;

%% 2) Set the path locations for PROFOR

% Set the directory in which to store the results:
p.savePath      = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+results','resultsOnlyEvaluation');
%%
% Data location:
loadDataPath     = proforStartup.pfRootHelpData;
%%
% Set the directory where the the model setup files reside:
p.modelSetupPath = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+batchFiles','batchFilesOnlyEvaluation');

%% 3) Construct a batch file for a model
% Model is VAR(4):

b               = Batchvar;
b.nlag          = 4;
%%
% The second time series  contains a ragged edge relative to gdp. The
% program handles this: for gdpctpi_missingValues, some of the forecasts made at
% particular vintages will be conditional forecasts.
b.selectionY    = {'gdp', 'gdpctpi_missingValues'};
b.sample        = '1980.01 -2010.01'; 
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 3;
b.dataSettings  = {seti, seti};
b.dataPath      = loadDataPath;

b.modelName     = 'M2';
b.savePath      = p.pathA;
b.saveo;

%% 4) Construct a batch file for the combination
% No combined forecast will be made, but the combination batch is
% still used to run the model recursively, and evaluate the model performance.

b                                   = Batchcombination;
b.selectionY                        = {'gdpctpi_missingValues'};
b.selectionA                        = {'M2'};
b.forecastSettings.nfor             = 4;
b.sample                            = '2000.01-2004.01';
b.freq                              = 'q';

b.densityScoreSettings.scoringMethods = {'logScoreD'};

b.simulationSettings.nSaveDraws     = 1000;
b.simulationSettings.showProgress   = false;

b.pathA                             = p.modelSetupPath;
b.dataPath                          = loadDataPath;

seti                                = DataSetting;
seti.doTransfTo                     = 3;
b.dataSettings                      = {seti};

b.savePath      = p.pathA;
b.saveo;

%% 5) Run PROFOR
% When the two paths have been defined and set, run Profor.
% This command will then load each batch file (for the individual models), and 
% estimate and forecast each model recursively through the defined sample. The 
% sample, and other specific settings for the recursions are determined by the 
% batch file for the combination.
p.runProfor;

%% 6) Check output
% No output is stored in p. prunProfor gives only information about the state of 
% the program, i.e., if everything worked as intented or not.

% To access output, either go to the output folder directly (defined by
% saveResultPath), or run Report(p)