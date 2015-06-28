function addProps( obj )
% addProps
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

% Initialise the batch property in a recursive fashion. Eg. For Batchprofor,
% which inherits from Batchcombination < Batch. 
if isempty( obj.batch )
    obj.batch   = eval(['Batch' obj.method]);
end

% For different initialisations of the batch file initialisation using the
% appropriate batch file.
if isa(obj.batch, 'Batchprofor')
    fhandle             = str2func( 'Estimationprofor' );
    obj.estimation      = feval(fhandle);
    obj.forecast        = 'No forecast class for this model';
    return
    
elseif isa(obj.batch, 'Batchcombination')
    fhandle             = str2func( 'Estimationcombination' );
    fhandlef            = str2func( 'Forecasting' );
    
else    
    fhandle             = str2func( 'Estimation' );
    fhandlef            = str2func( 'Forecasting' );
end

obj.estimation          = feval(fhandle);
obj.forecast            = feval(fhandlef);

end
