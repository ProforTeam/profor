classdef Report < handle
    % Report    Provides reporting methods for individual, combination and Profor
    %           model objects.
    %
    % Report Properties:
    %
    %
    %
    % Report Methods:
    %   Report                              - Constructor
    %   plotPointForecast                   - Plots the point forecast.
    %   plotDensityForecast                 - Plots the density forecast.
    %   plotWeightsOrScores                 
    %   plotTotalEconomicLoss               
    %   plotProbabilityEventThreshold
    %   plotRelativeOperatingCharacteristics
    %   plotProbabilityIntegralTransforms
    %   plotPointForecastHistorical
    %   plotDensityForecastHistorical
    %   getProbabilityIntegralTransformsTests
    %   evaluatePointForecast
    %   getRealTimeTable
    %   getDensityForecastScoreTable
    %
    % Usage:
    %
    %   See the reporting <a href="matlab: opentoline(./help/helpFiles/htmlexamples/makingReportsExample.m,1)">example file</a>
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%
    
    
    properties
        % savePath - string with directory path. Required to save plots and
        % tables
        savePath        = '';
        tableOptions    = TableOptionSettings();                % Class for setting of table opions.
        plotOptions     = PlotOptionSettings();                 % Class for setting of plot opions.
    end
    
    properties(SetAccess = protected, Transient = true)
        rawDataTable    = table();
        resultTable     = table();
    end
    
    properties(SetAccess = protected, Transient = true)
        output          = struct();         % output produced by procedures when making report (depends on method)
    end
    
    properties(SetAccess = protected, Hidden = true)
        
        % Note: defaultProperties and allowableProperties needs to have the
        % same size and names. Differs in that allowableProperties contains
        % a range of values for each setting that the defaultProperties can
        % take (i.e., allowableProperties is used to check input to Report
        % functions
        %
        
        defaultProperties = struct(...
            'maxHistoryPeriods',            20, ...             % hard coded, usually not less than 20 observation saved in history
            'dataType',                     'weights',...       % scores or weights
            'modelNames',                   [],...              % cellstr/str
            'forecastHorizon',              1,...               % Can not be less than 1, max defined in allowableProperties
            'vblNames',                     [],...              % cellstr/str
            'eventThreshold',               [],...              % double
            'eventType',                    [],...              % str
            'defaultModelName',             [],...              % str
            'realTimeTableExtractionType',  'lastRealTime',...  % str, either 'lastRealTime' or 'last'
            'scoreMethod',                  'mse',...              % str
            'realTimeTableType',            'full',...          % str, either 'current' or 'full'
            'requestedVintage',             [],...              % double, YYYY.NN
            'startPeriod',                  [],...              % double, YYYY.NN
            'endPeriod',                    []...               % double, YYYY.NN
            );
        %'plotVariableNames',       same as vblNames
        % 'outType'                 same as dataType
        allowableProperties = struct( ...
            'maxHistoryPeriods',            {20,@(x,y)x<=y},...
            'dataType',                     {{'weights','scores'},@(x,y)any(strcmpi(x,y))},...
            'modelNames',                   {[],@(x,y)Report.cellstrCheck(x,y)},...
            'forecastHorizon',              {[],@(x,y)numel(intersect(x,y)) == numel(x)},...
            'vblNames',                     {[],@(x,y)Report.cellstrCheck(x,y)},...
            'eventThreshold',               {[],@(x,y)sum(x == y) == 1},...
            'eventType',                    {[],@(x,y)any(strcmpi(x,y))},...
            'defaultModelName',             {[],@(x,y)numel(intersect(x,y)) == 1},...
            'realTimeTableExtractionType',  {{'lastRealTime','last'},@(x,y)any(strcmpi(x,y))},...
            'scoreMethod',                  {[],@(x,y)any(strcmpi(x,y))},...
            'realTimeTableType',            {{'current','full'},@(x,y)any(strcmpi(x,y))},...
            'requestedVintage',             {[],@(x,y)sum(x == y) == 1},...
            'startPeriod',                  {[],@(x,y)sum(x == y) == 1},...
            'endPeriod',                    {[],@(x,y)sum(x == y) == 1}...
            );
        
        modelProperties = struct(...
            'method',           '', ...
            'estimation',       '', ...
            'forecast',         '',...
            'batch',            ''...
            );
        
        proforObj
    end
    
    
    methods
        function obj = Report(inObj)
            % Report    Class constructor. Extracts appropriate fields from the
            %           input Model or Profor objects.
            %
            % Input:
            %   inObj        [Model]/[Profor]
            %
            % Output:
            %   obj         [Report]
            
            errType = ['Report:', mfilename];
            
            % Control:
            % 1. Model or Profor.
            
            if isa( inObj, 'Profor')
                
                if inObj.estimationState
                    
                    % Store profor object to make life easier for now.
                    obj.proforObj               = inObj;
                    
                else
                    error(errType,['PROFOR estimationState is false.',...
                        ' The settings are ok, but there are no combination',...
                        ' results in the folders you have specified.',...
                        ' Run Profor before asking for a report'])
                end
                
            elseif isa( inObj, 'Model')
                
                if inObj.forecast.forecastingState && inObj.estimation.estimationState
                    % Extract model properties.
                    obj.modelProperties.method      = inObj.method;
                    obj.modelProperties.estimation  = inObj.estimation;
                    obj.modelProperties.forecast    = inObj.forecast;
                    obj.modelProperties.batch       = inObj.batch;
                    
                    % Set the default save path:
                    obj.savePath                    = inObj.savePath;
                    
                else
                    error(errType,['The Model estimationState and/or forecastingState is false.',...
                        ' Run the Model before asking for a report'])
                end
                
            else
                error(errType, 'Unsupported class for Report functionality')
            end
            
            % Now populate the allowable properties. This works for both
            % Models and Progor objects. The allowableProperties structure
            % is used for error checking method inputs when running Report
            % methods
            populateAllowableProperties( obj );
            
            % Finally, populate the missing fields in defaultProperties
            % structure with the allowableProperties structure. The
            % defaultProperties structure is used if the Report methods are
            % called with no input
            populateDefaultProperties( obj );
            
        end
        
        
        %% Set and get methods
        function set.savePath(obj, value)
            if ~isempty(value)
                
                if ~ischar(value)
                    error('Report:savePath', 'The savePath property must be a string')
                else
                    % If not a path, make it
                    checkPath(value);
                    obj.savePath = value;
                end
                
            end
        end
        
        function set.tableOptions(obj, value)
            if ~isa(value, 'TableOptionSettings')
                error([mfilename ':settableOptions'],'The tableOptions property must be a TableOptionSettings class')
            else
                obj.tableOptions = value;
            end
        end
        
        function set.plotOptions(obj, value)
            if ~isa(value, 'PlotOptionSettings')
                error([mfilename ':setplotOptions'],'The plotOptions property must be a PlotOptionSettings class')
            else
                obj.plotOptions = value;
            end
        end
        
        function x = get.rawDataTable( obj )
            if ~isempty(obj.proforObj)
                isRawDataPopulated = numel( obj.rawDataTable.Properties.VariableNames ) > 0;
                
                if ~isRawDataPopulated
                    x  = obj.proforObj.returnRawDataTables;
                    obj.rawDataTable = x;
                else
                    x = obj.rawDataTable;
                end
            else
                x = table();
            end
            
            
        end
        
        %% General Methods.
        
        % Methods for plotting figures.
        plotPointForecast(obj, plotVariableNames, maxHistoryPeriods)
        
        plotDensityForecast(obj, plotVariableNames, maxHistoryPeriods)
        
        plotWeightsOrScores(obj, dataType, modelNames, forecastHorizon)
        
        %% Profor specific methods.
        plotTotalEconomicLoss(obj, vblName, eventThreshold, modelNames, ...
            defaultModelName, forecastHorizon, eventType)
        
        plotProbabilityEventThreshold(obj, vblName, eventThreshold, modelNames, ...
            forecastHorizon, eventType)
        
        plotRelativeOperatingCharacteristics(obj, vblName, eventThreshold, modelNames, ...
            defaultModelName, forecastHorizon, eventType)
        
        plotProbabilityIntegralTransforms(obj, vblName, modelNames, forecastHorizon, ...
            realTimeTableExtractionType, scoreMethod, eventThreshold)
        
        plotPointForecastHistorical(obj, vblNames, modelNames, forecastHorizon,...
            realTimeTableExtractType)
        
        plotDensityForecastHistorical(obj, vblNames, modelNames, forecastHorizon,...
            realTimeTableExtractType)
        
        outTable = getProbabilityIntegralTransformsTests(obj, vblName, ...
            scoreMethod, modelNames, defaultModelName, forecastHorizon, eventThreshold)
        
        outTable = evaluatePointForecast(obj, vblName, ...
            scoreMethod, modelNames, defaultModelName, forecastHorizon, eventThreshold)
        
        outTable = getRealTimeTable(obj, vblName, modelNames, forecastHorizon, ...
            scoreMethod, outType, realTimeTableType, eventThreshold)
        
        outTable = getDensityForecastScoreTable(obj, vblName, modelNames, ...
            forecastHorizon, scoreMethod, requestedVintage, startPeriod, ...
            endPeriod, defaultModelName, eventThreshold)
        
    end
    
    methods(Access = private, Hidden = true)
        % Helper methods:
        populateDefaultProperties( obj ) 
        
        populateAllowableProperties( obj )
        
        populateResultTable( obj, scoreMethod, eventThreshold )
        
        argumentPassingScript( obj, inputNamesNeeded, numberOfInputArgs )
        
        extractModelProperties( obj, modelObj, errType )
        
        validateEstimationcombination( obj )
        
        % Used as input for plotWeightsOrScores.
        outTable = createWeightAndScoreTable( obj, dataType )
    end
    
    methods (Static = true, Hidden = true)
        
        c = cellstrCheck(x, y)
        
    end
end
