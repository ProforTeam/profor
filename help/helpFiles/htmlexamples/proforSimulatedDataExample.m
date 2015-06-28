%% PROFOR experiment with rolling windows
% This script defines a PROFOR experiment where two models are estimated 
% recursively, and then evaluated and combined, recusively.
%
% See the example proforExample for general information. Two differences between 
% this example and the one described in proforExample are that here, the reseacher
% uses simulated data and rolling windows for combinations.
%
% The data are supplied directly to the Profor object below (instead of 
% reading from a file, as in 
% <./proforExample.html PROFOR Example>
% ).
%%
% See the
% <matlab:edit(fullfile('proforSimulatedDataExample.m')) matlab code> 
% corresponding to this help file to run this example directly in MATLAB.
%

%% 0) Initialise Profor
%
% Initialize the profor object:

p               = Profor;

%% 1) Set the path locations for profor 
%
% Set the directory in which to store the results:

p.savePath      = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+results','resultsSimulatedData');

%%
% Set the directory where the model setup files reside:

p.modelSetupPath = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+batchFiles','batchFilesSimulatedData');

%% 2) Construct batch files
% Batch files for the experiment have to be constructed:

constructAndStoreBatchFilesSimulatedDataExample( p.pathA );

%%
% To see how the various batch files are constructed -- in particular, the batch
% combination with rolling windows, navigate to 
% <./constructAndStoreBatchFilesSimulatedDataExample.html Constructuing The Batch Files>.

%% 3) Load data
% In this case, load simulated data:

load(fullfile(proforStartup.pfRootHelpData,'varData.mat'));
%%
% The data will still be transformed based on the settings in the
% individual batch files (when running the codes recursively). Note that
% PROFOR treats the sample (set in the batch for combination) as a real time 
% vintage. When estimating the parameters recursively, the data will be
% truncated such that in each vintage dated t, the last observation 
% will be t-1. 

p.data = d;

%% 4) Run experiment
% The Profor command will then load each batch file (for the individual models), 
% estimate and forecast each model recursively through the defined sample. The 
% sample, and other specific settings for the recursions are determined by the 
% batch file for the combination.

p.runProfor;

%% 5) Output
% No output is stored in p. This has information about the state
% of the program only, i.e., if everything worked as intended or not. 
%
% To access output, either go to the output folder directly (defined by
% saveResultPath), or run Report(p).




