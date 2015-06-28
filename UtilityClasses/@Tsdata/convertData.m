function convertData(obj)
% converData    - Converts data frequency (only high to low freq).
%
% Usage:
%
%   d.convertData
%
% Note: 
%   Only works from higher frequencies to lower frequencies.
%   Function uses information in the obj.dataSettings property
%
% See also DATASETTING
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


nObj = numel(obj);
for j = 1 : nObj
    
    % If fromFreq and toFreq are equal, or no
    % conversion specified  jump out of program 
    if strcmpi(obj(j).freq, obj(j).dataSettings.doConversionTo) || strcmpi(obj(j).dataSettings.doConversionTo,'n')
        continue
    end
    
    % get some preliniaries for computation and output    
    dataF       = obj(j).getData;    
    toFreq      = obj(j).dataSettings.doConversionTo;
    fromFreq    = obj(j).freq;
    
    % Convert data
    [datesOut, converted]   = conversionFnc(obj(j).getDates, dataF, fromFreq, ...
                                                toFreq,obj(j).dataSettings.conversionMethod.x{:});
                
    % Update some fields: dates must be done first!!!
    obj(j).freq             = toFreq;
    obj(j).ts               = Tsdata.setTs(datesOut,converted);

    % Notify change
    notify(obj(j), 'usedMethod', TsdataEventData('convertData'));        
end

end