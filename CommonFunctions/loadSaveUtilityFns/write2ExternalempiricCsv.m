function write2ExternalempiricCsv(in_data, dataPath, mnemonic, n_for, offset, ...
    start_date, n_periods, freq)
% write2ExternalempiricCsv Writes in_data to externalempiric format.
%   The data must be structured in ascending order over the vintage date and
%   then the forecastHorizon, otherwise the headers will not match the data.
%
%   Eg. If you have start_date corresponding to 2002Q1, n_for = 2, and an offset
%   = 1, then the output data will look like
%
%   Vintage             2002Q1  2002Q1 2002Q2 2002Q2 2002Q3 2002Q3
%   ForecastHorizon     2002Q2  2002Q3 2002Q3 2002Q4 2002Q4 2003Q1 
%   Data                1.123   1.41   etc
%                       1.123   1.11   etc
%                       1.123   1.11   etc ...
%                       1.123   1.11    
%                       1.123   1.11
%                       1.123   1.11
%
% Input:
%   in_data         [numeric] - must have dimensions in the corresponding order
%                               detailed above.
% 	dataPath        [str]     - location to save csv to
% 	mnemonic        [str]     - name of file, will output mnemonic_empiric.csv.
%   n_for           [numeric] - number of forecast horizons.
%   offset          [numeric] - offset between vintage date and forecast horizon
%   start_date      [numeric] - Must be of format YYYYMMDD
%   n_periods       [numeric] - Number of periods for vintages
%   freq            [str]     - Frequency of period.
%
%
% Usage:
%   outTable = write2ExternalempiricCsv(in_data, dataPath, mnemonic, n_for, ...
%   offset, start_date, n_periods, freq)
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

%% Extract parameters

% Number of draws from size of in_data
n_draws = size(in_data, 1);


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

% Generate the n_period vintage dates from start_date onwards.
vintage_dates_yyyynn =  csttt(bYear, bPeriod, n_periods, freq_number);

% Do the same for forecastHorizon but extending out to include offset and 
% n_horizon.
forecastHorizon_dates_yyyynn =  csttt(bYear, bPeriod, n_periods + offset + ...
    n_for, freq_number);


%% Generate the headers for vintage and forecastHorizon

% Initialise headers
vintage_header = 'Vintage';
forecastHorizon_header = 'forecastHorizon';

% Loop over the number of periods required and fill in the forecast horizons in
% the inner loop taking into account the offset.
for ii = 1 : n_periods
    
    % Set the current vintage.
    current_vintage = [num2str(floor(vintage_dates_yyyynn(ii))) 'Q' ...
        num2str(rem(vintage_dates_yyyynn(ii),1)*100)];
    
    % Obtain the corresponding forecast horizons.
    for jj = 1 : n_for
        % Create idx to chose forecast horizon including any offset
        idx_forecast_horizon = ii + jj - 1 + offset;
        
        % Set forecast_horizon
        forecast_horizon = [num2str(floor(forecastHorizon_dates_yyyynn(idx_forecast_horizon))) 'Q' ...
            num2str(rem(forecastHorizon_dates_yyyynn(idx_forecast_horizon),1)*100)];
        
        % Concatenate into appropriate string of corresponding vintage and
        % forecast horizons.
        vintage_header          = strcat(vintage_header, ',', current_vintage);
        forecastHorizon_header  = strcat(forecastHorizon_header, ',', ...
            forecast_horizon);
        
    end
end


%% Save data to .csv file
saveFilePath = fullfile(dataPath, fileName);

% Write the vintage and forecastHorizon headers
dlmwrite(saveFilePath, vintage_header, '')
dlmwrite(saveFilePath, forecastHorizon_header, '-append', 'delimiter', '')

% Loop over all data and insert
for ii = 1 : n_draws    
    % TODO: First col of 3rd row should have 'Data' in it.
    % dlmwrite(fullfile(dataPath, 'test1.csv'), 'asd', '-append', '')
    
    % Insert the data with 1 column offset.
    dlmwrite(saveFilePath, in_data(ii, :), '-append', 'delimiter', ',', ...
        'coffset', 1)
end

end
