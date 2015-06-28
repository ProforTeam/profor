%% Set Up PROFOR


%% Set up PROFOR
% The PROFOR Toolbox contains MATLAB routines that allow the researcher
% to estimate models, forecast, import forecasts, combine forecasts, and 
% then evaluate forecasts based upon out of sample performance metrics.
%
% The toolbox has to be initialized by the researcher. Make sure that the
% paths required are defined on the MATLAB search path. Place the
% downloaded toolbox in the current directory (of MATLAB). Then, simply
% write in the command window:

proforStartup()

%%
% This operation first restores the matlab default search paths, and then
% adds the required paths for the PROFOR Toolbox.

%% Parallel computing
% The PROFOR Toolbox exploits the parallel computing capabilities within
% MATLAB using its Parallel Computing toolbox. 
% This speeds up computations when looping
% across individual models, when controlling, loading and evaluating
% individual models and when combining forecasts.  Absent the Parallel
% computing toolbox, the run time on many PROFOR computations increases,
% but it still runs. By default, the proforStartup() command starts a
% number of local workers in MATLAB. The number of workers started depends
% on the researcher's MATLAB and computer settings.
%
% For example, by running the following command, the researcher tells PROFOR to
% utilize 2 workers:
nWorkers = 2;
proforStartup(nWorkers)






