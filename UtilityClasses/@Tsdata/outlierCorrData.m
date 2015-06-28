function outlierCorrData(obj)
% corrOutlierData   - Corrects data for outliers
%
% Usage:
%
%   d.outlierCorrData
%
% Note: 
%   Function uses information in the obj.dataSettings property. The property 
%   d.outliers indicates if the data contains outliers. Properties setoutliers 
%   in combination with outlierMethod determine the degree of outlier 
%   correction. (i.e. default is to correct data that is outside 6 times the 
%   interquantile range (which is alot))
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
    
    if strcmpi( obj(j).dataSettings.doOutlierCorr, 'y' )
        
        dataOutlierCorrected    = outlierCorrection(obj(j).getData, ...
            'outlierMethod', obj(j).dataSettings.outlierMethod.x{:}, ...
            'setoutlieras',  obj(j).dataSettings.setOutliersAs ...
            );

        obj(j).ts           = Tsdata.setTs(obj(j).getDates, dataOutlierCorrected);        

        % Create an instance of the event data with the name of the method 
        % usedMethodEventData('corrOutlierData') and trigger the listener for this
        % event 'uesdMethod' which simply updates the obj.changeLog.
        notify(...
            obj(j), ...
            'usedMethod', ...
            TsdataEventData('corrOutlierData') ...
            );
        
    end
    
end

end