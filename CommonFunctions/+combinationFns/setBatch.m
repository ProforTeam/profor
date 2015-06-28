function b = setBatch(draws, sample, nfor, pathStr, modelName)
% setBatch - 
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

% load batch file - which has to be stored as b.
load([pathStr '/' modelName '.mat']);

% Find the end date of the sample and start date of the batch file. 
[~, endD]                           = getDates( sample );
[startDm, ~]                        = getDates( b.sample );

% Update batch file with extended sample using the end date from the sample and
% the start date from the loaded batch file. 
b.sample                            = [num2str(startDm) '-' num2str(endD)];
b.forecastSettings.nfor             = nfor;

b.simulationSettings.nSaveDraws     = draws;
b.simulationSettings.showProgress   = false;

