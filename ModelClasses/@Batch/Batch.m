classdef (ConstructOnLoad=true) Batch < handle
    % Batch  -   A class to define run settings for individual models.
    %            Abstract class, can not be initialized
    %
    % Batch Properties:
    %   selectionY          - Cellobj
    %   selectionX          - CellObj
    %   selectionA          - CellObj
    %   sample              - Char
    %   dataSettings        - CellObj
    %   simulationSettings  - SimulationSetting
    %   dataPath            - Char
    %   state               - Logical
    %   savePath            - Char
    %   modelName           - Char
    %
    % Batch Methods:
    %
    % Usage:
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/constructAndStoreBatchFilesExample.m,1)">this example file</a>
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
        % selectionY - CellObj defining the observable variables to be used
        % in the model. Must be defined as a cellstr, where each element refers
        % to a mnemonic in the Tsdata array supplied to Model
        %
        % See also MODEL, CELLOBJ
        selectionY          = CellObj([], 'type', 1);
        % selectionX - CellObj defining any exogenous variables to include
        % in the model (constant is included by default). Must be defined as a
        % cellstr, where each element refers to a mnemonic in the Tsdata array
        % supplied to Model
        %
        % See also MODEL, CELLOBJ
        selectionX          = CellObj({'const'}, 'type', 1);
        % selectionA - CellObj defining the state variables to be used
        % in the model. Must be defined as a cellstr, where each element refers
        % to a mnemonic in the Tsdata array supplied to Model. If no state
        % variables defined, e.g., for VARs, BVARs etc. there is no need to
        % set this property
        %
        % See also MODEL, CELLOBJ
        selectionA          = CellObj([], 'type', 1);
        % sample - string in the format: year.period - year.period, where year
        % is, e.g., 2000 and period is 04 for quarter 4 or 12 for month 12.
        % Example: '1990.02-2000.01'
        sample              = '';
        % dataSettings - DataSetting object. Used to transform the data
        % before estimation when running Model. If dataSettings is not set
        % in Batch, i.e., its state is default, no transformation of the
        % data will be conducted before estimation. That is, the Tsdata
        % array supplied to the Model object will be used as is.
        %
        % See also DATASETTING, MODEL
        dataSettings        = CellObj([], 'type', 5, 'sameSizeAs', 'selectionY');
        % simulationSettings - SimulationSetting object. Defines the number of
        % simulations etc.
        %
        % See also SIMULATIONSETTING
        simulationSettings  = SimulationSetting();
        % dataPath - string. This is only used if you run a Profor experiment.
        % Then real time data can be loaded in for each recursion in the
        % experiment. The data will be loaded from the dataPath directory
        dataPath
        % savePath - string with directory path. Required to save model object
        % using saveo method. savePath should not include the model name,
        % but only the directory path
        savePath
        % modelName - string with the name of the model, e.g., M1.
        modelName
    end
    
    properties(Abstract = true, SetAccess = protected)
        % method - The model type you want to use. Each model type has its own
        % batch
        method
    end
    
    properties(Abstract = true)
        freq
    end
    
    properties(SetAccess = protected)
        % links - Used for temporary storage. Copied from Model
        links           = 'Only a Model class can set this!';
        % state - Logical. If all settings in batch is ok = true.
        % Needs to be true for Model to run! Determined by object itself
        %
        % See also MODEL
        state
    end
    
    properties(SetAccess=protected,Hidden)
        % Needed properties to set (for state to be true)
        neededProps     = {'selectionY', 'sample', 'freq', 'links'};
    end
    
    methods
        function obj = Batch()
            % Batch     Class constructor.
        end
        
        %% Set / Get Methods.
        function set.sample(obj, value)
            if ~ischar(value)
                error([mfilename ':setsample'],'The sample property must be a string')
            elseif ~isempty(value)
                [startD,endD] = getDates(value);
                if isempty(startD) || isempty(endD)
                    error([mfilename ':setsample'],'The sample property must be of the form ''1990.02 - 2000.01''')
                end
                if (endD/startD)<1
                    error([mfilename ':setsample'],'The sample end must be after sample start')
                end
            end
            obj.sample = value;
        end
        
        function set.selectionY(obj, value)
            if isa(value,'CellObj')
                if value.type == obj.selectionY.type
                    obj.selectionY = value;
                else
                    error([mfilename ':setselectionY'],'The selectionY has wrong type')
                end
            else
                obj.selectionY.x = value;
            end
        end
        
        function set.selectionX(obj, value)
            if isa(value,'CellObj')
                if value.type == obj.selectionX.type
                    obj.selectionX = value;
                else
                    error([mfilename ':setselectionX'],'The selectionX has wrong type')
                end
            else
                obj.selectionX.x = value;
            end
        end
        
        function set.selectionA(obj, value)
            if isa(value,'CellObj')
                if value.type == obj.selectionA.type
                    obj.selectionA = value;
                else
                    error([mfilename ':setselectionA'],'The selectionA has wrong type')
                end
            else
                obj.selectionA.x = value;
            end
        end
        
        function set.dataSettings(obj, value)
            if isa(value, 'CellObj')
                if value.type == obj.dataSettings.type
                    obj.dataSettings    = value;
                else
                    error([mfilename ':setdataSettings'], ...
                        'The dataSettings has wrong type')
                end
            else
                obj.dataSettings.x  = value;
            end
        end
        
        function set.dataPath(obj,value)
            %[pathstr,name,ext] = fileparts(value);
            if ~isempty(value)
                checkPath(value);
                if strcmpi(value(end),'/')
                    obj.dataPath = value(1:end-1);
                else
                    obj.dataPath = value;
                end;
            end
        end
        function set.simulationSettings(obj, value)
            if ~isa(value, 'SimulationSetting')
                error([mfilename ':setgeneralSettings'],'The simulationSettings property must be a SimulationSetting class')
            else
                obj.simulationSettings = value;
            end
        end
        
        function set.savePath(obj,  value)
            if ~isempty(value)
                checkPath(value);
                if strcmpi(value(end),'/')
                    obj.savePath = value(1:end-1);
                else
                    obj.savePath = value;
                end;
            end
        end
        
        function set.modelName(obj, value)
            if ~isempty(value)
                if ~ischar(value)
                    error([mfilename ':setmodelName'],'modelName must be a string')
                else
                    
                    if isa(obj, 'Batchcombination') 
                        if ~strcmpi(value, 'Combo')
                            error([mfilename ':setmodelName'],'modelName can not be Combo when the Batch object is not a Batchcombination')        
                        else
                            obj.modelName = 'Combo';
                        end
                    else
                        obj.modelName = value;                        
                    end
                    
                end
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
                x       = checkBatchSettings(obj);
            end
        end
        
        %% General methods in separate files.
        x  = checkBatchSettings( obj )
        xx = checkBatchAgainstData(obj, data)
        saveo (obj )
    end
    
    methods(Static)
        changeLinks( mobj )
        cellObj = setCellObj(cellObj, value)
    end
end
