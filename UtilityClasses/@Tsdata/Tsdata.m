classdef(ConstructOnLoad = true) Tsdata < handle
    % Tsdata - A class to store, load and work with data
    %
    % This class supports multiple time series objects and is used in all
    % models in the PROFOR Toolbox
    %
    % Tsdata Properties:
    %
    %   dataSettings            - DataSetting class
    %   block                   - Optional
    %   misc                    - Optional
    %   number                  - Scalar
    %   desc                    - String
    %   ts                      - container.Map
    %   mnemonic                - String
    %   freq                    - String
    %   sesAdjState             - String, y or n
    %   trendAdjState           - String, y or n
    %   conversionState         - String, y or n
    %   transfState             - String, y or n
    %   outlierState            - String, y or n
    %   getSample               - String
    %   getMean                 - Numeric
    %   getStd                  - Numeric
    %   getOutliers             - Numeric
    %   getMissingValues        - Logical
    %   getData                 - Numeric
    %   getDates                - Numeric
    %   getTransfDescription    - String
    %   state                   - Logical
    %
    % Tsdata Methods:
    %   Tsdata                  - Constructor
    %   convertData             - Converts data intro different frequency
    %   intPolData              - Internpolates missing values
    %   sesAdjData              - Seasonally adjusts data
    %   trendAdjData            - Decomposes data into trend and cycle
    %   outlierCorrData         - Removes outliers
    %   transformData           - Transforms data (growth, log, etc.)
    %   standardizeData         - Standardizes data
    %   resetData               - Resets data back to state it had when constructed
    %   truncateData            - Truncates data
    %   setAll                  - Helper function for setting all properties (useful if Tsdata array)
    %   selectData              - Selects data from Tsdata (array) and returns data matrix
    %   plot                    - Plot function for Tsdata
    %
    %
    % Usage:
    %
    %   See <a href="matlab: opentoline(./help/helpFiles/htmlexamples/usingTsdataExample.m,1)">this example file</a>
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
    
    properties(SetObservable = true, AbortSet)
        % dataSettings - Contains properties used to transform and adjust the
        % data in Tsdata when calling the transformation methods associated with
        % this class, e.g., transformData, sesAdjData, etc.
        %
        % See also TRANSFORMDATA, DATASETTING
        dataSettings    = DataSetting;
        block           = 0;        % Optional usage. Default 0
        misc            = 0;        % Optional usage. Default 0
        number          = 1;        % Index number for data. (Must be unique if a Tsdata array)
        desc            = '';       % Meta data
    end
    
    properties(SetAccess = protected, SetObservable = true)
        % ts - Contains dates and data.
        %
        % See also GETDATA, GETDATES
        ts                          %
        mnemonic        = '';       % Name of series
        freq            = '';       % Data frequency, e.g., d, m, q or a for daily, monthly etc.
        sesAdjState     = 'n';      % Indicates whether or not seasonal adjustement has been conducted
        trendAdjState   = 'n';      % Indicates whether or not trend adjustement has been conducted
        conversionState = 'n';      % Indicates whether or not data has been converted
        transfState     = 'n';      % Indicates which transformation state the data has
        outlierState    = 'n';      % Indicates whether or not outlier correction has been conducted
    end
    
    properties(SetAccess = protected, Hidden = true)
        originalStruct  = struct(); % Stores the object at the state of construction
        changeLog                   % Stores information about every change that has been done to the object since construction
    end
    
    properties(Dependent = true)
        getSample                      % Sample of the data series
        getMean                        % Mean of data in data property
        getStd                         % Std of data in data property
        getOutliers                    % Vector (t x 1) with zeros and ones. Ones in places of outliers
        getMissingValues               % Indicator for missing values
        getData                        % Data vector (t x 1)
        getDates                       % Dates vector (t x 1). Cs format
        getTransfDescription           % Get information about the doTransfTo identifier
        
        state           = false;       % If true, data object is ok
    end
    
    properties(Constant = true, Hidden = true)
        neededProps             = {'ts', 'freq', 'mnemonic'};
        transformationMapObj    = TransformationMapping();
    end
    
    events
        usedMethod
    end
    
    methods
        
        function obj = Tsdata(dates,data,freq,mnemonic)
            % Tsdata - Class constructor method
            %
            % Input:
            %
            %   dates       [Numeric]   (t x 1) - cs date format
            %   data        [Numeric]   (t x 1)
            %   freq        [char]      frequency, e.g., d, m, q or a for daily, monthly etc.
            %   menmonic    [char]      name of series
            %
            % Output:
            %
            %   obj         [Tsdata]    Tsdata object
            %
            % Usage:
            %
            %   obj = Tsdata(dates,data,freq,mnemonic)
            %
            %
            
            
            if nargin == 4
                
                obj.mnemonic    = mnemonic;
                obj.freq        = freq;
                obj.ts          = Tsdata.setTs(dates,data);
                
                % Store original structure of data
                constructOrigStruct(obj);
                
            end
            
            % Add listener to object: This is used to store all changes
            % that occur.
            metaClassData           = metaclass(obj);
            metaProperties          = metaClassData.Properties;

            observableProperties    = [];
            for i = 1 : numel(metaProperties)
                observableProperties = cat( 2, observableProperties, ...
                    findobj(metaProperties{i}, 'SetObservable', true) );
            end

            % Add listeners for just after when the obeservableProperties are
            % set ('PostSet') and also for when a given method is used.
            addlistener(obj, observableProperties,  'PostSet',...
                @obj.handleSetObservableProperties);
            addlistener(obj, 'usedMethod',   @obj.handleUsedMethod);
            
        end
        
        %% Set and get methods
        function set.number(obj, value)
            if ~isscalar(value)
                error([mfilename ':setnumber'],'The number property must be a scalar')
            else
                obj.number = value;
            end
        end
        function set.block(obj, value)
            if ~isscalar(value)
                error([mfilename ':setblock'],'The block property must be a scalar')
            else
                obj.block = value;
            end
        end
        function set.misc(obj, value)
            obj.misc = value;
        end
        function set.mnemonic(obj, value)
            if ~ischar(value)
                error([mfilename ':setmnemonic'],'The mnemonic property must be a string')
            end
            obj.mnemonic = value;
        end
        function set.freq(obj, value)
            if ~any(strcmpi(value,{'d','m','q','a',''}))
                error([mfilename ':setfreq'],'The freq property bust be of a char')
            end
            obj.freq = value;
        end
        
        
        %% Dependet properties
        function value = get.getSample(obj)
            value   = getSample(obj.getDates);
        end
        function value = get.getMean(obj)
            value   = nanmean(obj.getData);
        end
        function value = get.getStd(obj)
            value   = nanstd(obj.getData);
        end
        function value = get.state(obj)
            % define the vital properties that need to be filled in for
            % state to be OK
            value   = false;
            props   = obj.neededProps;
            y       = false(1,numel(props));
            for i = 1 : numel(props)
                y(i) =~ isempty(obj.(props{i}));
            end
            if all(y)
                value = true;
            end
        end
        function value = get.getOutliers(obj)
            [~,idi] = outlierCorrection(obj.getData, ...
                'outlierMethod', obj.dataSettings.outlierMethod.x{:},...
                'setoutliers', obj.dataSettings.setOutliersAs);
            value   = idi;
        end
        function value = get.getMissingValues(obj)
            value   = any(isnan(obj.getData));
        end
        function value = get.getData(obj)
            value = vec(cell2mat(obj.ts.values));
        end
        function value = get.getDates(obj)
            value = vec(cell2mat(obj.ts.keys));
        end
        function value = get.getTransfDescription(obj)
            value = obj.transformationMapObj.dm(obj.transfState);
        end
        
        %% Functions/methods
        convertData(obj);
        intPolData(obj);
        sesAdjData(obj);
        trendAdjData(obj);
        outlierCorrData(obj);
        transformData(obj);
        standardizeData(obj);
        resetData(obj);
        truncateData(obj, endDate, varargin);        
        listAllDataTransformations( obj )
        
        setAll(obj, fieldname, value);
        [x, sampleDates, selectionChar, transf] = ...
            selectData(obj,selection,freq,sample);
        
        plot(obj, mnemonics, path);
        disp(obj);
    end
    
    methods(Hidden = true)
        constructOrigStruct(obj);
    end
    
    methods(Static = true, Hidden = true)
        ts          = setTs(dates, data)
        dates       = findLongestSample(y)
        
        %% Event functions
        handleSetObservableProperties(src, evnt)
        handleUsedMethod(src, evnt)
        fnamesP     = getPropertiesNotDependentAndConstant;
    end
    
end