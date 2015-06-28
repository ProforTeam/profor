function inTsdata = prepareData(inTsdata, dataSettings, selection)
% prepareData -  Extract data transformations and apply to Tsdata obj inTsdata.   
%   
% Input:
%   inTsdata        [Tsdata]
%   dataSettings    [CellObj]
%   selection       [cell]
%
% Usage:
%
%   inTsdata = prepareData(inTsdata, dataSettings, selection)
%
% Note: dataSettings and selection will have the same number of elements
% (controlled in Batch)
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

%% Validation
errType = [mfilename ':input'];

if dataSettings.numc ~= numel(selection)
    msg = 'Number of elements in selection and dataSettings have to match';
    error(errType, msg)
end

%% Return modified Tsdata object inTsdata.

% Apply the transformations in dataSettings to the corresponding series in
% selection. 
for i = 1 : dataSettings.numc
    
    % Extract the data transformations (DataSetting obj) from dataSettings.
    dataSettingsI   =  dataSettings.x{i};
    
    % Find the appropriate series from the inTsdata
    tempTsdata      =  findobj(inTsdata, 'mnemonic', selection{i});
    
    % Note that since inTsdata is a handle object, changes made to tempTsdata 
    % will also affect inTsdata. 
    if numel(tempTsdata) == 1
        tempTsdata.dataSettings = dataSettingsI;        
    else
        msg = ['Found zero or multiple instances of %s series', selection{i}];
        error(errType, msg)
    end
        
end




