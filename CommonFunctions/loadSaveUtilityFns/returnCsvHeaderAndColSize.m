function [header, nCols] = returnCsvHeaderAndColSize( fileName, errType )
% returnCsvHeaderAndColSize - Returns the header and number of cols of a csv
%                             file.
% NB: Header should not have commas in the name of the columns.
%
% Input:
%   filename        [str]       Path to csv file.
%   errType         [str]       Stem of the error msg location.
%
% Output:
%   header          [str]       The string containing the first row of the csv
%                               file - just returning raw output of fgetl(
%                               fileName)
%   nCols           [int]       Number of columns contained within the csv file.
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


% Update ErrType Msg if supplied.
if isempty(errType)
    errType = [mfilename, ': '];
else
    errType         = strcat(errType, ': ', mfilename);
end

% Validate input args
if nargin == 0
    error(errType, 'Not enough input arguments');
end

% Get Filename
if ~ischar(fileName)
    error(errType, 'Filename must be a string.');
end

% Make sure file exists
if exist(fileName,'file') ~= 2
    msg = ['File: %s not found - make sure in batch path', fileName];
    error(errType, msg);
end

% Open the input file and read in the first row (header) as a string.
delim           = ',';
fid             = fopen( fileName );
header          = fgetl(fid);

% Count the number of columns as instances of ,
% TODO: will break if headers have , in them.
nCols           = length(find(header == ',')) + 1;
fclose(fid);

end
