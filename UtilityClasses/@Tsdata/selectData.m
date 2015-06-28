function [outData, sampleDates, selectionChar, transf] = ...
                                        selectData(obj, seriesName, freq, dateRange)
% selectData  -  selectData method selects data from the Tsdata obj (which can 
%               contain more than one array of Tsdata objects)
%
% Input:
%   seriesName 	[cell/cellstr/numeric] 
%       Either cellstr, or cell or numerics. If cellstr, each cell is a 
%       mnemonic. If cell with numerics, each cell is a number. If cellstr, 
%       porgam search for match in menomonics, if cell with numbers, program 
%       search for match among number properties
%   freq        [string/number] 
%       Frequency of data. Follows standard notation.
%   dateRange      [string]    
%       The dateRange you want to extract, e.g. '1990.02-2010.03. If empty, 
%       default is to use the longest sample available.
%
% Output:
%   outData         [array (t x nObjFound)]     Contains extracted data. Can 
%                                               contain nans.
%   sampleDates     [numeric (t x 1)]           Cs format
%   selectionChar 	[string ]           
%       Contains selected variable names. Will be similar as seriesName, but 
%       might be shorter if some series are not found.
%   transf          [cell]            
%       Extracts the transf property for each selected series puts into common 
%       vector transf.
%
% USAGE: [outData, sampleDates, selectionChar, transf] = ...
%                               selectData(obj, seriesName, freq, dateRange)
%
% Note: 
%   Program makes a output vector/matrix x which can contain nans, i.e. the 
%   different data series can have different lenght. Longest available series 
%   defines the time dimension. Also, you can not mix frequency.
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


%% Validation and assignment

% Validate that the seriesName is of the correct format.
if ~iscell( seriesName )
    error([mfilename ':inputseriesName'],'The seriesName input must be a cellstring or cell')
        
elseif ~iscellstr( seriesName )
    % If not a cell array of strings. 
    seriesName       = seriesName{:};
    
    if ~isnumeric( seriesName )
        error([mfilename ':inputseriesName'], 'If seriesName is a cell, the content must be numeric')
    end
    propertyName    = 'number';
    
else
    propertyName    = 'mnemonic';
end

% Convert freq to character representation if given as numeric.
if isnumeric(freq)
    freq    = convertFreqN( freq );
end

%% Find the selected series in seriesName.

% Initialise an empty Tsdata object.
nSeries     = numel( seriesName );
y           = eval([ class(obj) '.empty(nSeries, 0)']);

% Find the Tsdata objects with the given propertyName and freq.
for i = 1 : nSeries
    % Deal with accessing the property name value for cell or numeric data type.
    if iscellstr( seriesName )
        propertyNameValue = seriesName{i};        
    else
        propertyNameValue = seriesName(i);        
    end
    
    % Find the obj with the given property name and frequency.
    y(i)    = findobj(obj, propertyName, propertyNameValue, ...
                'freq', freq );
end

nObjFound   = numel(y);

% Throw errror if not all of the selctions were found. 
msg = ['Program did not find the (following) variables you asked for in ',...
        'the seriesName cell:'];
if nObjFound ~= numel( seriesName )
    if isempty( nObjFound )        
        error([mfilename ':missingMatch'], msg)        
    else        
        warning([mfilename ':missingMatch'], msg)
        char( setdiff( seriesName, {y.mnemonic} ))        
    end
end


%% Find the largest sample and truncate the data set if dateRange is provided.

% Find longest possible sample, truncate later
sampleDates     = Tsdata.findLongestSample( y );
t               = size( sampleDates, 1 );

outData         = nan(t, nObjFound);
selectionChar   = cell(1, nObjFound);
transf          = cell(1, nObjFound);

for i = 1 : nObjFound
    
    dates                       = y(i).getDates;    
    idx                         = find( dates(1)   == sampleDates );
    idxEnd                      = find( dates(end) == sampleDates );
    outData( idx : idxEnd, i )  = y(i).getData;
    
    if y(i).getMissingValues
        warning([mfilename ':missingValues'], 'The data you are selecting contain missing values')
    end
    
    selectionChar{i}            = y(i).mnemonic;
    transf{i}                   = y(i).transfState;    
end

% Truncate if dateRange limits the sample size. 
if ~isempty( dateRange )
    [idx, idxEnd, sampleDatesNew, stt, enn] = ...
                                mapDatesAndSample(dateRange, sampleDates, freq);
                            
    if isempty( sampleDatesNew ) 
        % dateRange is within sampleDates. Trunkate outData and % sampleDates to get 
        % finial output
        outData                     = outData( idx : idxEnd, :);
        sampleDates                 = sampleDates( idx : idxEnd );
        
    else
        % dateRange is not within sampleDates. Need to construct new outData matrix, and 
        % then fit the original outData into the new outData. sampleDatesNew is constructed 
        % based on dateRange, stt and enn idx where in the new xx matrix the old outData 
        % matrix fits.
        t                   = size(sampleDatesNew, 1);
        xx                  = nan(t, nObjFound);
        xx( stt : enn, : )  = outData;
        % Adjusted output (in accordance with dateRange)
        outData             = xx( idx : idxEnd, :);
        sampleDates         = sampleDatesNew( idx : idxEnd );
    end
end

end
