function saveo(obj)
% saveo         Save object to disk.
%
% USAGE: m.saveo.
%
% Note: A savePath must have been set for the model object before
% using saveo.
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

if isempty( obj.savePath )
    error('Model:saveobj','You need to specify a savePath property before saving!')
    
else
    [status, me]    = copyfile(obj.links.filePath, obj.savePath, 'f');
    
    if status ~= 1
        error('Model:saveobj', me)
    end
end

% Change obj.batch.links.filePath now, after creating the
% folder above. The sequence is important.
obj.links.filePath      = obj.savePath;

%             if isa(obj.forecast,'Forecast')
%                 obj.forecast.saveo;
%             end

save(fullfile(obj.savePath,'m.mat'), 'obj');

end
