function out = existFieldNameInStructOrStructOfCells( inArg, requestedFieldName )
% existFieldNameInStructOrStructOfCells  -   
%   Takes structure or cell of structures amd returns logical array of same 
%   dimensions if field exists.
% N.B. Only set up to work on one level of nesting as currently setup for
% storing results in resultCell.
%
% Input:
%   inArg               [struct] or [cell][struct] (nRows x nCols)
%   requestedFieldName  [str]
%
% Output:
%   out             [logical] (nRows x nCols)
%
% usuage: 
% out = existFieldNameInStructOrStructOfCells( inArg, requestedFieldName )
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

errType     = [mfilename, ': '];

%% Validation
assert( isstruct( inArg ) || iscell( inArg ), errType, ...
    'Fn only defined on data type structure')

%% Extract data from input argument.
[nRows, nCols]  = size( inArg );
inClass         = class( inArg );

%% Extract field name from cell / structure

FieldNames(nRows, nCols).fieldNames = '';
out                                 = false( nRows, nCols );

for ii = 1 : nRows
    for jj = 1 : nCols
        
        % Allow for different type of input arguments, cell or struct. 
        switch inClass
            case 'cell'
                FieldNames( ii, jj ).fieldNames     = fieldnames( inArg{ ii, jj } );
                
            case 'struct'
                FieldNames( ii, jj ).fieldNames     = fieldnames( inArg( ii, jj ) );
                
            otherwise
                error(errType, 'Class of input argument %s not supported', inClass)
        end
        
        
        % Check if field name is present.
        nInstanceOFField = sum( strcmpi( requestedFieldName, ...
            [FieldNames( ii, jj ).fieldNames ] ) );
        
        if nInstanceOFField == 1
            out( ii, jj )    = true;
            
        elseif nInstanceOFField > 1
            warning( errType, 'Multiple instance of field %s', requestedFieldName)
            
        else
            out( ii, jj )    = false;
        end
        
    end
end




end