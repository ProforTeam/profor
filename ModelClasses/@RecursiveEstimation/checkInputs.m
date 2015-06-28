function x = checkInputs(obj)
% checkInputs
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

x       = false;
% First check if all inputs that are settable are set
mobj    = metaclass(obj);
mobjp   = mobj.Properties;
nn      = numel(mobjp);
mobj    = [];
for i = 1:nn
    mobj = cat(2, mobj, findobj(mobjp{i}, 'SetAccess', 'public'));
end
nn = numel(mobj);
for i = 1:nn
    if isempty(obj.(mobj(i).Name)) &&  ~strcmpi(mobj(i).Name,'outputNames') &&  ~strcmpi(mobj(i).Name,'saveNames')
        warning([mfilename  ':checkinputs'],'Your input is not sufficient for the program to be able to run.\n Check input: %s', mobj(i).Name)
        return
    end
end

% Check that saveNames are either empty or correct size
if ~isempty(obj.saveNames)
    if numel(obj.saveNames) ~= obj.T
        warning([mfilename  ':checkinputs'],'Your saveNames do not have the correct size (should be equal to T)')
        return
    end
end

% Now check that dates are ok
sampleDates = sample2ttt(obj.batch.sample, obj.freq);
[cc, ia]    = intersect(sampleDates, obj.dates);
if isempty(cc)
    warning([mfilename  ':checkinputs'],'Your sample period in batch do not overlap with the sample in recursiveEstimation. It should')
    return
else
    idx = find(ia(1) == sampleDates);
    if idx < 10
        warning([mfilename ':checkinputs'],'Your sample in recursiveEstimation makes estimation sample in batch to be smaller than 10 obervations. Not valid')
        return
    end
end

% Check that outputNames are in model class that is
% estimated
if ~obj.saveRecursions
    if isempty(obj.outputNames)
        warning([mfilename ':checkinputs'],'outputNames is empty and you are not saving the recursions. Add outputNames or saveRecursions (or both)')
        return
    else
        mobj = eval(['?' obj.type.x{:} obj.batch.method]);
        mobj = mobj.Properties;
        nn   = numel(mobj);
        cnt  = 0;
        for i = 1:nn
            if any(strcmp(mobj{i}.Name, obj.outputNames))
                cnt = cnt+1;
            end
        end
        if cnt ~= numel(obj.outputNames)
            warning([mfilename ':checkinputs'],'You are asking for output that is not in your Model class. Check spelling (case sensitive), type and outputNames')
            return
        end
    end
end

% Lastly check that Model class is ready for running
m = Model(obj.batch.method, obj.batch, obj.data);
if ~m.state
    warning([mfilename ':checkinputs'],'Model class can not be run. Check settings in batch and data objects')
    return
end
% delete m object (this should in future release also remove
% tmp files for this object
clear m;

x = true;
end
