function b = setBatchCombo(obj, modelNames, selectionY)
% setBatchCombo - 
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

% Make a Batch combination object
b                               = Batchcombination;
b.selectionA                    = modelNames;
b.selectionY                    = selectionY;

b.forecastSettings.nfor         = obj.nfor;
b.sample                        = obj.sample;
b.freq                          = obj.freq;

b.simulationSettings.nSaveDraws    = obj.simulationSettings.nSaveDraws;
b.simulationSettings.showProgress  = false;
%b.xDomain=obj.xDomain;
%b.savePath=[obj.savePath '\models'];
b.pathA                                 = [obj.savePath 'models/'];
b.densityScoreSettings.scoringMethods   = obj.densityScoreSettings.scoringMethods.x(:);
b.densityScoreSettings.optimize         = obj.densityScoreSettings.optimize;
b.loadPeriods                           = combinationFns.quarterlySaveNames(obj.sample, '1');
b.onlyEvaluation                        = false;

%b.loadPeriods=quarterlySaveNames(settings.combinationForecastSample,settings.combinationForecastMonth);
