function x = loadAndControlBatchFiles(pathA, namesA, realTime, data)
% loadAndControlBatchFiles - Load and control that state is true for all
%                           Batch files included in namesA
%
% Input:
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

nModels = namesA.numc;

y       = false(1,nModels);

exception =[];
for i = 1 : nModels

    % Will be b in the workspace
    load([pathA '/' namesA.x{i} '.mat']);

    if b.state
        if ~realTime 
            % Check if the data you need is in the actual data object
            try
                x = checkBatchAgainstData(b, data);                
                if x            
                    y(i) = true;    
                end
            catch exception1
                if i == 1
                    exception = exception1;
                else                    
                    exception = addCause(exception, exception1);        
                    %exception = [exception, exception1];        
                end
            end
            
        elseif realTime 
            
            if isempty( b.dataPath )            
                
                exception1 = MException([mfilename ':dataPath'],'realTime is true, but no dataPath is supplied in individual batch file: %s',namesA.x{i});
                if i == 1
                    exception = exception1;
                else
                    exception = addCause(exception, exception1);        
                end
            
            else                            
                y(i) = true;    
            end
            
        end
    end
end

if all(y)
    
    x = true;
    
else        
    
    x = false;
    
    if isempty(exception)
        error([mfilename ':batchfiles'],'The loaded individual batch file are not correctly specified')
    else
        throw(exception);
    end

end


