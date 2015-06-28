function xDomain = getxDomain(predictions, xDomainLength)
% PURPOSE: Get xDomain if it is not supplied in the object
% already
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

[~, nvary, numQuant] = size(predictions);

if numQuant ~= 3
    error([mfilename ':getxDomain'],'Input predictions should have had size(.,3)=3')                
end;

%rangeDiff       = abs(predictions(:,:,3)) + abs(predictions(:,:,1))*10;
rangeDiff       = (abs(predictions(:,:,3)) + abs(predictions(:,:,1))) + (abs(predictions(:,:,2)) + abs(predictions(:,:,1)))./2;
startValues     = min(predictions(:,:,2) - rangeDiff,[],1);
endValues       = max(predictions(:,:,2) + rangeDiff,[],1);

xDomain = nan(xDomainLength, nvary);
for i = 1:nvary
    xDomain(:,i) = linspace(startValues(i), endValues(i), xDomainLength);                
end;
