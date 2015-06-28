function T = createTable(modelNames, periods, inMat, description, horizon, ...
    fillIns)
% createTable
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

nModels  = numel(modelNames);
nPeriods = numel(periods);

vintages = repmat(periods(end),[nPeriods 1]);
horizons = repmat(horizon,[nPeriods 1]);

% Set table input settings.
tableInfo = {...,
    TableSettings('Vintage',    false, ['The real time vintage the ', ...
    'table entries are computed for.']), ...
    TableSettings('Periods',    false, 'The time period the table entries are computed for.'), ...
    TableSettings('Horizon',    false, 'Forecasting horizon') ...
    };

% Only include the periods here
T = returnTable( tableInfo, vintages, periods, horizons);

for i = 1 : nModels
    
    inMati = inMat(:, i, horizon);
    
    % If the data is not sufficient for scores to be calculated replace with 
    % fillIns. E.g. In the first period for the 1-step forecast, you do not have
    % the outturn to evaluate the score. 
    if size(inMati, 1) <= horizon
        inMati = fillIns(1:size(inMati,1),i);
        
    else
        inMati =[fillIns(:,i); inMati(~isnan(inMati), 1)];
    end
    
    
    t1 = table(inMati, 'VariableNames', modelNames(i));
    t1.Properties.VariableDescriptions{modelNames{i}} = description;
    
    T = [T t1];
    
end

end