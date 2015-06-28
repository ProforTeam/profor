function saveNames = monthly2quarterlySaveNames(qsample, msample)
% monthly2quarterlySaveNames - Makes a cellstr with quarterly save names. 
% Useful for RecursiveEstimation
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

datesqvec   = vec(repmat(sample2ttt(qsample, 'q'), [1 3])');
suffix      = repmat((1:3)', [size(datesqvec,1)/3 1]);
saveNames   = cellstr(strcat(num2str(datesqvec),'_',num2str(suffix)));

if nargin == 2
    
    dates   = sample2ttt(msample, 'm');
    r       = size(dates, 1);
    
    if r ~= size(saveNames, 1)
        saveNames = saveNames(1:r, 1);        
    end    
    
end