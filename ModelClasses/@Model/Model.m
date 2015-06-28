classdef Model < handle
    % Model - A class to estimate and forecast individual models. Used as a
    % container object for all properties and output from indiviudal model
    % estimation etc. 
    %
    %
    % Model Properties:
    %   data                - Tsdata
    %   savePath            - Char
    %   estimation          - Estimation
    %   forecast            - Forecast
    %   time                - Char
    %   ttElapsed           - Char  
    %   state               - Logical
    %   supportedMethods    - Cellstr
    %
    % Model Methods:
    %   Model               - Constructor 
    %   runModel            - Runs model object (estimates and forecast)
    %   runEstimation       - Runs model object (estimation only)
    %   runForecast         - Runs model object (forecast only)
    %   saveo               - Saves object to disk
    %
    % Usage: 
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/runningModelsExample.m,1)">this example file</a>
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
        % data - Tsdata object to store data used in model.
        %
        % See also TSDATA
        data        = Tsdata;
        % savePath - string with directory path. Required to save model object 
        % using saveo method
        savePath                
    end
    
    properties(SetAccess=private)
        % estimation - Contains estimation results. Populated by object
        % only
        %
        % See also MODEL.RUNMODEL
        estimation              
        % forecast - Contains forecasting results. Populated by object
        % only
        %
        % See also MODEL.RUNMODEL        
        forecast 
        time                    % Date/Time of constructing the object
        ttElapsed               % Total time used in estimation, forecasting etc.
        method      = 'var';        
    end
    
    properties(Dependent=true)
        % state - Logical. True if model is ready for running. 
        % I.e. if batch file is correct, data object is supplied etc.        
        state
    end
    
    properties(Dependent=true, Hidden = true)
        showProgress        
    end    
    
    properties(Constant=true)
        % supportedMethods - Cellstr. Constant property. 
        % Type Model.supportedMethods to see which model types that is
        % supported by this class        
        supportedMethods = {'var', 'bvar', 'bvartvpsv', ...
            'combination', 'profor', 'externalanalytic', ...
            'externalempiric','tvar','barmixture'};
    end
    
    properties(SetAccess = private, Hidden = true)
        batch                   % Defines your settings                
        links                   % Used for temporary storage
    end
    
    methods
        function m = Model(method, batch, data)
            % Model     Class constructor
            %
            % Input: 
            %
            %   method     [char]
            %              Must be one of the Model.supportedMethods
            %
            %   batch      [Batch]
            %              Batch class associated with method
            %
            %   data        [Tsdata]
            %
            % Output:
            %
            %   m           [Model]
            %
            % Usage: 
            % 
            %   There are to ways to initilaize the Model object:
            %   m = Model(method, batch, data)
            %   m = Model 
            %   
            %   In the latter case, with no input, the method and batch
            %   properties will automatically be for a VAR model. 
            %
            %
            
            if nargin > 0
                m.method    = method;
                
                if nargin > 1
                    
                    if ~strcmpi( method, batch.method)
                        error([mfilename ':input'], 'The batch property must be of the same type as method and Batch class')
                    else
                        
                        m.batch     = batch;
                    end
                    
                    if nargin == 3
                        m.data      = data;
                    end
                end
            end
            % Evaluate the appropriate batch file and add the estimation and 
            % forecast properties to the Model object.
            addProps(m);
            
            % Save the model name and path to strut field: obj.link.
            giveMeMyModelTag(m);
            
            m.time                  = date;
        end
        
        % Set functions
        function set.data(obj, data)
            if ~isa(data, 'Tsdata')
                error([mfilename ':setdata'],'The data property must be of a Tsdata class')
            end
            obj.data    = data;
        end
        
        function set.batch(obj, value)
            if  ~isa(value, 'Batch')
                error([mfilename ':setbatch'],'The batch property must be of Batch class')
            end
            obj.batch   = value;
        end
        
        function set.method(obj, value)
            if any(strcmpi(value, obj.supportedMethods))
                obj.method  = lower(value);
                % Seem to get error when lower is used (NB)
                %obj.method  = value;
            else
                error([mfilename ':setmethod'],'The method supplied is not recognised')
            end
        end
        
        function set.savePath(obj, value)
            if ~ischar(value)
                error([mfilename ':setsavePath'],'The savePath property must be a string')
            end
            
            [path, ~]   = fileparts(value);
            
            if strcmpi(path,[proforStartup.pfRoot '\temp'])
                error([mfilename ':setsavePath'],'You can not save to the temp folder of the Profor Toolbox. This is only used for temporary storage')
            end
            
            % If not a path, make it
            checkPath(value);
            obj.savePath    = value;
        end
        
        function set.links(obj, value)
            
            if ~isstruct(value)
                error([mfilename ':setlinks'],'links must be a structure')
                
            else
                fnames     = fieldnames(value);
                %                  if ~all(strcmpi({'tag';'filePath';'DB'},fnames))
                %                      error('Model:setlinks','Fieldnames must be tag, DB and filePath')
                %                  end
                if ~all(strcmpi({'tag';'filePath'}, fnames))
                    error([mfilename ':setlinks'],'Fieldnames must be tag and filePath')
                end
                
                if ~ischar(value.tag)
                    error([mfilename ':setlinkstag'],'tag must be a char')
                end
                
                %                 if ~isa(value.DB,'COM.ADODB_Connection') && ~isa(value.DB,'handle')
                %                     error('Batch:setlinksDB','DB must be a COM.ADODB_Connection')
                %                 end
                
                if ~ischar(value.filePath)
                    error([mfilename ':setlinksfilePath'],'filePath must be a char')
                end
                
                obj.links   = value;
                Batch.changeLinks( obj );
            end
        end
        
        function x = get.links( obj )
            
            if isdir(obj.links.filePath)
                x   = obj.links;
                
            else
                giveMeMyModelTag(obj)
                x   = obj.links;
            end
        end
        
        function x = get.ttElapsed( obj )
            
            isEstimation           = isa(obj.estimation, 'Estimation');
            isEstimationCobination = isa(obj.estimation, 'Estimationcombination');
            isEstimationProfor     = isa(obj.estimation, 'Estimationprofor');
            
            if isEstimation || isEstimationCobination || isEstimationProfor
                
                x   = obj.estimation.tElapsed;
                
                if isa(obj.forecast, 'Forecast')
                    
                    if ~isempty( obj.forecast.tElapsed )
                        x       = x + obj.forecast.tElapsed;
                    end
                    
                end
            else
                x   = [];
            end
        end
        
        function x = get.showProgress( obj )           
            x = obj.batch.simulationSettings.showProgress;
        end        
        
        function x = get.state( obj )
            % get.state     Check that data property and batch property settings
            %               are compatible. Used before trying to run model
            
            x   = false;
            
            % Only check state if both batch and data are ready
            if obj.batch.state && all( [obj.data.state] )
                x   = obj.batch.checkBatchAgainstData( obj.data );
                if ~x
                    error([mfilename ':state'],'Your batch and data settings do not match. Check your settings')
                end                
            end
%             else
%                 warning([mfilename ':state'],'Your batch and or data settings are not ready')
%             end
            
        end        
        
        runModel(obj)
        runEstimation( obj )
        runForecast( obj )
        addProps( obj )
        saveo(obj)
        giveMeMyModelTag( obj )
    end
    
    methods(Static)
        obj = loado( path )
        copyModel(mobj, savePath)
    end
end

