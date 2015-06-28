function saveo(b)
% saveo         Save object to disk.
%
% USAGE: m.saveo.
%
% Note: A savePath and modelName must have been set for the model object before
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

if isempty( b.savePath ) || isempty( b.modelName )
    error('Batch:saveo','You need to specify a savePath and modelName property before saving!')
    
else
    
    listing      = dir( b.savePath );
    listingNames = {listing.name};
    
    if any( strcmpi(b.modelName,listingNames) )
        error('Batch:saveo','modelName already in savePath folder. Delete this manually before saving the bath object')
    else
        
        save(fullfile(b.savePath,[b.modelName  '.mat']), 'b');
        
    end

end


end
