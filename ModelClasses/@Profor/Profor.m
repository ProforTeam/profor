classdef Profor < handle
    % Profor - Class to estimate and forecast individual models and combine them
    %          recursively.
    %   It runs the combination of these models recursively (i.e., real-time
    %   out-of-sample experiment). Note, this class does not produce any
    %   "output" on it's own. Instead, for each model and each vintage that
    %   is combined, results are saved to disk following the input
    %   specifications, see below. 
    %
    % Profor Properties:
    %     onlyDoLast        - Logical         
    %     savePath          - Char         
    %     modelSetupPath    - Char
    %     doModels          - Logical
    %     doCombination     - Logical
    %     data              - Tsdata
    %    
    % Profor Methods:
    %     Profor            - Constructor 
    %     runProfor         - Executes the Profor class
    %     evaluateProfor    - Returns a Report class object with results
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/proforExample.m,1)">this example file</a>
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

    properties
        % onlyDoLast - logical. If true, only the last vintage of data will
        % be estimated
        onlyDoLast          = false;
        % savePath - string with path pointing to where recusive results should 
        % be stored
        savePath                        
        % modelSetupPath  - string with path pointing to where the batch files for
        % each individual model and the combination are stored
        modelSetupPath 
        % doModels - logical. If true, all individual models will be
        % estimated, forecasted and saved across all vintages in the
        % experiment. Default = true. Set to false if model results have
        % already been computed (to save time)
        doModels            = true;
        % doCombination - logical. If true, all combination models will be
        % estimated, forecasted and saved across all vintages in the
        % experiment. Default = true. 
        doCombination       = true;
        % data - Tsdata. If supplied, the program will use this as the data
        % in the experiment. The data will be truncated for each t-1
        % vintage used in the experiment (i.e., quasi-real time experiment)
        %
        % See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/proforSimulatedDataExample.m,1)">this example file</a>        
        data
    end
    
    properties(Constant = true, Hidden = true)
        neededProps     = {'savePath','modelSetupPath'};
        method          = 'profor';
    end
    
    properties(SetAccess = protected, Hidden = true)
        % stateModelOverview - matrix with logicals. Shows which models are
        % estimated ok and not across time
        stateModelOverview
        % stateComboOverview - matrix with logicals. Shows which combinations are
        % estimated ok and not across time        
        stateComboOverview
        % estimationState - logical. True if program execution is ok, i.e.,
        % all entries in stateModelOverview and stateComboOverview is true
        estimationState
        % tElapsed - computation time
        tElapsed
        % errorStack - Collects all the errors encountered during the running of
        % the program (apart from errors in setting the batch). If
        % estimationState = true, this is empty
        errorStack              
        original_warningState   % Matlab varaible containing information about warnings
        realTime                % Defined by data supplied or not
    end
    
    properties(Dependent = true)
        state
    end
    
    properties(Dependent = true, Hidden = true)
        pathA
    end    
    
    methods
        
        function obj = Profor()
            % Profor        Constructor method. Takes no input arguments
            
        end
        %% Set and get function
        function set.onlyDoLast( obj,value )
            if ~islogical( value )
                error([mfilename ':setonlyDoLast'], ...
                    'The onlyDoLast property must be a logical')
            else
                obj.onlyDoLast  = value;
            end
        end
        function set.savePath(obj, value)
            
            if ~isempty( value )
                % Check if the path exist.
                checkPath( value );
                if strcmpi(value(end),'/')
                    obj.savePath = value(1:end-1);
                else
                    obj.savePath = value;
                end;
            end
        end
        function set.doModels(obj,value)
            if ~islogical(value)
                error([mfilename ':setdoModels'],'The doModels property must be a logical')
            else
                obj.doModels=value;
            end
        end
        
        function set.doCombination(obj,value)
            if ~islogical(value)
                error([mfilename ':setdoCombination'],'The doCombination property must be a logical')
            else
                obj.doCombination=value;
            end
        end
        function set.data(obj,value)
            if ~isa(value,'Tsdata')
                error([mfilename ':setdata'],'The data property must be a Tsdata class')
            else
                obj.data = value;
            end;
        end;
        function set.modelSetupPath(obj,value)
            if ~isempty(value)
                % Check if the path exist.
                checkPath(value);
                if strcmpi(value(end),'/')
                    obj.modelSetupPath  = value(1:end-1);
                else
                    obj.modelSetupPath  = value;
                end;
            end
        end
        
        function x = get.state(obj)
            % define the vital properties that need to be filled in for
            % state to be OK
            x       = false;
            props   = obj.neededProps;
            y       = [];
            
            for i = 1 : numel( props )
                
                if isa(obj.(props{i}), 'CellObj')
                    y       = cat(2, y, ~obj.( props{i} ).default);
                    
                else
                    y       = cat(2, y, ~isempty( obj.(props{i}) ));
                end
            end
            
            if all(y)
                
                load(fullfile(obj.modelSetupPath ,'Combo.mat'));
                % Check state of the combo file
                if ~b.state
                    error([mfilename ':batchfile'],'The loaded combination batch file is not correctly specified')
                end;
                
                x = true;
                
            end
        end
        
        function x = get.estimationState( obj )
            x = false;
            if isempty( obj.estimationState )
                % if empty, you have probably not run the experiment, but
                % only supplied the paths etc. Then we need to check if
                % there is acutally results etc. in the paths you have
                % defined
                if obj.state 
                    load(fullfile(obj.modelSetupPath,'Combo.mat'));                    
                    
                    % get the vintages used and check
                    % if the folders with results exist.
                    vintagesUsed    = b.loadPeriods.x;
                    variableNames   = b.selectionY.x;
                    
                    for i = 1:numel(variableNames)
                        for j = 1:numel(vintagesUsed)                                                
                            status = exist( fullfile(obj.savePath,'models',['Combination_' variableNames{i}],'results',vintagesUsed{j},'m.mat'), 'file');
                            % status  should be 2 for an .m file. If it does
                            % not exist, something is not ok, and
                            % estimationState remains false.
                            if status ~= 2
                                return
                            end                            
                        end                    
                    end
                    
                    x = true;
                end
                                
            else
                x = obj.estimationState;
            end
        end
        
        function x = get.pathA(obj)
            x = obj.modelSetupPath;
        end
        
        %% Other (external) functions
        obj                 = runProfor( obj )        
        reportObj           = evaluateProfor( obj )
        
    end
    
    methods(Static = true)
        W = getDateVintageTable( estimationObj )        
    end
    
    methods(Hidden = true)
        % Methods to extract results and raw data.
        outTable            = returnRawDataTables( obj )               
        outTable            = returnResultTables( obj, scoreMethod, eventThreshold )        
        cleanup( obj )
    end
    
    methods(Static = true, Hidden = true)
        [runState, errorStack]  = runModelsRecursively(bc, savePath, onlyDoLast, realTime,errorStack)
        runState                = runModelsRecursivelyParFor(bc, savePath, onlyDoLast, realTime, i)
        [runState, errorStack]  = runComboRecursively(bc, savePath, onlyDoLast, realTime, errorStack)
        original_warningState   = warningControls(original_warningState)
        printErrorStack(errorStack)
        
    end
    
end
