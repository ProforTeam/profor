%% An Example with Reduced Run Time 

%% An Example with Reduced Run Time
% 
% Sometimes the researcher needs to reduce run time.  In particular, when:
%
% - Looking for script errors before the final 'publication' run of PROFOR 
%
% - Updating real-time data with an additional data vintage (no need to
% run over all the vintages again)
%
% - Fine-tuning a report (no need to re-estimate models) e.g. threshold of
% interest for forecast evaluation
% 
% In what follows, the settings for the Bank of England example have been
% modified to improve run speed.
%


clear all; 

p               = Profor;


p.savePath          = fullfile(proforStartup.pfRoot,'help','helpFiles',...
    'htmlexamples', '+results', 'bankOfEnglandExample');


loadDataPath        = proforStartup.pfRootHelpData;


p.modelSetupPath    = fullfile(proforStartup.pfRoot,'help','helpFiles', ...
    'htmlexamples', '+batchFiles', 'bankOfEnglandExample');


d               = loadRealTimeDataFromCsv(20140101, loadDataPath, 'cpi', 'q');
p.data          = d;


b               = Batchvar;
b.nlag          = 1;       
b.selectionY    = {'cpi'};
b.sample        = '1993.01 - 2014.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = { seti };
b.modelName     = 'M1';
b.savePath      = p.pathA;
b.saveo;

b               = Batchexternalanalytic;
b.selectionY    = {'cpi'};
b.sample        = '1993.01 - 2014.01';
b.freq          = 'q';
seti            = DataSetting;
seti.doTransfTo = 0;
b.dataSettings  = { seti };
b.dataPath      = loadDataPath;
b.modelName     = 'M2';
b.savePath      = p.pathA;
b.saveo;

%% 0) Set up the batch for the combination

b                                   = Batchcombination;
b.selectionY                        = {'cpi'};
b.selectionA                        = {'M1', 'M2'};

%% 1) Forecast horizon
%
% If the researcher is interested in long horizons e.g. (h =) 12 steps ahead,
% it is often helpful to set the horizon to one just to check the code in
% preliminary runs to reduce run time.

b.forecastSettings.nfor             = 1;

%% 2) Evaluation/combination sample
%
% Improve run speed by shortening the evaluation sample in the early
% runs while checking that the script runs.  The evaluation sample can be
% increased later (e.g. for the final production run of the script).  In 
% the original example with Bank of England data, the evaluation sample was
%  b.sample                            = '2004.01 - 2014.01';
% reduce to a couple of years when check the script, e.g.

b.sample                                    = '2013.01 - 2014.01';
b.freq                                      = 'q';
b.densityScoreSettings.scoringMethods       = {'logScoreD'};

%% 3) XDomain settings
%
% Since the xDomain controls the ksdensity, run speed can be improved
% by widening the grid points (i.e., a coarser grid). This results in  less
% accurate approximations. Set the
% start and end points close together to avoid redundant range and further 
% improve computational speed (but
% note there is a risk that the density won't integrate to one).
% The original setting was
% b.densityScoreSettings.xDomain                           = {linspace(-5,5,500)'};
% 
% Try, for example: 

b.densityScoreSettings.xDomain                           = {linspace(-4,4,100)'};


%% 4) Number of reps
%
% Set the number of iterates used to construct the empirical densities to a
% low number to boost the run speed.  Again, PROFOR will be less accurate
% so remember to restore the parameter for the final publication run. The
% original Bank of England example had the setting:
%
% b.simulationSettings.nSaveDraws     = 1000;
%
% Try, for example:

b.simulationSettings.nSaveDraws     = 100;


%% 5) Turn of the progress bar
% Showing the progress bar might slow the program down, especially if there
% are many models, iterations etc. Turn it off simply by: 

b.simulationSettings.showProgress   = false;

%% 6) Skip controlling models
% The program automatically loads and checks all individual models prior to
% evaluating them and combining forecasts. This extra control, which is
% intented to capture any errors (that should not be there), takes time.
% However, at the risk of getting some strange errors, you can turn the
% control off. This saves time.

b.controlModels                     = false; 


%% 7) The other needed settings 
% Don't mess with these here as they don't change the run speed!
b.pathA                             = p.pathA;
seti                                = DataSetting;
seti.doTransfTo                     = 0;
b.dataSettings                      = {seti};
b.savePath                          = p.pathA;
b.saveo;

%% 8) Estimation, then combination
%
% First, do the estimation and forecasting of the models.  But only do the
% combination/evaluation in the subsequent runs.  
%
% To do this, run Profor with doCombination = false initially. That is,
% turn off the combination and evaluation on the first run.
%
% Then, when all models are done, set doCombination = true, doModels =
% false, and p.onlyDoLast = true. The last one ensures that combination
% will not be done recursively, only for the last vintage: handy if for
% example you already have all the results for earlier vintages, but just
% got data updated with one vintage!
%
% For first run only (comment out for second run), insert: 
%
% doCombination = false;
%
% Second run only (comment out for first run):
%
 
doCombination   = true;
doModels        = false; 
p.onlyDoLast    = true;

p.runProfor;

