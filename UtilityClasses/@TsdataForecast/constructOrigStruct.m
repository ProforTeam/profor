function constructOrigStruct(obj)
% constructOrigStruct - Generate struct with original data.
%   Generate structure with original data and information. 
%   Use method resetData to reinitialise the original data. 
%
%   See also DATA/RESETDATA
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

attribute   = TsdataForecast.getPropertiesNotDependentAndConstant;
nObj        = numel(obj);

for ii = 1 : nObj
    originalData            = struct();

    for jj = 1 : numel(attribute)
        originalData.( attribute{jj} )     = obj(ii).( attribute{jj} );
    end
    
    obj(ii).originalStruct   = originalData;
end

end