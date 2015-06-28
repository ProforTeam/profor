classdef PlotOptionSettings < handle
    % PlotOptionSettings -  Defines allowable options for the plot options in
    %                       Report.
    %
    %   Set up as a class to enable better control over the various user inputs
    %   using get / set methods.
    %
    % Properties:
    %
    %   figureVisible       [logical]
    %   saveFigures         [logical]
    %   closeAfterSaving    [logical]
    %   plotLegend          [logical]
    %   plotTitle           [logical]
    %   axisTight           [logical]
    %   axisFontSize        [double]
    %   legendFontSize      [double]
    %   fontSize            [double]
    %   lineWidth           [double]
    %   widthOfBar          [double]
    %   titleFontSize       [double]
    %   transparentFigures  [logical]
    %   densityColor        [CellObj]   ('f', 'r', 'g', 'b', 'y', 'o', 's', 'n', 'k')
    %   quantiles           [CellObj]
    %   renderer            [CellObj]
    %   resolution          [CellObj]
    %   figureFormat        [CellObj]
    %
    % Methods:
    %   PlotOptionSettings      - Constructor
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
        
        figureVisible@logical       = true;
        saveFigures@logical         = false;
        closeAfterSaving@logical    = false;
        plotLegend@logical          = true;
        plotTitle@logical           = true;
        axisTight@logical           = true;
        axisFontSize@double         = 14;
        legendFontSize@double       = 10;
        fontSize@double             = 14;
        lineWidth@double            = 4;
        widthOfBar@double           = 0.8;           % witdth of bar in figures
        titleFontSize@double        = 14;
        transparentFigures@logical  = true;         % If figure background transparent
        
        densityColor                = CellObj({'f'}, 'type', 1, 'restrictions', ...
            {'f', 'r', 'g', 'b', 'y', 'o', 's', 'n', 'k'})
        
        quantiles                   = [0.05; 0.15; 0.25; 0.35; 0.65; 0.75; 0.85; ...
            0.95] .* 100;                           % Quantiles for density plots
        
        renderer                    = CellObj({'painters'}, 'type', 1, 'restrictions', ...
            {'painters', 'opengl', 'zbuffer'});
        
        resolution                  = CellObj({'r600'}, 'type', 1, 'restrictions', ...
            {'r300','r600','r1200'});
        
        figureFormat                = CellObj({'pdf'}, 'type', 1, 'restrictions', ...
            {'pdf', 'eps', 'tif', 'jpg', 'png'});
    end
    
    properties(Constant = true)

        markers         = ['o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>',...
            'p', 'h', '.', '+', '*', 'o', 'x', '^', '<', 'h', '.', '>', 'p', ...
            's', 'd', 'v', 'o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>', ...
            'p', 'h', '.'];
        
        linestyles      = cellstr(char('-', ':', '-.', '--', '-', ':', '-.', ...
            '--', '-', ':', '-', ':', '-.', '--', '-', ':', '-.', '--', '-', ...
            ':', '-.'));               
    end    
    
    % if setting up using matlab systems, need to make a subclass as
    % PlotOptionSettings < matlab.System
    %     properties
    %         Coordinates
    %     end
    %     properties(Hidden,Transient)
    %         CoordinatesSet = matlab.system.StringSet({'north','south','east','west'});
    %     end
    
    methods
        
        function obj = PlotOptionSettings()
        end
        
        % Set methods for the CellObj such that you don't overwrite settings.
        function set.densityColor(obj, value)
            obj.densityColor    = Batch.setCellObj(obj.densityColor, value);
        end
        
        function set.renderer(obj, value)
            obj.renderer    = Batch.setCellObj(obj.renderer, value);
        end
        
        function set.resolution(obj, value)
            obj.resolution    = Batch.setCellObj(obj.resolution, value);
        end
        
        function set.figureFormat(obj, value)
            obj.figureFormat    = Batch.setCellObj(obj.figureFormat, value);
        end                
        
    end
    
    
    
end
