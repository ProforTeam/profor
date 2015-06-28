%% PROFOR experiment with real-time Data

%% 
% This script defines a PROFOR experiment with real-time data.
% There are three models in the example, including a Bayesian VAR.  
% All are estimated recursively, and then evaluated and combined, recursively. 
%
% First, go to the directory where PROFOR is installed, and initialize the
% toolbox. Run:

proforStartup(2)

%%
% The input 2 attributes 2 workers to this PROFOR session. Once
% 'proforStartup' has executed, run an experiment.
%%
% See the
% <matlab:edit(fullfile('proforExample.m')) matlab code> 
% corresponding to this help file to run examples directly in MATLAB.
%

%% 1) Initialize Profor instance
%
% Create a Profor instance: 
%

p               = Profor;


%% 2) Set the path locations for PROFOR 
%
% To run the experiment, supply the instance with two directories:
%
% 1) 'p.savePath': location to save results; and  
%
% 2) 'p.modelSetupPath': location of batch files. 
%
% These paths can be anywhere on the reseacher's computer, but preferably
% not in the same folder as the PROFOR toolbox codes.
%
% Set the directory in which to store the results:

p.savePath      = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+results','resultsProfor');
%%
% Set the data path:

loadDataPath    = proforStartup.pfRootHelpData;

%%
% This path is automatically constructed by the PROFOR instance below 
% (if it does not exist).
%
% Set the directory where the model setup files reside:

p.modelSetupPath = fullfile(proforStartup.pfRoot,'help','helpFiles','htmlexamples','+batchFiles','batchFilesProfor');

%% 3) Construct batch files
% 
% Construct a batch file for each model, and another for the combination.
%
% The batch files that will be created in
% 'constructAndStorebatchFilesExample', allow for different types of models
% (such as VARs, BVARs, etc) and for different model combinations. The
% batch files specify the priors where appropriate.
%
% In the example, these batch files are constructed in a function:

constructAndStoreBatchFilesExample(loadDataPath, p.pathA);

%%
% To see how the various batch files are constructed you can naviagate to 
% <./constructAndStoreBatchFilesExample.html Constructing The Batch Files>.

%% 4) Run PROFOR
% 
% When the two paths have been defined and set, run PROFOR.
% 
% This command will load each batch file (for the individual models),
% and estimate the parameters of the model over the available 
% sample and forecast each model recursively through the defined
% out of sample period. The out of sample period for the recursions are
% determined by the batch file for the combination (even if the researcher
% isn't interestd in the combination).
p.runProfor;

%% 5) Output and results
% 
% Use the in-built report functionality to explore the results. See the
% help script:
help Report;
%%
%
% See <matlab:edit(fullfile('makingReportsExample.m')) matlab code> 
% for a help file on how to make a report after running this example.
