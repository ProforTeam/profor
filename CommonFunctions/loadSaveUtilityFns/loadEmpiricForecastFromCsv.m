function [vintageDate, forecastDate, empiricData] = loadEmpiricForecastFromCsv(dataPath, mnemonic, freq)
% loadEmpiricForecastFromCsv - Load external forecast data for a external empiric distribution
%                              from a CSV file
%
%   The raw forecast data must come in the following format.  The iterates
%   in the rows, with the columns giving forecasts of different
%   horizons, for a given data vintage. For example, if the external forecasts 
%   came from 5000 draws and all forecasts were one step ahead
%   for a single vintage, there would be 5000 rows and one column.
%
%   Vintage             2002Q1  2002Q1  
%   ForecastHorizon     2002Q2  2002Q1
%   Data                1.123   1.41
%                       1.123   1.11
%                       1.123   1.11
%                       1.123   1.11
%                       1.123   1.11
%                       1.123   1.11
%
%   NB. The reading of data assumes that where no year or month are provided,
%   they take the previous value.
%
%   N.B. Missing values should be blank spaces, if anything else will cause
%   problems with the reading from the csv file -- a MATLAB issue.
%
% Input:
%   dataPath                [string]
%       A string containing the path to the xls spreadsheet (but not
%       including the name of the sheet itself)
%   mnemonic                [string]
%       Variable name (must be the same as the name of the xls spreadsheet)
%   freq                    [string]
%       A string identifying the freqency of the data to be loaded
%
% Output:
%   outTable                [Table]
%
% Usage:
%   outTable = loadEmpiricForecastFromCsv(dataPath, mnemonic, freq)
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
errType = [mfilename ':input'];

% Load data from real time csv file, and match the correct vintage with
% inVintageDate from above
fileName     = [dataPath '/' mnemonic '.csv'];

% Check sure file exists
if exist(fileName,'file') ~= 2
    msg = ['File: %s not found - make sure in batch path', fileName];
    error(errType, msg);
end

%% Open file and read in.

% Find the number of rows, cols and header in the csv file.
nLines              = returnNumberOfLines(fileName, errType);
[~, nCols]          = returnCsvHeaderAndColSize(fileName, errType);

% As specified in the format of the file - Vintage, ForecastHorizon, Data
nDataIdentifierCols = 3;
nBlocks             = (nLines - 1);
nDataPoints         = nCols - nDataIdentifierCols + 1;

if ~isDoubleAnInteger(nBlocks)
    error(errType, ['Check your input data, needs to be in rows of 5 with ', ...
        'Mode, Median, Mean, Uncertainty and Skew.'])
end

% Open the csv, read in the header such that subsequent reading captures the
% 2nd to last row.
fid                 = fopen( fileName );
vintageDate         = fgetl( fid );

% Split the header up into it's col titles (must not include commas).
vintageDate         = strsplit(vintageDate, ',');
vintageDate         = regexprep( vintageDate, 'Q', '.0');

forecastDate        = fgetl( fid );
% Split the header up into it's col titles (must not include commas).
forecastDate        = strsplit(forecastDate, ',');
forecastDate        = regexprep(forecastDate, 'Q', '.0');

% Convert the cell arrays of dates to matricies
vintageDate         = str2num( cell2mat( vintageDate(2:end)' ) );
forecastDate        = str2num( cell2mat( forecastDate(2:end)' ) );

% This is the standard format of the data, see the detailed eg data above.
fileFormat          = strcat(' %s', repmat('%f ', 1, nCols - 1));

% Get all data
fileData            = textscan(fid, fileFormat , 'delimiter',',');

% Extract a matrix of the empiric data.
empiricData         = cell2mat( fileData(2:end) );

end
