classdef Batchcombination < Batch
    % Batchcombination - A class to define run settings for combining individual
    %                  models    
    %
    % Batchcombination is a child of Batch
    %
    % Batchcombination Properties:
    %     pathA                 - Char
    %     trainingPeriodSample  - Char
    %     isRollingWindow       - Logical
    %     loadPeriods           - CellObj
    %     forecastSettings      - ForecastSetting
    %     generalSettings       - GeneralSetting
    %     brierScoreSettings    - BrierScoreSetting
    %     densityScoreSettings  - DensityScoreSetting
    %     controlModels         - Logical
    %
    % See also BATCH
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
        % pathA - string defining the directory path where result files for
        % individual models are stored. This path should be the top level
        % directory, e.g., ./results , where the content of this directory
        % is a set of sub directories like ./results/M1 , ./results/M2 etc.
        % M1, M2 etc. are the result folders for the individual models
        %
        pathA              
        % trainingPeriodSample - char. Must follow the same format as
        % sample. If this property is defined, the combination routine will
        % use the specified trainingPeriodSample to initialize the weights.
        % That is, no combination will take place. Defaul = '', i.e., no
        % training sample is used.
        %
        % See also BATCH.SAMPLE
        trainingPeriodSample    = '';
        % isRollingWindow - Logical. If true, a rolling window is used for
        % computing the weights. For this to work, a trainingPeriodSample
        % must also be defined. Default = false.
        isRollingWindow         = false; 
        % loadPeriods - CellObj with cell defining which vintage periods to
        % combine ...
        loadPeriods             = CellObj([],'type',1); % Use this instead of default (names from sample)        
        % forecastSettings - ForecastSetting object. Defines properties
        % associated with forecasting
        %
        % See also FORECASTSETTING                
        forecastSettings        = ForecastSetting(); 
        % generalSettings - GeneralSettings object. Defines other general
        % settings
        %
        % See also GENERALSETTING
        generalSettings         = GeneralSetting();
        % brierScoreSettings - BrierScoreSetting object. Defines settings
        % for use with brier scoring
        %
        % See also BRIERSCORESETTING        
        brierScoreSettings      = BrierScoreSetting();
        % densityScoreSettings - DensityScoreSetting object. Defines settings
        % defining how densities should be evaluated
        %
        % See also DENSITYSCORESETTING                               
        densityScoreSettings    = DensityScoreSetting();
        % controlModels - logical. If true, program will load and control
        % all models prior to (loading them again) evaluating them. 
        % Default = true
        controlModels           = true; 
        
    end
    
    properties(Abstract = false, SetAccess = protected)
        method                  = 'combination';
    end
    
    properties(Abstract = false)
        freq                    = ''
    end
    
    properties(Dependent = true)
        onlyEvaluation         
    end        
    
    methods
        function obj = Batchcombination()
            % Batchcombination  Class constructor.
            
            % Overwrite the neededProps settings from Batch
            %obj.neededProps={'selectionY','selectionA','sample','freq','links','pathA','xDomain'};
            obj.neededProps = {'selectionY','selectionA','sample','freq','links','pathA'};
            
            obj.modelName   = 'Combo';
        end
        
        %% Set/ Get  Methods.
        function set.loadPeriods(obj,value)
            obj.loadPeriods = Batch.setCellObj(obj.loadPeriods,value);
        end
        
        function set.pathA(obj,value)
            if ~isempty(value)
            % Check if the path exist.
                checkPath(value);
                if strcmpi(value(end),'/')
                    obj.pathA = value(1:end-1);
                else
                    obj.pathA = value;
                end;                                
            end
        end                
        
        function set.freq(obj,value)
            if isnumeric(value)
                value = convertFreqN(value);
            end
            obj.freq = value;
        end        
        
        function set.onlyEvaluation(obj,value)
            if ~islogical(value)
                error([mfilename ':setonlyEvaluation'],'The onlyEvaluation property must be a logical')
            end
            obj.onlyEvaluation = value;
        end
        
        function set.trainingPeriodSample(obj,value)
            if ~ischar(value)
                error([mfilename ':settrainingPeriodSample'],'The trainingPeriodSample property must be a string')
            elseif ~isempty(value)
                [startD, endD] = getDates(value);
                if isempty(startD) || isempty(endD)
                    error([mfilename ':settrainingPeriodSample'],'The trainingPeriodSample property must be of the form ''1990.02 - 2000.01''')
                end
                if (endD/startD)<1
                    error([mfilename ':settrainingPeriodSample'],'The trainingPeriodSample end must be after sample start')
                end
            end
            obj.trainingPeriodSample = value;
        end
        
        function set.isRollingWindow(obj,value)
           if ~islogical(value)
               error([mfilename ':setisRollingWindow'],'The isRollingWindow must be a logical')
           else
               obj.isRollingWindow = value;
           end            
        end
        
        function set.forecastSettings(obj,value)
            if ~isa(value,'ForecastSetting')
                error([mfilename ':setforecastSettings'],'The forecastSettings property must be a ForecastSetting class')
            else
                obj.forecastSettings = value;
            end
        end
        
        function set.generalSettings(obj,value)
            if ~isa(value,'GeneralSetting')
                error([mfilename ':setgeneralSettings'],'The generalSettings property must be a GeneralSetting class')
            else
                obj.generalSettings = value;
            end
        end
        
        function set.brierScoreSettings(obj, value)
            if ~isa(value,'BrierScoreSetting')
                error([mfilename ':setbrierScoreSettings'],'The brierScoreSettings property must be a BrierScoreSetting class')
            else
                obj.brierScoreSettings = value;
            end
        end        
        
        function set.densityScoreSettings(obj, value)
            if ~isa(value,'DensityScoreSetting')
                error([mfilename ':setdensityScoreSettings'],'The densityScoreSettings property must be a DensityScoreSetting class')
            else
                obj.densityScoreSettings = value;
            end
        end                        
        
        function set.controlModels(obj,value)
            if ~islogical(value)
                error([mfilename ':setcontrolModels'],'The controlModels property must be a logical')
            end
            obj.controlModels = value;
        end                
        
        function x = get.onlyEvaluation(obj)            
            if obj.selectionA.numc > 1
                x = false;
            else
                x = true;
            end            
        end
        
        %% General methods in separate files.
        x  = checkBatchSettings( obj )
        xx = checkInitialization(obj, obje)                               
        periods  = returnPeriodCorrectedForTrainingSample(obj)    
        
    end
    
end