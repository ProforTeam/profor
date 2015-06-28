function original_warningState = warningControls(original_warningState)
% warningControls - 
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

doIHaveIt = proforStartup.doIHaveTheParallel();

if doIHaveIt
    % If no pool, do not create new one.
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        poolsize = 0;
    else
        poolsize = poolobj.NumWorkers;
    end
else
    poolsize = 0;
end

% Hard coded for now, need to do more here
if poolsize > 0 
    
    if nargin == 1    
        pctRunOnAll warning('original_warningState');    
        % And not built in warnings
        pctRunOnAll warning('on','mapDatesAndSample:input');        
    else        
        % Get the warning states...
        original_warningState = warning;
        %... and turn off warning
        pctRunOnAll warning('off','all');
        % And not built in warnings
        pctRunOnAll warning('off','mapDatesAndSample:input');    
        pctRunOnAll warning('off','kernelDensity:kernelDensity');
        
    end;
    
else
    
    if nargin == 1    
        warning('original_warningState');    
        % And not built in warnings
        warning('on','mapDatesAndSample:input');        
    else        
        % Get the warning states...
        original_warningState = warning;
        %... and turn off warning
        warning('off','all');
        % And not built in warnings
        warning('off','mapDatesAndSample:input');    
        warning('off','kernelDensity:kernelDensity');
    end;    
    
end




