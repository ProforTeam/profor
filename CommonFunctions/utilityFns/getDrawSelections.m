function [selections, sortedValue, order, biasCorrValue]...
    = getDrawSelections(value, alphaSign, draws, varargin)
% getDrawSelections - 
% Based on input, make confidence intervals for content of value.
% Value can have different dimension. The function will match the dim in
% value that correspond to draws and use this. Different options can be set
% based on varargin.
%
% Input:
%
%   value = matrix. () can have different dimensions, but the number of 
%   draws must be in the last dim, and this must equal input draws (see 
%   below). 
%
%   alphaSign = integer between 0 and 1. Defines the alpha level of the
%   interval
%
%   draws = integer. Number of draws in value. E.g. is size(value)=[4 4 100]
%   and draws=100, the third dim of value correspond to the number of
%   draws.
%
%   varargin = optional input. String followed by argument
%    'method' = string. Default: 'quantile'. Options: 'biasCorr', which
%    will apply Hall's bias corrected percentiles. Note, if 
%    method='biasCorr', also value0 must be supplied (see below)
%
%    value0 = matrix. Same size as value, but without the last dim (i.e. no
%    draws). This will be used to center the distribution when
%    method='biasCorr'.
%       
% Output:
%
%   selections = If method='quantile': Vector (1 x 3) of selection index
%   from [round((alphaSign)*draws) round(0.5*draws) round((1-alphaSign)*draws)]
%
%   order = index from MATLAB sort function (applied to either value of bias
%   corrected values. Depending on mehtod). 
%
%   sortedValue = matrix with confidence intervals for content of value.
%   The last dim of sortedValue will equal 3. The median (or value0, 
%   see varargin) value will be in position 2. 
%
%   biasCorrValue = matrix(), same size as value. Bias corrected, i.e. 
%   value-repmat(options.value0,[draws 1]). Will be empty if method is
%   different than 'hallsquantile'.
%
% Usage:
%   [selections,sortedValue,order]=getDrawSelections(value,alphaSign,draws)
%   and
%   [selections,sortedValue,order]=getDrawSelections(value,alphaSign,...
%                          draws,'method','biasCorr','value0',value0)
% 
% Note: If draw=1 (or 2), the sortedValue output will be equal to value.
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

% default
defaults = {
    'method', 'hallsquantile',  @(x)any(strcmpi(x,{'norminv','quantile','hallsquantile','quantilewithmean'})),...
    'value0', [],               @isnumeric...
    };
options = validateInput(defaults, varargin(1:nargin-3));

if isa(options.method,'CellObj')
    options.method = char(options.method.x);
end

order           = [];
selections      = [];
sortedValue     = [];
biasCorrValue   = [];
if draws == 1
    sortedValue = value;
else    
    column      = find(draws == size(value));
    selections  = [ceil((alphaSign/2)*draws) round(0.5*draws) floor((1-alphaSign/2)*draws)]; 
    
    switch lower(options.method)        
        
        case {'norminv'}
            
            if ~isempty(options.value0) 
                ncrit       = norminv(1-alphaSign/2,0,1);            
                stdOfValues = std(value,[],column);                
                sortedValue = cat(column,sortedValue,options.value0-stdOfValues.*ncrit);                
                sortedValue = cat(column,sortedValue,options.value0);
                sortedValue = cat(column,sortedValue,options.value0+stdOfValues.*ncrit);                                
            else
                error([mfilename ':norminv'], 'You must supply a value0 to use the norminv method');                
            end;                        
            
            if column == 1
                biasCorrValue = value - repmat(mean(value, column) - options.value0,[draws 1]);
            else
                biasCorrValue = value - repmat(mean(value,column) - options.value0,[ones(1,column-1) draws]);
            end                             
            
        case {'quantile'}           
            
            [sortedValue, order] = sort(value, column); 
            if column == 1
                sortedValue = sortedValue';
            end            
            sortedValue     = eval(['sortedValue(:' repmat(',:',[1 column-2]) ',selections)']);            
            biasCorrValue   = value;
            
        case {'quantilewithmean'} 
            
            [sortedValue, order] = sort(value, column); 
            if column == 1
                sortedValue = sortedValue';
            end;            
            sortedValue = eval(['sortedValue(:' repmat(',:',[1 column-2]) ',selections)']);                        
            meanValue   = mean(value,column);
            eval(['sortedValue(:' repmat(',:',[1 column-2]) ',2)=meanValue;']);                                    
            biasCorrValue = value;                                    
            
        case {'hallsquantile'}
            
            if ~isempty(options.value0) 
                if column == 1
                    biasCorrValue0 = value - repmat(options.value0, [draws 1]);
                else 
                    biasCorrValue0 = value - repmat(options.value0, [ones(1,column-1) draws]);
                end                
                [biasCorrValue0, order] = sort(biasCorrValue0, column); 
                if column == 1
                    biasCorrValue0 = biasCorrValue0';
                end;            
                biasCorrValue0 = eval(['biasCorrValue0(:' repmat(',:',[1 column-2]) ',selections)']);            
                
                lowValue = options.value0 - eval(['biasCorrValue0(:' repmat(',:',[1 column-2]) ',3)']);

                midValue = options.value0 - eval(['biasCorrValue0(:' repmat(',:',[1 column-2]) ',2)']);
                %midValue=options.value0;
                
                higValue = options.value0 - eval(['biasCorrValue0(:' repmat(',:',[1 column-2]) ',1)']);
                sortedValue = cat(column, sortedValue, lowValue);
                %sortedValue=cat(column,sortedValue,options.value0);
                sortedValue = cat(column, sortedValue, midValue);
                sortedValue = cat(column, sortedValue, higValue);                                
                
                if column == 1
                    biasCorrValue = value - repmat(mean(value, column) - midValue, [draws 1]);
                else        
                    biasCorrValue = value - repmat(mean(value, column) - midValue, [ones(1, column-1) draws]);
                end                
                
            else
                error([mfilename ':hallsquantile'], 'You must supply a value0 to use the hallsquantile method');
            end                       
    end   
    
end

    
    

