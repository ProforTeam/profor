function d = loadData(pathAndNameString, endDate, freq, mnemonics)
% loadData  Load data from a CSV file, or stored .mat file with data in
%           Tsdata object saved in Tsdata array d
%
% Input: 
%
%   pathAndNameString   [char]
%                       file path to .csv file, or full path and name of
%                       .mat file containing Tsdata array stored in
%                       variable d
%
%   endDate             [numeric]
%                       end date  (in cs format) 
%
%   freq                [char]
%                       frequency of data to be loaded
%
%   mnemonics           [cellstr]
%                       contains the names of the variables to be loaded.
%                       1) if loaded from csv file, the .csv files must have
%                       the same name as each individual mnemonic
%                       2) if loaded from .mat file, only the
%                       pathAndNameString is used
%
% Output:
%             
%   d                   [Tsdata]
%                       Tsdata array with loaded data
%
% Usage: 
% 
%   d = loadData(pathAndNameString, endDate, freq, mnemonics)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin>1
        vintageNumeric      = getVintage(endDate,freq);  
        [dataPath,~,ext]    = fileparts(pathAndNameString);
        if isempty(ext)        
            % Then the path is not to a .mat file, and dataPath should be
            % the whole string
            dataPath        = pathAndNameString;
        end
        
        d               = [];
        for i = 1 : numel( mnemonics )        
            d   = cat(2, d, ...
                loadRealTimeDataFromCsv(vintageNumeric, dataPath, mnemonics{i}, freq)...
                );        
        end
    else        
        load(pathAndNameString,'d');
        % add error checking to see if freg and mnemonic etc. is contained
        % within the Tsdata array
        %...
    end
    
end

