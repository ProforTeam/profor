function populateAllowableProperties( obj )
% populateAllowableProperties Populates the allowableProperties structure
%                         based on the settings in the Batch combination
%                         file or the Batch model file. The content will be
%                         the set of allowed properties that settings in 
%                         defaultProperties can take. 
%
% Inputs:
%   obj                     [Report]
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

if isempty( obj.proforObj )        
    batchFile   = obj.modelProperties.batch;
    % Model Batch true
    mb          = true;
else    
   batchFile    = load( fullfile(obj.proforObj.pathA,'Combo.mat') );            
   batchFile    = batchFile.b;
    % Model Batch false / Profor thing   
   mb           = false;      
end

if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
   if isempty(batchFile.trainingPeriodSample)       
        dates            = combinationFns.quarterlySaveNames2YYYYdotNN( batchFile.loadPeriods.x );       
   else
       
       trainingDates    = sample2ttt(batchFile.trainingPeriodSample,batchFile.freq);
       dates            = combinationFns.quarterlySaveNames2YYYYdotNN( batchFile.loadPeriods.x );
       
       dates            = dates(find(dates == trainingDates(end)) : end  );
       
   end
   
end        

fnames = fieldnames( obj.allowableProperties );
for i = 1 : numel(fnames)
    
    fieldi = obj.allowableProperties(1).(fnames{i});
    % Populate the fields that are empty
    if isempty(fieldi)
        
        switch fnames{i}
            
            case{'forecastHorizon'}
                obj.allowableProperties(1).forecastHorizon     = 1:batchFile.forecastSettings.nfor;
            case{'vblNames'}
                obj.allowableProperties(1).vblNames            = batchFile.selectionY.x;                                
            case{'defaultModelName','modelNames'}
                % Differs depending on Model or Profor object
                if mb && ~isa(batchFile,'Batchcombination') 
                    obj.allowableProperties(1).(fnames{i}) = {batchFile.modelName};
                else
                    obj.allowableProperties(1).(fnames{i}) = batchFile.selectionA.x;                
                end
            case{'scoreMethod'}
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).scoreMethod     = batchFile.densityScoreSettings.scoringMethods.restrictions;                    
                end
            case{'requestedVintage'}
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).requestedVintage = dates;                                                           
                end
            case{'startPeriod'}
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).startPeriod = dates;                                                                              
                end
            case{'endPeriod'}                
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).endPeriod = dates;                                                                            
                end        
            case{'eventThreshold'}
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).eventThreshold = batchFile.brierScoreSettings.eventThresholdValue;                                                                             
                end                        
            case{'eventType'}
                if ( mb && isa(batchFile,'Batchcombination') ) || ~mb
                    obj.allowableProperties(1).eventType       = batchFile.brierScoreSettings.eventType.restrictions;                                                                             
                end                        
                
        end
        
    end
    
end
