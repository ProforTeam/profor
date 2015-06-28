function disp( obj )
% disp      Display summary information on the data series in Data object.
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

nObj    = numel(obj);
fid     = 1;
for j = 1 : nObj
    if obj(j).state
        % Print to screen information on the series, frequency and sample range.
        fprintf(fid, 'Series:         %s\n',    obj(j).mnemonic );
        fprintf(fid, 'Frequency:      %s\n',    obj(j).freq     );
        fprintf(fid, 'Sample:         %s\n',    obj(j).getSample   );
        
        % Print to screen all data contained with the series summarised above.
        fprintf(fid, 'Dates           Value\n'                  );        
        dataLength  = size(obj(j).getData, 1);
        for i = 1 : dataLength
            
            if any( strcmpi(obj(j).freq, {'q', 'm'}) )
                fprintf(fid,'%6.2f         %6.3f\n', obj(j).getDates(i), obj(j).getData(i));
                
            elseif strcmpi(obj(j).freq,{'a'})
                fprintf(fid,'%6.0f         %6.3f\n', obj(j).getDates(i), obj(j).getData(i));
                
            else
                fprintf(fid,'%6.3f         %6.3f\n', obj(j).getDates(i), obj(j).getData(i));
            end
            
        end
        fprintf(fid, '\n');
        fprintf(fid, 'Description: %s\n', obj(j).desc);
    else
        fprintf(fid, 'Time series object does not contain any data\n');
    end
end

end