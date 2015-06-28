function outTable = loadSplitNormalDataFromCsv(dataPath, mnemonic, freq)
% loadSplitNormalDataFromCsv -  Load forecast data for a split normal distribution from a
%                               csv file.
% Reads in data in blocks of 5 lines to capture the Mean, Median, Mode,
% Uncertainty and Skew (as defined in the Bank of England's fan charts).
%
%   The raw forecast data must come in the following format in blocks of 5
%   - as the data comes from the Bank of England releases, see
%   http://www.bankofengland.co.uk/publications/Pages/inflationreport/irprobab.aspx:
%
%   year	Month       IR_Type     Stat_Type   2004Q1  2004Q2  2004Q3
%                           4.0         Mean        1.34    1.60    1.60
%   1946	January     4.0         Median      1.34    1.60    1.60
%                           4.0         Mode        1.34    1.60    1.60
%                           4.0         Uncertainty 0.34    1.60    1.60
%                           4.0         Skew        1.34    1.60    1.60
%                           Market      Mean        1.34    1.60    1.60
%   1946	April       Market      Median      1.34    1.60    1.60
%                           Market      Mode        1.34    1.60    1.60
%                           Market      Uncertainty 0.34    1.60    1.60
%                           Market      Skew        1.34    1.60    1.60
%
%   NB. The reading of forecast data assumes that where no year or month are provided,
%   they take the previous value
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
%   outTable = loadSplitNormalDataFromCsv(dataPath, mnemonic, freq)
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

%% Refactor:

% Should extract location from file - too lazy at the minute. 
iMode           = 1;
iMedian         = 2;
iMean           = 3; 
iUncertainty    = 4;
iSkew           = 5;

% TODO: Infer frequency from date spacing.
freq = 'q';

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

% As specified in the format of the file - Year, Month, IR_Type, Stat_Type.
nDataIdentifierCols = 4;
nRowsToRead         = 5;
nBlocks             = (nLines - 1) / nRowsToRead;

if ~isDoubleAnInteger(nBlocks)
    error(errType, ['Check your input data, needs to be in rows of 5 with ', ...
        'Mode, Median, Mean, Uncertainty and Skew.'])
end

% Open the csv, read in the header such that subsequent reading captures the
% 2nd to last row.
fid                 = fopen( fileName );
header              = fgetl( fid );

% Split the header up into it's col titles (must not include commas).
header              = strsplit(header, ',');

% Extract just the date from the header from the input YYYYQN format by just
% replacing the 'Q' with '.0'.
evaluationDates     = regexprep( header(1, nDataIdentifierCols + 1 : end)', 'Q', '.0');

% This is the standard format of the data, see the detailed eg data above.
fileFormat  = strcat(' %s %s %s %s', repmat('%f ', 1, nCols - nDataIdentifierCols));


year                = [];
month               = [];
outTable            = table();
for ii = 1 : nBlocks
    
    % Read in the block of data corresponding to 1 market projection.     
    fileData    = textscan(fid, fileFormat , nRowsToRead, 'delimiter',',');
    
    % Extract the values relating to a particular vintage / block of data.
    year                = returnUniqueElementOrPrevious(fileData{1, 1}, year, ii);
    month               = returnUniqueElementOrPrevious(fileData{1, 2}, month, ii);
    marketProjection    = returnUniqueElementOrPrevious(fileData{1, 3}, [], ii);
    
    if isempty(marketProjection)
        error(errType, 'No data on market projection')
        
    elseif sum( isstrprop( marketProjection, 'digit' ) ) > 0
        % The marketProjection is using a constant interest rate.
        marketProjectionValue    = marketProjection;
        marketProjection         = 'Constant';
    end
    
    if ischar(year)
        year            = str2num(year);
    end
    
    % Construct the vintage date from the year and month and convert to YYYY.NN
    % format.
    vintageDate         = datenum([num2str(year), '-', month], 'yyyy-mmmm');
    vintageDate         = matlabDate2YYYYdotNN( vintageDate, freq, errType );
    
    % Find the index of the non-empty data cells that contain at least the min
    % number of data points.     
    minNumberOfDataPoints   = 3;
    testDataAvailable       = @(x)( sum(~isnan(x)) > minNumberOfDataPoints);
    
    % Create the index by applying this fn cell by cell. 
    isDataAvailableIdx      = cellfun( testDataAvailable, ...
        fileData(1, nDataIdentifierCols + 1 : nCols));
    
    % Use this index to choose the appropriate evaluation dates, and mean mode
    % etc through the file Data.                    
    availableEvaluationDates = evaluationDates( isDataAvailableIdx );
    
    % Remove the first descriptive columns of the data and then choose data.
    fileData = fileData(1, nDataIdentifierCols + 1 : end);    
    fileData = fileData(1, isDataAvailableIdx);
            
    % Set table input settings.
    tableInfo = {...,
        TableSettings('vintage',            true, ''), ...
        TableSettings('evaluationDate',     false, '',  true), ...
        TableSettings('marketProjection',   true, '',   true), ...
        TableSettings('Mode',               false, ''), ...
        TableSettings('Median',             false), ...
        TableSettings('Mean',               false), ...
        TableSettings('Uncertainty',        false), ...
        TableSettings('Skew',               false) ...
        };
    
    % TODO: Perhaps not the most efficient way to extract the data - but it
    % works.
    in_mode         = cellfun(@(x)(x(iMode)),           fileData');  
    in_median       = cellfun(@(x)(x(iMedian)),         fileData');  
    in_mean         = cellfun(@(x)(x(iMean)),           fileData');  
    in_uncertainty  = cellfun(@(x)(x(iUncertainty)),    fileData');  
    in_skew         = cellfun(@(x)(x(iSkew)),           fileData');  
            
    % Generate tables.        
    tableRow = returnTable(tableInfo, vintageDate, availableEvaluationDates, ...
            marketProjection, in_mode, in_median, in_mean, in_uncertainty, ...
            in_skew );
    
    % Add rows to the out table.
    outTable = [outTable; tableRow];
    
end

end
