function [y,yInfo,ydates] = getVariableMatrix(obj, data, variableIdx)
% getVariableMatrix   -  Extract information from Tsdata object and return
% output in matrix format
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the monthly sample
monthlyYRawIn       = [];
selectionMonthly    = {''};
monthlyTransf       = [];
monthlySelectionIdx = [];

datam               = findobj(data,'freq','m');
if ~isempty(datam)
    [~, monthlySelectionIdx] = intersect(obj.(variableIdx).x, {datam.mnemonic});
    if sum(monthlySelectionIdx) ~= 0
        sampleIn = adjSample(obj.sample, 'm', 'nlag', obj.nlag, 'nfor', obj.nfor);
        % Everything is extracted in order of selecton.x...
        [monthlyYRawIn, monthlyDatesIn, selectionMonthly, monthlyTransf] = selectData(datam, obj.(variableIdx).x(monthlySelectionIdx), 'm', sampleIn);
        
        quarterlySampleIn = convertDatesFreq(monthlyDatesIn, 'm', 'q');
        % Map monthly dates to quarterly idx
        monthlyValues = uint8(rem(monthlyDatesIn,1)*100);
        fun = @(x)(monthlyValues == x);
        lastMonthOfQuarterIdx = any(cell2mat(arrayfun(fun, [3 6 9 12], 'UniformOutput', false)), 2);
    end
end
% Get the quarterly sample
quarterlyYRawIn     = [];
selectionQuarterly  = {''};
quarterlyTransf     = [];

dataq               = findobj(data, 'freq', 'q');
if ~isempty(dataq)
    [~, quarterlySelectionIdx] = intersect(obj.(variableIdx).x, {dataq.mnemonic});
    
    if sum(quarterlySelectionIdx) ~= 0
        % Everything is extracted in order of selecton.x...
        if sum(monthlySelectionIdx) ~= 0
            [quarterlyYRawIn, ~, selectionQuarterly, quarterlyTransf] = selectData(dataq, obj.(variableIdx).x(quarterlySelectionIdx), 'q', getSample(quarterlySampleIn));
        
        else
            sampleIn = adjSample(obj.sample, 'q', 'nlag', obj.nlag, 'nfor', obj.nfor);
            [quarterlyYRawIn, quarterlyDatesIn, selectionQuarterly, quarterlyTransf] ...
                = selectData(dataq, obj.(variableIdx).x(quarterlySelectionIdx), 'q', sampleIn);
            
            % Need these below
            monthlyDatesIn = quarterlyDatesIn;
            lastMonthOfQuarterIdx = true(size(quarterlyYRawIn,1), 1);
        end
    end
end

% Put it all together
% Get idx for whole data object
monthlySelectionIdx     = ismember({data.mnemonic}, selectionMonthly);
quarterlySelectionIdx   = ismember({data.mnemonic}, selectionQuarterly);
allSelectionIdx         = logical(sum([monthlySelectionIdx; quarterlySelectionIdx], 1));

if sum(allSelectionIdx) ~= 0
    T       = size(monthlyDatesIn,1);
    n       = numel(data);
    yy      = nan(T,n);
    transf  = cell(1,n);
    freq    = cell(1,n);
    if sum(quarterlySelectionIdx) ~= 0
        yy(lastMonthOfQuarterIdx, quarterlySelectionIdx) = quarterlyYRawIn(1:sum(lastMonthOfQuarterIdx),:);
        transf(quarterlySelectionIdx)                    = quarterlyTransf;
        freq(quarterlySelectionIdx)                      = repmat({'q'}, [1 sum(quarterlySelectionIdx)]);
    end
    if sum(monthlySelectionIdx) ~= 0
        yy(:,monthlySelectionIdx)       = monthlyYRawIn;
        transf(monthlySelectionIdx)     = monthlyTransf;
        freq(monthlySelectionIdx)       = repmat({'m'}, [1 sum(monthlySelectionIdx)]);
    end
    % remove variables (nans) not used
    yy      = yy(:,allSelectionIdx);
    transf  = transf(allSelectionIdx);
    freq    = freq(allSelectionIdx);
    
    if sum(monthlySelectionIdx) ~= 0
        % Truncate y so that it matches sample
        [~, en] = mapDatesAndSample(obj.sample, monthlyDatesIn, 'm');
        y       = yy(1:en,:);
        ydates  = monthlyDatesIn(1:en);
    else
        y       = yy;
        ydates  = monthlyDatesIn;
    end
    
    [minPanel, maxPanel] = minmaxPanel(y);
    
    yInfo.minPanel  = minPanel;
    yInfo.maxPanel  = maxPanel;
    yInfo.transf    = transf;
    yInfo.freq      = freq;
    
else
    y       = [];
    yInfo   = [];
    ydates  = [];
end

