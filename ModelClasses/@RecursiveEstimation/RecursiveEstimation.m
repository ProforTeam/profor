classdef RecursiveEstimation < handle
    % RecursiveEstimation   This class is used to estimate, forecast or identify a
    %                       model recursively
    %
    % RecursiveEstimation Properties:
    %
    % RecursiveEstimation Methods:
    %
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
        outputNames                 % cellstr with output names from Model estimation that should be saved
        sample                      % string. Recursive estimation sample. Porgram uses data up to first date, and then recursively updates data length until end of sample
        type                    = CellObj({'Forecast'},'type',1,'restrictions',{'Forecast','Estimation'})
        realTime                = false;    % logical. If true, data is loaded for every recursion from real time data. If false, data is just trunkated
        saveRecursions          = false;    % logical. If true, save Model object for every iteration, if false, just save output
        saveNames                   % cellstr with suffix to be used for saved model recursions. Must be equal length as T
        
        savePath                = 'recursiveEstimation'; % string with savePath
        fixedEstimationSample   = false % logical. If true, start of estimation sample (for model) is recursively updated so that estimation sample length is fixed
        batch                           % Batch file for Model. Must be of Batch class
        data                            % Data object or string. Must be of Tsdata class. If string - path and filename to script for making data. See documentation
        dataPath                        % string with data path 
    end
    properties(SetAccess = protected)
        output                          % output structure. Will contain the defined output choices
        windowLength                    % length of estimation sample, if fixedEstimationSample is true.        
    end
    properties(Dependent = true, SetAccess = protected)
        state
        T                               % numeric. length of recursive samle
        dates                           % cs date vector for sample
        freq
    end
    properties(SetAccess = protected, Hidden = true);
        originalEstimationDates         % vector cs format. Original estimation sample
        originalEstimationLoadPeriods
        dates2quasiRealTimeMapper       % mapper for dates to quasi real time experiment
    end
    
    methods
        
        %% Constructor
        function obj = RecursiveEstimation()
            
        end
        
        %% Set and get mehtods
        function set.sample(obj, value)
            if ~ischar(value)
                error([mfilename ':setsample'],'The sample property must be a string')
            elseif ~isempty(value)
                [startD, endD] = getDates(value);
                if isempty(startD) || isempty(endD)
                    error([mfilename ':setsample'],'The sample property must be of the form ''1990.02 - 2000.01''')
                end
                if (endD/startD) < 1
                    error([mfilename ':setsample'],'The sample end must be after sample start')
                end
            end
            obj.sample = value;
        end
        
        function set.type(obj, value)
            if isa(value, 'CellObj')
                if value.type == obj.type
                    if ~any(strcmpi(value.x, obj.type.restrictions))
                        error([mfilename ':settype'],'Can not match the input of type with the restrictions.')
                    else
                        obj.type.x = value.x;
                    end
                else
                    error([mfilename ':settype'],'The type has wrong type')
                end
            else
                obj.type.x = value;
            end
        end
        
        function set.realTime(obj, value)
            if ~islogical(value)
                error([mfilename ':setrealtime'],'realTime input must be logical')
            end
            obj.realTime = value;
        end
        
        function set.saveRecursions(obj, value)
            if ~islogical(value)
                error([mfilename ':setsaverecursions'],'saveRecursions input must be logical')
            end
            obj.saveRecursions = value;
        end
        
        function set.fixedEstimationSample(obj, value)
            if ~islogical(value)
                error([mfilename ':setfixedsstimationsample'],'fixedEstimationSample input must be logical')
            end
            obj.fixedEstimationSample = value;
        end
        
        function set.batch(obj, value)
            if ~isa(value,'Batch') && ~isa(value,'Batchcombination')
                error([mfilename ':setbatch'],'batch input must be of class Batch or Batchcombination class')
            end
            obj.batch = value;
        end
        
        function set.data(obj, value)
            if ~isa(value,'Tsdata')
                error([mfilename  ':setdata'],'data input must be of class Tsdata')
            end
            obj.data = value;
        end
        
        function set.outputNames(obj, value)
            if ~iscellstr(value) && ~isempty(value)
                error([mfilename ':setoutputnames'],'outputNames input must be a cellstr')
            end
            obj.outputNames = value;
        end
        
        function set.windowLength(obj, value)
            if ~isempty(value)
                if value <= 0
                    error([mfilename ':setwindowlength'],'windowLength must be  larger than 0')
                else
                    obj.windowLength = value;
                end
            end
        end
        
        function set.saveNames(obj, value)
            if ~iscellstr(value)
                error([mfilename ':saveNames'],'saveNames must be a cellstr')
            else
                obj.saveNames = value;
            end
        end
        
        %% Dependent properties
        function x=get.state(obj)
            % check input and settings
            x = checkInputs(obj);
        end
        
        function x=get.T(obj)
            x = numel(obj.dates);
        end
        
        function x=get.dates(obj)
            if ~isempty(obj.batch) && ~isempty(obj.sample)
                x = sample2ttt(obj.sample, obj.freq);
            else
                x = [];
            end
        end
        
        function x=get.freq(obj)
            if strcmpi(obj.batch.method,'mfvar')
                x = 'm';
            else
                x = obj.batch.freq;
            end
        end
        
        %% General functions
        runRecursiveEstimation(obj)
        setRealTimeDataOrTruncate(obj, endDate, T, t)
        
    end
    
    methods(Access = protected)
        populateOutput(obj, m, t)
        x = checkInputs(obj)
        getYourStuff(obj)
        adjustBatchFile(obj, t)
    end
    
end