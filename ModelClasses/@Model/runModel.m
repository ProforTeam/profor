function runModel(obj)
% runModel      Runs the model with the supplied settings
%
% Inputs:
%   obj         [Model]
%
% If the specific method you have supplied support forecasting, identification
% etc., depending on your batch setting, will also be done.
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

modelName = upper(obj.links.tag);

if obj.showProgress
    fprintf('Starting model %s computation\n', modelName);
end

% Do estimation
runEstimation( obj );
% Do forecasting
runForecast( obj );


if obj.showProgress
    fprintf('Done with %s computation\n', modelName);
end

end
