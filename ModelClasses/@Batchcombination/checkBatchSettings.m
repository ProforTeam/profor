function x = checkBatchSettings( obj )
% checkBatchSettings

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

if ~isempty(obj.trainingPeriodSample)
    ts=sample2ttt(obj.trainingPeriodSample,obj.freq);
    s=sample2ttt(obj.sample,obj.freq);
    idx=ismember(ts,s);
    if sum(idx,1)~=numel(ts) 
        error([mfilename ':checkBatchSettings'],'Wrong specification of training sample. The trainingPeriodSample is not within the sample.')
    elseif ~all(idx(1:numel(ts))) || any(idx(numel(ts)+1:end))
        error([mfilename ':checkBatchSettings'],'Wrong specification of training sample. All of the trainingPeriodSample is not within the sample or some of it is outside')
    end
end
if obj.isRollingWindow && isempty(obj.trainingPeriodSample)
    error([mfilename ':checkBatchSettings'],'You want a rolling window for estimating the weights, set the training sample to indicate the length of this window')    
end;
if ~obj.onlyEvaluation && obj.selectionA.numc<2
    error([mfilename ':checkBatchSettings'],'Number of models (selectionA) must be at least 2')
end
if obj.densityScoreSettings.optimize && ~any(strcmpi(obj.densityScoreSettings.scoringMethods.x{:},{'logScore','logScoreD','mvnLogScore'}))
    error([mfilename ':checkBatchSettings'],'If optimal weights are to be computed, one of the log scores must be used as scoringMethod')
end
if obj.forecastSettings.nfor<1
    error([mfilename ':checkBatchSettings'],'nfor setting must be larger than or equal to 1')
end
if ~obj.loadPeriods.default
    if numel(sample2ttt(obj.sample,obj.freq))~=obj.loadPeriods.numc
        error([mfilename ':checkBatchSettings'],'loadPeriods do not have the correct size. Should equal numel in sample dates')
    end
end

% Check general settings
x = checkSettings(obj.generalSettings,obj);
% Check forecast settings
x = checkSettings(obj.forecastSettings,obj);
% Check other stuff in parent
x = checkBatchSettings@Batch(obj);

end
