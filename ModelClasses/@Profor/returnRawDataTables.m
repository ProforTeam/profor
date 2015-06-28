function outTable = returnRawDataTables( obj )
% returnResultTables    Generates tables for raw data by vintage date, i.e.
%                       recovers the input data. 
%   
% Input:
%   obj             [Profor]
%   scoreMethod     [cell][str](1xn)        Methods for which results required.
%
% Output:
%   outTable        [Table]
%
% Usage: outTable = returnRawDataTables( obj )
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

if obj.state
    
    % Load batch combo file to get periods etc.
    load([obj.pathA '/Combo.mat']);
    
    periods             = returnPeriodCorrectedForTrainingSample(b);   
    selectionY          = b.selectionY;
    savePath            = obj.savePath;    
    nVariables          = selectionY.numc;
    nEvaluationDates    = periods.numc;
    
    outTable            = table();
    for v = 1 : nVariables
        for p = 1 : nEvaluationDates
            
            % Load the model for given variable and evaluation period.
            m           = Model.loado( fullfile(savePath,'models',['Combination_' ...
                selectionY.x{v}],'results',periods.x{p},'m'));
            
            % Extract the raw data from the estimation object.
            w  = obj.getDateVintageTable( m.estimation );
                        
            % Add rows
            outTable    = [outTable; w];
            
        end
    end
    
        
else
    error([mfilename ':input'],'The state of the Profor object is not ok. Can not make tables');
end





