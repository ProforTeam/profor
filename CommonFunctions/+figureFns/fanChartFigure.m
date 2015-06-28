function fanchart = fanChartFigure(simulationSmpl, dates, obj, varargin)
% fanChartFigure - Fanchart figure based on density estimates
%
% Usage: handle = fanChartFigure(comboPdf, quantiles, dates)
%
% Inputs:
%
%	simulationSmpl = matrix: d x h, where d is the
%   number of drawspoints the density is evaluated at and h is the maximum
%   horizon. 
%
%   dates = (hor x 1), cs format forecast date vector
%
%   varargin = string followed by argument. Optional
%       quantiles = vector: numQuants by 1; the set of quantiles between 0
%       and 1 at which you want to evaluate your fanchart
%       Default=[0.05; 0.15; 0.25; 0.35; 0.65; 0.75; 0.85; 0.95].*100

%		forecasts =	(nfor x 1) vector of point forecast which what you want
%       plotted with the densities
%
%       historyAndDates = (t x 2) vector of historical dates and values.
%       First column should be dates (cs format), second column values.
%
%		xLim = limits that control the display for the x-axis, e.g. [0 10]
%
%       lineWidth = width of forecast line if provided
%
%       fontsize = fontsixe for ticks etc.
%
%       intensityScale = (1 x 2) vector with values between 0 and 1
%       representing the intensity range for the colors, which correspond
%       to black and white, respectively. Default is [0.5 0.7].
%
%       color = a string of characters that includes any combination of the
%       following letters:
%               'r' = red           'g' = green         'b' = blue
%               'y' = yellow        'c' = cyan          'm' = magenta
%               'o' = orange        'l' = lime green    'a' = aquamarine
%               's' = sky blue      'v' = violet        'p' = pink
%               'n' = navy blue     'f' = forest green
%               'k' or 'w' = black/white/grayscale
%
%       figure = true or false. If true, the program puts the area plot
%       into its own figure. If false, the area plot will be put into the
%       current axes (usefull if you already have e.g. a subplot and then
%       populate this by running this function). Default=true
%
%       figureName = string. Name of figure
%
%       savePath = string. Default=''. If supplied it should be the whole
%       filepath and filename of figure (but not extension)
%
% OUTPUTS:
%
%   fanchart = handle(s) of area plot.
%
% NOTE: This function uses the vivid function by Joseph Kirk. See doc vivid
% for details.
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

%% Preliminaries
errType             = 'fanChartFigure:quantilesMin';

% Preliminary constants
deafultQuantiles    = [0.05; 0.15; 0.25; 0.35; 0.65; 0.75; 0.85; 0.95] .* 100;
% Defaults
defaults            ={...
    'forecast',         [],                 @isnumeric,...
    'historyAndDates',  [],                 @isnumeric,...
    'xLim',             [],                 @isnumeric,...
    'quantiles',        deafultQuantiles,   @isnumeric,...
    'intensityScale',   [0.5 0.7],          @isnumeric,...
    'color',            'f',                @ischar,...
    'figure',           true,               @islogical,...
    'figureName',       'Density plot',     @ischar,...
    'savePath',         '',                 @ischar,...
    'titleFontSize',    '',                 @isnumeric,...
    'ynames',            '',                @ischar, ...
    'titleNames',       '',                 @iscell ...
    };
options             = validateInput(defaults, varargin(1:nargin-3));

% make quantiles a column vector
if size(options.quantiles, 2) > size(options.quantiles,1)
    options.quantiles   = options.quantiles';
end

if min( options.quantiles ) < 0
    error( errType, 'Negative values for quantiles are inadmissible.');
end

%% Compute the quantiles

% If X is a matrix, then Y is a row vector or a matrix where 
% the number of rows of Y is equal to the length of p.
quantLocations = quantile(simulationSmpl, options.quantiles./100, 1);

% Compute the contributions
quantLocationsDiffs = (quantLocations(2:end,:) - quantLocations(1:end-1,:)); % (h x q)
quantLocationsDiffs = [quantLocations(1,:);
                        quantLocationsDiffs]';
qc = size(quantLocationsDiffs,2);
% if history is supplied, add this to the plot
if ~isempty(options.historyAndDates)
    datesh  = options.historyAndDates(:,1);
    xh      = options.historyAndDates(:,2);
    T       = size(xh,1);
    
    %adjust quantLocationsDiffs
    quantLocationsDiffs = [[xh zeros(T,qc-1)];
                            quantLocationsDiffs];
    
else
    xh      = [];
    datesh  = [];
    T       = [];
end
quantLocationsDiffs( isnan(quantLocationsDiffs) ) = 0;

%% Draw graph
if options.figure
    figure('Name', options.figureName)
else
    figure();    
end
fanchart    = area(quantLocationsDiffs);

numAreas    = length(fanchart);
st          = ceil((numAreas-1)/2);

% Set the colour map for the fan chart using vivid which creates a personalised
% colour map. 
cmap        = vivid(st, options.color, options.intensityScale);
cmap        = [flipud(cmap(1 : st, :)); cmap(2 : st, :)];

set(fanchart(1),'FaceColor','none','linestyle','none','EdgeColor','none');
for i=2:numAreas
    set(fanchart(i),...
        'FaceColor',cmap(i-1,:),...
        'linestyle',...
        'none',...
        'EdgeColor',...
        'none')        
    % Uncomment next line to check colours being used
    % rgbColor3(i+1,:)
end

if ~isempty(options.historyAndDates)
    hold on
    plot(xh, 'k',...
        'lineWidth',obj.plotOptions.lineWidth);
end

% Add point forecast to the plot if supplied
if ~isempty(options.forecast)
    hold on
    if ~isempty(options.historyAndDates)
        forecast = [nan(T-1,1);
                    xh(end);
                    options.forecast(:)];
    else
        forecast = [nan(T,1);
                    options.forecast(:)];
    end
    plot(forecast,'k--',...
        'lineWidth',obj.plotOptions.lineWidth)
end

% Final stuff for figure
% adjust dates
dates = [datesh;
        dates];
% Correct ticks and date formats etc.
[~,~] = setXtickAndLabel(dates, 'handle', gca);
if ~isempty(options.xLim)
    set(gca, 'xlim', options.xLim);
end

% Plot title
if ~isempty(options.titleNames) && ~isempty( options.titleNames{1} )
    % Extract the title using the model names and variable name.
    titleName = [options.ynames, ' : ', ...
        strjoin([options.titleNames], ', ')];    
    title(titleName, 'interpreter', 'none', 'fontsize', obj.plotOptions.titleFontSize);
end

set(gca, 'fontSize', obj.plotOptions.fontSize);
set(gca, 'box', 'off');

% Save the figure.
if obj.plotOptions.saveFigures == true
    if ~isempty(options.savePath)
        saveEconToolboxFigures(options.savePath, obj);
        close
    end
end

end

