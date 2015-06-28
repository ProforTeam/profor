function options = validateInput(default, varargin)
% validateInput - Validate input. General function. Can be used by all functions
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

if ~iscell(default)
    error([mfilename ':input'], 'default input needs to be passed as a cell');
end

% extract defualt input
defaultNames    = default(1:3:end);
defaultValues   = default(2:3:end);
validate        = default(3:3:end);

default         = cell2struct(defaultValues,defaultNames,2);
options         = default;

% overwrite input with varargin values if present
if nargin > 1
    optInput    = varargin{1};
    
    % NOTE: varargin can be a structure. Sometimes, if varargin is passed from
    % one function to a other function it can end up as a structure inside a
    % cell. The try catch block bellow fix this. If the structure is inside a
    % cell inside a cell, the function can not help you!
    
    if isstruct(optInput)
        optInNames=fieldnames(optInput);
        optInValues=struct2cell(optInput);
        
    else
        optInNames=optInput(1:2:end);
        optInValues=optInput(2:2:end);
    end
    
    if ~iscellstr(optInNames)
        try
            optInNames=fieldnames(optInput{:});
            optInValues=struct2cell(optInput{:});
            
        catch ME
            disp('validateInput:err','varargin needs to be a cell array with every second argument as a string')
            rethrow(ME)
        end
    end
    
    [~, ia, ib]     = intersect(defaultNames, optInNames);
    
    % to be used for validation
    notValid=false(1,length(ia));validateErrorMsg='Following error(s) found in input: ';
    
    for mn = 1 : length( ia )
        %validate input
        x       = validate{ia(mn)};
        zz      = optInValues{ib(mn)};
        
        if isa(zz, 'CellObj')
            zz      = zz.x;
        end
        
        notValid(mn)    =~ x(zz);
        
        if ~notValid(mn)
            options.(defaultNames{ia(mn)})  = optInValues{ ib(mn) };
        
        else
            validateErrorMsg = sprintf('%s\n%s', validateErrorMsg, ...
                ['Input: ' defaultNames{ia(mn)} ', should have passed: ' ...
                func2str(x)]);
        end
    end
    
    % print error message
    if any(notValid)
        error([mfilename ':unknownError'], validateErrorMsg);
    end
end
