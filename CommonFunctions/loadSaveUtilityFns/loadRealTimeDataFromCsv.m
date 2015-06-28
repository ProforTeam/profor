function d = loadRealTimeDataFromCsv(inVintageDate, dataPath, mnemonic, freq)
% loadRealTimeDataFromCsv   Load data from an ALFRED formatted csv spreadsheet
%                           and return a Tsdata object.
%   The data is found in ALFRED csv spreadsheets in the location
%   dataPath/mnemonic.csv. This raw data must come in the following format:
%
%   observation_date	GDP_19911204	GDP_19911220
%   1946-01-01          123.3           123.4
%   1946-04-01          124.5           134.67
%   1946-07-01          etc             etc
%   1946-10-01                          etc
%
%   Where the series name identifier in the first row is in the format
%   seriesName_YYYYMMDD, eg. for GDP of vintage 20th Decemeber 1991 the column
%   header would be GDP_19911220.
%
%   N.B. Missing values should be blank spaces, if anything else will cause
%   problems with the reading from the csv file. Don't blame us blame Matlab for
%   not having easy IO handling.
%
% Input:
%   inVintageDate          [numeric]        Must be of YYYYMMDD format.
%   dataPath                [string]
%       A string containing the path to the xls spreadsheet (but not
%       including the name of the sheet itself)
%   mnemonic                [string]
%       Variable name (must be the same as the name of the xls spreadsheet)
%   freq                    [string]
%       A string identifying the freqency of the data to be loaded
%
% Output:
%   d                       [Tsdata]
%       A time series data object
%
% Usage:
%   d = loadRealTimeDataFromCsv(inVintageDate, freq, dataPath, mnemonic)
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

% TODO: Infer frequency from date spacing.
narginchk(4, 4)

% Validation
errType = [mfilename ':input'];

% TODO: Check inVintageDate of YYYYMMDD format.
if ~isnumeric(inVintageDate)
    error(errType, 'Vintage date has to be double')
end

if numel(num2str(inVintageDate)) < 8
    error([errType, 'The input date should be of YYYYMMDD format'])
end

% Load data from real time csv file, and match the correct vintage with inVintageDate
fileNameCsv     = fullfile(dataPath,[mnemonic '.csv']);

% Check sure file exists
if exist(fileNameCsv,'file') ~= 2
    msg = ['File: "%s" not found - make sure in batch path'];
    error(errType, msg, fileNameCsv);
end

% Find the number of cols in the csv file.
[header, nCols]     = returnCsvHeaderAndColSize(fileNameCsv, errType);

% Open the csv, read in the header such that subsequent reading captures the
% 2nd to last row.
fid                 = fopen( fileNameCsv );
header              = fgetl( fid );

% The file format must be, a string followed by numeric values.
fileFormat          = strcat(' %s ', repmat('%f ', 1, nCols - 1));
fileData            = textscan(fid, fileFormat , 'delimiter',',');
fclose(fid);

% Split the header up into its col titles, they must not include commas.
header              = strsplit(header, ',');

% Extract just the date from the header in seriesName_YYYYMMDD format
seriesName          = regexp (header(1,2:end)', '_', 'split');

% Extract the date YYYYMMDD from the series name.
seriesDate          = cellfun( @(x) (str2num(x{1, 2})), seriesName);

% Calculate the difference between the series date and the required vintage.
vintageDiff         = seriesDate - inVintageDate;

% Set up indicator for the case when the available seriesDate is after, or equal
% to the requested date, inVintageDate.
vintageIdx          = vintageDiff < 0;
isVintageAvailable  = ~all(vintageIdx);

% If there is some data for which the seriesDates >= inVintageDate, then extract
% the first vintage that is greater than the inVintageDate.
if isVintageAvailable
    
    % Find the index for the first series that includes the inVintageDate.
    if numel(vintageIdx) == 1 && vintageDiff >= 0
        % Deal with the case when there is only 1 vintage and hence the
        % vintageIdx = 0;
        vintageToLoadIdx = 1;
        
    else
        [~, vintageToLoadIdx]   = max( vintageDiff( vintageIdx ) );
    end
    
    % NB. Have to add 1 to vintageToLoadIdx as dates are contained within the
    % first column.
    data                    = fileData{ vintageToLoadIdx + 1};
    dates                   = fileData{1}(1 : numel(data));
    
    % Find start and end of data - not including nans (note, there can be
    % missing values within the st and en indexes)
    [st, en]                = minmaxPanel(data);
    data                    = data(st : en);
    dates                   = dates(st : en);
    
    % Convert dates to PROFOR's YYYY.NN format.
    dates = str2DateYYYYNN(dates, {'yyyy-mm-dd','dd.mm.yyyy'}, freq);
    
    % If seriesDate is double convert to str
    if strcmpi( class( seriesDate ), 'double')
        seriesDate      = num2str( seriesDate );
    end
    
    % If inVintageDate is double convert to str
    if strcmpi( class( inVintageDate ), 'double')
        inVintageDate      = num2str( inVintageDate );
    end
    
    % Find the period for the series and inVintage dates.
    seriesDatePeriod    = str2DateYYYYNN( seriesDate, {'yyyymmdd', 'yyyy-mm-dd', ...
        'dd.mm.yyyy'}, freq);
    inVintageDatePeriod = str2DateYYYYNN( inVintageDate, {'yyyymmdd', 'yyyy-mm-dd', ...
        'dd.mm.yyyy'}, freq);
    
    % Create an index for all periods that are equal or less than requested
    % vintage.
    idx = (dates <= inVintageDatePeriod );
    
    % Construct Tsdata object, returning all data that is within the requested
    % period or before.
    d = Tsdata(dates(idx, 1), data(idx, 1), freq, mnemonic);
    
    return
end

if isempty(d) || numel(d)>1
    error([mfilename ':output'],'Could not find any data, or found to many matches!')
end

end
