classdef TsdataForecast < Tsdata
    % TsdataForecast - A class to store, load and work with forecasts
    %
    % This class supports multiple time series objects and is used in all
    % models in the PROFOR Toolbox. TsdataForecast is a child of Tsdata
    %
    % The data in this object will be a combination of history and
    % forecasts. These are treated as one time series vector (matrix for
    % the simulations) when operations are conducted on the data. Separate
    % functions apply to extract the different parts of the data (history
    % and forecasts)
    %
    % TsdataForecast Properties:
    %   confidenceIntMethod     - Cell
    %   alphaSign               - SCALAR
    %   getHistory              - Numeric
    %   getHistoryLevel         - Numeric
    %   getHistoryDates         - Numeric           
    %   getForecast             - Numeric           
    %   getForecastDates        - Numeric           
    %   getForecastSimulations  - Numeric           
    %   getForecastDensity      - Numeric           
    %   getForecastxDomain      - Numeric                                                   
    %   getForecastQuantiles    - Numeric            
    %   getNfor                 - SCALAR
    %   getDraws                - SCALAR
    %
    % Tsdata Methods:
    %   TsdataForecast          - Constructor
    %
    % See also TSDATA 
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
        % confidenceIntMethod - Defines the method used to construct confidence
        % intercals. Type obj.confidenceIntMethod.restrictions for the different 
        % options
        confidenceIntMethod = CellObj({'quantile'}, 'type', 1,....
            'restrictions', {'quantile'}); 
        % alphaSign - Defines the significance level used when constructing
        % confidence intervals
        alphaSign           = 0.1; 
    end        

    properties(Hidden = true) 
        xDomainLength       = 500;                
    end
    
    properties(SetAccess = protected, Hidden = true)            
        % tsHistoryLevel - Contains historical level of data (if supplied)
        %
        % See also GETHISTORYLEVEL
        tsHistoryLevel            
        % tsSimulations - Contains emperical distribution of forecasts
        %
        % See also GETFORECASTSIMULATIONS        
        tsSimulations        
        isHistoryLevel   = false;   
        forecastStartIdx = 1;
    end
                               
    properties(Dependent = true)                    
        getHistory                  % Vector with historical values
        getHistoryLevel             % Vector with historical values in levels
        getHistoryDates             % Vector with historical dates (cs format)
        
        getForecast                 % Vector with forecasts
        getForecastDates            % Vector with forecast dates
        getForecastSimulations      % Matrix with forecast simulations
        % getForecastDensity - Matrix with forecast simulations. Program
        % uses ksdensity to create the density. xDomain length is fixed
        %
        % See also GETFORECASTXDOMAIN
        getForecastDensity                          
        % getForecastxDomain - xDomain used to construct density
        %
        % See also GETFORECASTDENSITY
        getForecastxDomain          
        % getForecastQuantiles - Matrix (nfor x 3) with median, and upper
        % and lower tails of forecast distribution. Uses properties 
        % alphaSign and confidenceIntMethod
        getForecastQuantiles                
        getNfor                     % Number of forecast horizons
        getDraws                    % Number of draws used to generate simulated forecasts
    end
    
    properties(Constant, Hidden = true)
        notNeeded           = {'historyLevel'};        
        minHistoryLength    = 20;
    end
    
    methods
        
        function obj = TsdataForecast(mnemonic, forecastPoint,...
                forecastSimulations, forecastDates, transfState, history,...
                historyDates, freq, historyLevel)            
            % TsdataForecast - Class constructor method                                    
            %
            % Input: 
            % 
            %   menmonic                [char]
            %                           name of series            
            %   forecastPoint           [Numeric]
            %                           (tf x 1) 
            %   forecastSimulations     [Numeric]
            %                           (tf x draws) 
            %   forecastDates           [Numeric]
            %                           (tf x 1) - cs date format
            %   transfState             [char]
            %                           see TransformationMapping.keySet
            %   history                 [Numeric]
            %                           (th x 1) 
            %   historyDates            [Numeric]
            %                           (th x 1) - cs date format
            %   freq                    [char]
            %                           Frequency, e.g., d, m, q or a for daily, 
            %                           monthly etc.            
            %   historyLevel            [Numeric]
            %                           Empty or (th x 1) vector. See below
            %                           
            % Output:
            % 
            %   obj         [TsdataForecast], a TsdataForecast object
            %
            % Usage:
            %
            %   obj = TsdataForecast(mnemonic, forecastPoint,...
            %    forecastSimulations, forecastDates, transfState, history,...
            %    historyDates, freq, historyLevel)                        
            %
            % Note: 
            %   If historyLevel is empty, the data within the object can
            %   not be transformed to different transformations. E.g., if
            %   forecasts and history is 'gr', and you want to apply the
            %   transformation 'gryoy', this will NOT be possible unless 
            %   historyLevel is supplied to the constructor.
            % 
            
            
            
            if nargin == 9        
                
                                
                % Check that the input has correct sizes etc. relative to
                % each other
                transfState = TsdataForecast.checkInput(forecastPoint, forecastSimulations,...
                    forecastDates, history, historyDates, historyLevel, transfState);
                                                
                obj.mnemonic                = mnemonic;                                  
                obj.transfState             = transfState;                   
                obj.freq                    = convertFreqN(freq);                
                                                             
                obj.forecastStartIdx        = numel(history) + 1; 
                % Construct cell object of forecastSimulations to put into
                % ts property                                
                obj.ts                      = TsdataForecast.setTs([historyDates;forecastDates], [history;forecastPoint]);                
                obj.tsSimulations           = TsdataForecast.setTs(forecastDates, forecastSimulations);                                                
                if ~isempty(historyLevel)
                    obj.tsHistoryLevel      = TsdataForecast.setTs(historyDates, historyLevel);                                
                    obj.isHistoryLevel      = true;
                else
                    obj.isHistoryLevel      = false;
                end
                
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
        function set.alphaSign(obj, value)
           if ~isscalar(value)
               error([mfilename ':setalphaSign'],'alphaSign must be a scalar');
           else
               if value <= 0 || value >= 1
                   error([mfilename ':setalphaSign'],'alphaSign must be larger than 0 and less than 1');
               else
                  obj.alphaSign = value; 
               end
           end            
        end        
        function set.confidenceIntMethod(obj, value)
            obj.confidenceIntMethod = Batch.setCellObj(obj.confidenceIntMethod, value);            
        end
        function set.xDomainLength(obj,value)
            if isscalar(value)
                if value > 100 
                    obj.xDomainLength = value;
                else
                    error([mfilename ':setxDomainLength'], 'The xDomainLength property must be larger than 100')
                end
            else
                error([mfilename ':setxDomainLength'], 'The xDomainLength property must be a scalar')
            end
            
        end        
        
        
        %% Dependet properties
        function value = get.getHistory(obj)
            x       = cell2mat(obj.ts.values');                                           
            value   = x(1 : obj.forecastStartIdx - 1);
        end
        function value = get.getHistoryLevel(obj)
           if obj.isHistoryLevel
               value = cell2mat(obj.tsHistoryLevel.values');                                           
           else
               value = [];
           end            
        end
        function value = get.getHistoryDates(obj)
            x       = vec(cell2mat(obj.ts.keys));  
            value   = x(1 : obj.forecastStartIdx - 1);
        end        
        function value = get.getForecast(obj)
            x       = cell2mat(obj.ts.values')';                                           
            value   = vec(x(obj.forecastStartIdx : end));            
        end
        function value = get.getForecastDates(obj)
            x       = vec(cell2mat(obj.ts.keys));                                   
            value   = x(obj.forecastStartIdx : end);            
        end                               
        function value = get.getForecastSimulations(obj)
            value = cell2mat(obj.tsSimulations.values');                                                       
        end                
        function value = get.getForecastDensity(obj)
            draws = obj.getDraws;
            if draws > 1                          
                x           = obj.getForecastSimulations;                
                [~,y,~,x]   = getDrawSelections(x,obj.alphaSign,draws,'method',obj.confidenceIntMethod,'value0',obj.getForecast);    
                y           = permute(y,[1 3 2]);
                x           = permute(x,[1 3 2]);
                
                xDomain     = forecastFns.getxDomain(y,obj.xDomainLength);                                
                value       = forecastFns.kernelDensityEstimate(x,xDomain);                                
            else
                value = [];
            end                                                        
        end        
        function value = get.getForecastxDomain(obj)
            draws = obj.getDraws;
            if draws > 1                          
                x           = obj.getForecastSimulations;                
                [~,y,~,~]   = getDrawSelections(x,obj.alphaSign,draws,'method',obj.confidenceIntMethod,'value0',obj.getForecast);    
                y           = permute(y,[1 3 2]);                                
                value       = forecastFns.getxDomain(y,obj.xDomainLength);                                                                        
            else
                value       = [];
            end                                                                                            
        end                                  
        function value = get.getForecastQuantiles(obj)
            draws = obj.getDraws;
            if draws > 1                                      
                x           = obj.getForecastSimulations;                
                [~, value]  = getDrawSelections(x,obj.alphaSign,draws,'method',obj.confidenceIntMethod,'value0',obj.getForecast);
            else
                value       = [];
            end                
        end                
        function value = get.getNfor(obj)
            value = size(obj.getForecast,1);
        end
        function value = get.getDraws(obj)
            value = size(obj.getForecastSimulations,2);
        end        
        %% Functions/methods            
        
    end
    
    methods(Hidden = true)
        %% Functions/methods            
        [dataPoint, dataDates, dataHistoryLevel, dataHistoryDates,...
            forecastSimulations, forecastStartIdx] = extractNeededInformation(obj)                
    end
    
    methods(Hidden = true, Static = true)                
        
        fnamesP     = getPropertiesNotDependentAndConstant;              
        ts          = setTs(dates, data);
        
        transfState = checkInput(forecastPoint, forecastSimulations, forecastDates,...
            history, historyDates, historyLevel, transfState);        
    end 

end