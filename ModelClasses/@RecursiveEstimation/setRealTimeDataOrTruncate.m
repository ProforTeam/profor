function obj = setRealTimeDataOrTruncate(obj, endDate, T, t)
% setRealTimeData   For a given endDate load and sets new Tsdata object.
%
% Input:
%   obj     []
%   endData     [YYYY.QQ]       Where QQ are numeric quarter dates, e.g. 01, 02.
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

if obj.realTime
    % Load real time data for a given endDate.
    vintageNumeric  = getVintage(endDate, obj.freq);
    dataPath        = obj.dataPath;
    
    d               = [];
    for i = 1 : numel( obj.data )
        d = cat(2, d, ...
            loadRealTimeDataFromCsv(vintageNumeric, dataPath, ...
            obj.data(i).mnemonic, obj.data(i).freq));
    end
    obj.data = d;
    
else    
    
    % Lag enddate one period so that we loose one period with observations.
    % This is done such that the sample end for a quasi real time maps with
    % a true real time experiment. I.e., it is assumed that we miss
    % information for the period we are in, but might have information from
    % the previous period (like the usuall case with real time data).     
    endDate = obj.dates2quasiRealTimeMapper(endDate);    
    
    % Load data: Need to do this since it might be adjusted later on and
    % because it's a handle 
    D           = load( fullfile(obj.dataPath, 'data.mat'),'d' );
    obj.data    = D.d;
    
    obj.data.truncateData(endDate, 'freq', obj.freq);
    
end

% Adjust batch file if needed.
if T ~= 1    
    adjustBatchFile(obj, t);
end


end


