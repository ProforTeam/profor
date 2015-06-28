function periods = returnPeriodCorrectedForTrainingSample(b)
% returnPeriodCorrectedForTrainingSample -  
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

if isempty(b.trainingPeriodSample)       
    periods         = b.loadPeriods;       
else

   trainingDates    = sample2ttt(b.trainingPeriodSample,b.freq);
   dates            = combinationFns.quarterlySaveNames2YYYYdotNN( b.loadPeriods.x );                     
   periods          = b.loadPeriods; 
   periods.x        = periods.x(find(dates == trainingDates(end)) : end );

end        