classdef Estimationcombination < handle
% Estimationcombination - 
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
    
    properties(SetAccess = protected, Hidden)
        yInfo
        nfor
        pathA
        onlyEvaluation
        dataSettings
        dataPath
        links
        
        estimationState = false;
        
        controlModels 
    end
    
    properties(SetAccess = protected)
        tElapsed  %Total time used in estimation
        
        sample    %Estimation sample
        estimationDates
        freq      %From the batch object
        method
        periods
        
        namesY    % (1 x n) cellstr with names of endogenous variables
        namesA    % (1 x s) cellstr with model names
        

        y         % Observable variables
        trainingSampleStartIdx
        isRollingWindow
        
        resultCell
        weightsAndScores
        
        simulationSettings
        generalSettings
        priorSettings        
        brierScoreSettings
        densityScoreSettings
        
    end
    properties(Dependent)
        dates
        estimationSample
        %horizons
    end
    
    properties(Constant = true,Hidden)
        nlag = 20;
    end
    
    methods
        
        function obj = Estimationcombination()
            
        end
        
        function x = get.dates(obj)
            x = sample2ttt(obj.sample, obj.freq);
        end
        
        function x=get.estimationSample(obj)
            x = getSample(obj.estimationDates);
        end
        
        %% General methods in separate files.
        obj = estimate(obj, mobj)
        
        result                          = controlAndLoadModels( obj )
        
        weightsAndScores                = constructScoresAndWeights( obj, eventThreshold )
        
        [weightsAndScores, forecastObj] = updateWeightAndScores(obj, method,...
            optimize, isProduceForecast, eventThreshold)
        
        [weightTable, scoreTable]       = createResultTables(obj, horizon)
        
        outTable    = returnResultTables(obj, nHorizon, variableName, scoreMethod, ...
            eventThreshold)        
        
        controlOutput(obj, weightsAndScores)
        disp( obj )
        
        inData          = validateTableData(obj, inData, horizon, dataType);
        
        [weights, optResult, isWeightsOk] = getWeights(obj, methodo, numPeriods, nforo,...
            numModels, trainingSampleStartIdxo, optimizeo, nvary, isRollingWindow, ...
            scores, constant);
        
        arrayOfMapData = extractDataFromMap(obj, resCell, fieldName, ...
            eventThreshold, iForecastHorizon, nForecastHorizons, nPeriods)
        
        
        
    end
    
    methods(Access = private)        
        populateResultTable( obj, scoreMethod, eventThreshold )                
    end
    
    
    methods(Static = true)
        T = createTable(modelNames, periods, inMat, description, horizon, ...
            fillIns)
    end
end