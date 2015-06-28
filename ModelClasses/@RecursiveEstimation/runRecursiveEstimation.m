function runRecursiveEstimation( obj )
% runRecursiveEstimation
%
% Input:
%   obj     [RecursiveEstimation]
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

errType = [mfilename ':run'];

if obj.state
    
    getYourStuff(obj);
    
    % Do recursive estimation. Note, it starts from the last period
    T       = obj.T;
    dates   = obj.dates;    
    
    for t = T : -1 : 1
        
        endDate = dates(t);
        obj.setRealTimeDataOrTruncate(endDate, T, t);
        
        try
            % Make model object
            m   = Model(obj.batch.method, obj.batch, obj.data);
            m.runModel;
            
            % Populate output structure
            populateOutput(obj, m, t);
            
            if obj.saveRecursions
                % save to file the whole estimation step
                if ~isempty(obj.saveNames)
                    saveName = obj.saveNames{t};
                else
                    saveName = num2str(endDate);
                end
                m.savePath = fullfile(obj.savePath,saveName);
                m.saveo;
            end
            
        catch exception1
            msgString = ['Some error occured when estimating vintage %6.2f. This ',...
                'will not be stored, moving on to the next vintage. Error ',...
                'message:\n%s'];
            
            exception = MException(errType, msgString, endDate);
            exception = addCause(exception, exception1);                
            
            throw(exception);
            
        end
        
    end
    
else
    
    msgString = 'The program is not ready for running. obj.state is false. Check properties';
    error(errType, msgString);
end

end
