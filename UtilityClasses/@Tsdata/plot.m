function plot(obj,mnemonics,path)
% plot  -    Plot Tsdata object
%
% Input (optional):
%
%   mnemonics       [cellstr] 
%                   names of series in Tsdata object to plot
%   path            [char]
%                   full path and name to use for saving. Figure saved if
%                   provided
%
% Usage:
%
%   1) d.plotData(mnemonics, path)
%   2) d.plotData(mnemonics)
%   3) d.plotData()
%
% Note: 
%   If you have an array of Tsdata objects, press space to move to next figure
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

if nargin == 2        
    figure('name', 'Multivariable plot')
    set(0, 'DefaultAxesColorOrder', [0 0 0;0 0 1;1 0 0],...
        'DefaultAxesLineStyleOrder','-|-*|--+|:')
    
    lname       = [];
    dj          =[];
    
    numMnem     = numel( mnemonics );
    for j = 1 : numMnem
        dj  = cat(2, dj, findobj(obj, 'mnemonic', mnemonics{j}));
    end
    
    datesl  = Tsdata.findLongestSample(dj);
    
    for j = 1 : size(dj, 2)
        dates   = dj(j).getDates;
        st      = find( dates(1)   == datesl );
        en      = find( dates(end) == datesl );
        
        if ~isempty(en) && ~isempty(st)
            y               = nan(size(datesl, 1), 1);
            y(st : en, 1)   = dj(j).getData;
            
            plot(y,'linewidth',4);
            [~,~]           = setXtickAndLabel(datesl, 'handle', gca);
            lname           = cat(1, lname, mnemonics(j));
            hold all
        else
            disp(['Variable: ' mnemonics{j} ' was not in the Tsdata object, or ',...
                'frequency mismatch. Remember that the function is case sensitive'])
        end
    end
    legend(lname);
    hold off
else
    
    if nargin == 3
        checkPath(path);
        strct.figureFormat.x        = {'pdf'};
        strct.transparentFigures    = true;
    end;
    
    figure('name', 'Tsdata variables')
    nObj    = numel(obj);
    for j=1:nObj
        
        plot(obj(j).getData,'b','linewidth',4);
        
        [~, ~]  = setXtickAndLabel(obj(j).getDates, 'handle', gca);
        str     = sprintf('Number: %d, Variable: %s\n%s', ...
            obj(j).number,...
            obj(j).mnemonic,...
            obj(j).desc);
        h       = title(str, 'interpreter', 'none');
        pause
        if nargin == 3
            delete(h);
            saveEconToolboxFigures([path '\Variable' obj(j).mnemonic],strct);
        end
    end
end
end
