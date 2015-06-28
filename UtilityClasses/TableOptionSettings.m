classdef TableOptionSettings 
    % PlotOptionSettings -  Defines allowable options for the table options in
    %                       the Report class.
    %
    %   Class to enable better control over the various user inputs using get 
    %   / set methods.
    %
    % Properties:
    %   
    %   format          [char]
    %   tableFormat     [CellObj]       {'tex'}.
    %
    % Methods:
    %   TableOptionSettings      - Constructor 
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
        
        format@char                 = '%6.2f';       % For numbers in tables
        tableFormat                 = CellObj({'tex'}, 'type', 1, ...
            'restrictions', {'tex'});        
    end


    methods
        
        function obj = TableOptionSettings()
        end                
        
    end
    
    
    
end
