function adjustBatchFile(obj, t)
% adjustBatchFile       TODO:
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

errType     = [mfilename ':adjustBatchFile' ':NotImplementedError'];

%1) Remove one observations from the top
if obj.fixedEstimationSample
    %obj.batch.sample   = getSample(obj.originalEstimationDates(1-t+obj.T:-t+obj.T+obj.windowLength));
    obj.batch.sample    = getSample( obj.originalEstimationDates...
        (end - obj.T + t - obj.windowLength + 1 : end - obj.T + t));
    
    if isa(obj.batch, 'Batchcombination')
        %obj.batch.loadPeriods=obj.batch.loadPeriods(end-obj.T+t-obj.windowLength+1:end-obj.T+t);
        msg = ['Not possible to use fixedEstimationSample with ',...
            'Batchcombination (haven not programmed this in, but simple...'];
        error( errType, msg )
    end
    
else
    obj.batch.sample    = getSample( obj.originalEstimationDates...
                        (1 : end - obj.T + t));
    
    if isa(obj.batch, 'Batchcombination')    
        if ~obj.batch.loadPeriods.default
            obj.batch.loadPeriods   = obj.originalEstimationLoadPeriods.x(1 : end - obj.T + t);
        end
    end    
end
end
