function write2Tsdata(in_data, dataPath, mnemonic, start_date, n_periods, freq)
% write2Tsdata Writes in_data to Tsdata format.
%   The corresponding dates are taken from the start_date onwards at the given
%   frequency for n_periods.
%
%
% Input:
%   in_data         [numeric] - 
% 	dataPath        [str]     - location to save Tsdata object.
% 	mnemonic        [str]     - name of variable.
%   start_date      [numeric] - Must be of format YYYYMMDD
%   n_periods       [numeric] - Number of periods for vintages
%   freq            [str]     - Frequency of period.
%
% Usage:
%   outTable = write2Tsdata(in_data, dataPath, mnemonic, start_date, ...
%                           n_periods, freq)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Copyright (C) 2014  PROFOR Team
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Validation
errType = ['loadSaveUtilityFns:', mfilename ];

assert(strcmpi(freq, 'q'), errType, 'NotImplementedError: Only quarterly freq');

% Set freq_number for generation of quarterly data.
freq_number = 4;

% TODO: Check inVintageDate of YYYYMMDD format.
if ~isnumeric(start_date)
    error(errType, 'start_date date has to be double')
end

if numel(num2str(start_date)) < 8
    error([errType, 'The start_date should be of YYYYMMDD format'])
end

%% Initialisation
% Generate filename 
fileName     = [mnemonic '_empiric.csv'];

%% Generate dates from start_date, n_periods, and eventually freq.

% Get 2 different forms of the start_date
start_date_yyyynn = str2DateYYYYNN( num2str(start_date), {'yyyymmdd', 'yyyy-mm-dd', ...
    'dd.mm.yyyy'}, freq);
start_date_datenum = str2Datenum( num2str(start_date), {'yyyymmdd'});

% Use Matlab's datenum form to get the start year and end.
[bYear, ~, bPeriod, ~] = convertMadToNum(start_date_datenum, ...
    start_date_datenum, freq);

% Generate the n_period dates from start_date onwards.
dates_yyyynn =  csttt(bYear, bPeriod, n_periods, freq_number);

%% Make Tsdata object to store.

d = Tsdata(dates_yyyynn, in_data, freq, mnemonic);

save( savePathFile, 'd')


%% Save Tsdata 
saveFilePath = fullfile(dataPath, fileName);


end
