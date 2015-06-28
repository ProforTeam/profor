function getYourStuff(obj)
% getYourStuff
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

% First, generate output structure
emptyOutput(1:obj.T) = struct();
obj.output           = emptyOutput;

% make sure originalEstimationDates ends where dates ends.
obj.originalEstimationDates = sample2ttt(obj.batch.sample, obj.freq);
idx                         = find(obj.dates(end) == obj.originalEstimationDates);
obj.originalEstimationDates = obj.originalEstimationDates(1:idx);

% Now, find windowLength
if obj.fixedEstimationSample
    obj.windowLength = numel(obj.originalEstimationDates(1:end-obj.T+1));
    
else
    obj.windowLength = [];
end

% Construct the dates2quasiRealTimeMapper
sampleForQuasiRealTimeExperiment    = adjSample(obj.sample,obj.freq, 'nlag', 1);
datesForQuasiRealTimeExperiment     = sample2ttt(sampleForQuasiRealTimeExperiment, obj.freq);

obj.dates2quasiRealTimeMapper       = containers.Map(obj.dates,...
                                            datesForQuasiRealTimeExperiment(1:end-1));

if isa(obj.batch, 'Batchcombination')    
    obj.originalEstimationLoadPeriods =  obj.batch.loadPeriods;                                        
end