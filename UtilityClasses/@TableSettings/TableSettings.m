classdef TableSettings
    % TableSettings - Stores the transformations required for input table entries
    %
    % Usaage: TableSettings(colName, replicateIntoCol, colDescription, ...
    %                       convertToCategorical)
    % e.g. TableSettings('evaluationDate', false, 'Date evaluated forecast', true)
    %
    % See Also: 
    %   RETURNTABLE
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
        colName                 % [string]
        replicateIntoCol        % [logical]
        colDescription          % [String]
        convertToCategorical    % [logical]
    end
    
    methods
        
        function obj = TableSettings(colName, replicateIntoCol, colDescription, ...
                convertToCategorical)
            % TableSettings Class constructor - checks if field present and
            %               populates if so.
            
            allowableProperties     = {'colName', 'replicateIntoCol', ...
                'colDescription', 'convertToCategorical'};
            
            for i = 1 : nargin
                
                % if the input variables are not empty, populate the field.
                if ~isempty( eval( allowableProperties{i} ) )
                    obj.( allowableProperties{i} )  = ...
                        eval( allowableProperties{i} );
                end
                
            end
            
        end
        
        %% Set and get function
        function obj = set.colName(obj, value)
            if ~ischar(value)
                error([mfilename ':setColHeaders'], ...
                    'The colHeader property must be a string')
            else
                obj.colName    = value;
            end
        end
        
        function obj = set.replicateIntoCol(obj, value)
            if ~islogical(value)
                error([mfilename ':replicateIntoCol'], ...
                    'The replicateIntoCol property must be logical')
            else
                obj.replicateIntoCol    = value;
            end
        end
        
        function obj = set.colDescription(obj, value)
            if ~ischar(value)
                error([mfilename ':colDescription'], ...
                    'The colDescription property must be a string')
            else
                obj.colDescription    = value;
            end
        end
        
        function obj = set.convertToCategorical(obj, value)
            if ~islogical(value)
                error([mfilename ':convertToCategorical'], ...
                    'The convertToCategorical property must be logical')
            else
                obj.convertToCategorical    = value;
            end
        end
        
        
    end
end
