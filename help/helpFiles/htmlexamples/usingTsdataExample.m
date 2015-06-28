%% Read in Data and Use Tsdata Instances  
%
% This script shows how to read in data and define a Tsdata object. 
% Understanding how time series data are stored and used with the 
% Tsdata class is essential for efficient use of the PROFOR Toolbox.
%
% See the
% <matlab:edit(fullfile('usingTsdataExample.m')) matlab code>
% corresponding to this help file to run examples directly in Matlab.
%  

%% 1) Data inputted directly (on the fly) into MATLAB
%
% Input some data and then make the Tsdata object.
% The 'flydata' vector could be typed in at the command prompt >>
% or cut and pasted from a column in a spreadsheet.
%%

flydata = [1.0 2.0 3.5 1.2 2.3 3.1 0 0.5]';

%% 
% Assign frequency and dates as shown below. (The date convention used in
% the toolbox was originally suggested by Christie Smith.)
%
% (i) freq: we set the frequency to be quarterly by 'q', but it could be
% monthly 'm' or daily 'd'.
%
% (ii) dates: in the example below we read in data starting 2000 ending
% 2001, where in 2000 the first observation is quarter 1 and in 2001 the
% last observation is quarter 4. In total there are 8 observations, as
% inputted above in 'flydata'. The term 'freq' is a standard required input.
%%

freq        = 'q';
dates       = latttt(2000,2001,1,4,'freq',freq);

%%
% For more information on latttt, type 'help latttt'. The resulting
% output is shown below.
%%

help latttt

%% 2) Reading data from a spreadsheet
%
% Use MATLAB's 'xlsread' command.  For more information, type in 'help
% xlsread'. Note: some researchers have found issues with the xlsread command
% -- might be wise to google search on that. The resulting output is shown
% below.
%%

help xlsread

%%
% First, use the file path command, 'filePath', to point to where the data
% are stored on the computer. In this case,
%%

filePath = 'demots.xlsx'

%% 
% In the xlsread example shown below:
%
% (i) 'demots.xlsx' is an Excel file with 11 rows and 3 columns in Sheet 1.
% Column 1 contains the dates, which we do not use here. Column 2, row 1,
% contains the name "Inflation", then data for the remaining rows. Column
% 3, row 1, contains the name "GDP growth" and then data for the remaining
% rows.
%
% (ii) 'data' is defined over column 2 through to the end, as in this
% instance the Excel file has dates in the first column.
%
% (iii) 'mnemonic' uses the first row of the Excel file where the names are
% stored (the first number in the brackets: 1), and ignores the first
% column as it contains dates (ie 2:end).
%%

[X, txt]    = xlsread( fullfile(proforStartup.pfRootHelpData, filePath), 'Sheet1');
data        = X(:,2:end);
mnemonic    = txt(1,2:end);

%%
% Here use 10 quarterly observations from 1990.01 through 1992.02.
% (Switch to 'm' for monthly, etc.) 
%%

dates       = latttt(1990,1992,1,2,'freq','q');

%%
% Define the time series object, 'd', and then define d1 (the first column
% of 'data') as 'inflation'. The output for 'd1' is shown below.
%%

d   = Tsdata(dates,data(:,1),'q', mnemonic{1});
d1  = d(1)

%%
% The following command picks up just GDP growth (the second
% column of 'data').
%%

dd = Tsdata(dates,data(:,2),'q', mnemonic{2});

%%
% This line picks up both variables:
%%

d = [d Tsdata(dates,data(:,2),'q',mnemonic{2})];


%% 3) Reading mixed frequencies from the same spreadsheet
%
% Suppose the quarterly data from demots.xlsx are already loaded
% (see previous case). Now add some monthly data on the
% interest rate contained on Sheet 2.
%
% Define 'filePath' first eg, filePath = 'demots.xlsx'.
% 
% Note: Sheet 2 in 'demots.xlsx' contains 25 rows and 2 columns. Column 1
% contains the dates, which we are not used here. Column 2, row 1, contains
% the name "interestrate", then data for the remaining rows.
%%

[X,txt]     = xlsread(fullfile(proforStartup.pfRootHelpData, 'demots.xlsx'), 'Sheet2');
data        = X(:,2:end);
mnemonic    = txt(1,2:end);

%%
% Use the 'dates' function to generate a dates vector as shown below. In
% this example, the researcher reads in monthly data starting in 1990,
% month 1 and ending in 1991, month 12. Define the time series object,
% 'dm', as the first column:
%%

dates       = latttt(1990,1991,1,12,'freq','m');
dm          = Tsdata(dates,data(:,1),'m',mnemonic{1});

%% 
% Next, stack all the data together, ie the quarterly data contained in 'd'
% and the monthly data contained in 'dm'.  This is shown below:
%%

d = [d dm]

%% 
% To stack the quarterly variables in a  matrix format
% (perhaps for a subsequent estimation step) use 'selectData'. 'outData'
% gives the data; 'sampleDates' shows the associated dates.
%%

[outData, sampleDates]      = selectData(d, {'GDP growth','inflation'}, 'q', '1990.01 - 1992.02')

%%
% If the specified sample in 'selectData' is longer than the available
% data, PROFOR gives NaN values. In the following example, the end of the
% sample is 2 quarters longer than the available data.
%
%%

[outData2, sampleDates2]    = selectData(d, {'GDP growth','inflation'}, 'q', '1990.01 - 1992.04')

%%
% For more information on selecting variables type 'help
% Tsdata.selectData'.

%%

help Tsdata.selectData

%% 4) Examining the data 
%
% a) To check the frequency of the data (recall, d1 is the inflation rate):
%%

d1 = d(1) 
d1.freq

%% 
% b) To check the data sample:
%%

d1.getSample

%% 
% c) Other properties of the data can be explored using the options
% available under the 'properties' command. The list of options is shown
% below.
%%

properties(d1)

%%
% d) Plotting the data. The 'plot' command will call the built in plot
% function of the Tsdata class, and plot the time series in 'd' - one
% variable at a time. Note, press a tab on the keyboard
% to move from one plot to the next.  To plot d1, inflation, over
% time:
%
d1.plot

%%
% e) The data and dates are stored and can be accessed using the
% following command:
%%
d1_original = [d1.getDates d1.getData];

%%
% f) Further information is available from the 'help' command:
%%

help Tsdata

%% 5) Load data generated within PROFOR
%
% Suppose the researcher has simulated some data from a VAR model, and
% stored the simulated time series as a Tsdata object. Load the file
% containing these time series using the standard MATLAB 'load' command.
%%

load( fullfile( proforStartup.pfRootHelpData, 'varData.mat') )

%%
% Note: proforStartup.pfRoot points to the root directory of PROFOR.
%
% The object 'd' is of a Tsdata class, size 1 x 4 ie we have a Tsdata
% object that contains 4 different time series (dates, inflation, GDP
% growth and the interest rate).
%
% Define:
%%

d1 = d(1);
%%
% This constructs  a new Tsdata object, d1, which only contains the first
% time series object in 'd'.


%%
% The class is defined as:
%%

class(d1)

%%
% The methods associated with the class are given by:
%%

methods(d1)


%% 6) Tsdata with many time series
%
% The 'd' object loaded above contained 4 time series. (Above only the
% first variable was used.) Get the varaible names:
%%

{d.mnemonic}
%%
% Next, get the transformations (none, in this example):
%%

{d.transfState}
%%
% Then, check the time series observations for which there are data:
%%

{d.getSample}
%%
% Plot the variables named y2 and y3:
%%

d.plot({'y2','y3'})

%%
% Then extract the data into standard MATLAB matrices:

[outData, sampleDates, selectionChar, transf] = ...
    selectData(d,{d.mnemonic},'q','2000.01 - 2003.01')


%% 7) Data generated within MATLAB
%
% The following commands generate a data vector, (8x1), within MATLAB, 
% using a normal distribution. Then, define a Tsdata object. (The
% other commands used here are explained in the examples above.)

%%

data        = randn(8,1);
freq        = 'q';
mnemonic    = 'myData'; 
dates       = latttt(2000,2001,1,4,'freq',freq);
d = Tsdata(dates,data,freq,mnemonic);



%%
% Alternatively, we simulate an AR1 (using the MATLAB econometric toolbox
% arima). Label the resulting reps as different variables. For more details
% on the arima toolbox see
% http://www.mathworks.co.uk/help/econ/simulate-stationary-arma-processes.html
%
% First, check that the toolbox is installed! Then, define the arima
% process to be simulated:
%%

model = arima('Constant',0.5,'AR',{0.7},'Variance',.1);

%%
% Next set the number of reps (we use 100) and fix the random number
% generator with rng('default'), then simulate:
%%

nreps=100;
rng('default')
data = simulate(model,224,'NumPaths',nreps);

%%
% Burn the first 100 draws:
%

data = data(101:end,:);

%%
% Now define the Tsdata object in PROFOR. Extract the first 5 variables
% (reps, of 100) and print them on the screen.
%%

freq    = 'q';
dates   = latttt(1984,2014,1,4,'freq',freq);
d = [];
for ii = 1 : nreps
    vblName = sprintf('vbl_%d', ii);
    d = [d Tsdata(dates, data(:, ii),'q', vblName)];
end
ds15 = [d(1) d(2) d(3) d(4) d(5)];

ds15(:,1:2)


%% 
% For more information, type: 
%%
help Tsdata.Tsdata
