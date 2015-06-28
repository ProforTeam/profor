function controlOutput(obj, weightsAndScores)
% controlOutput     Check that output is ok. Report any possible errors without
%                   causing error
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

if obj.densityScoreSettings.optimize && ~obj.onlyEvaluation
    a=cell2mat(cellfun(@(x)(x.exitflag),weightsAndScores.optResult(:,:),'uniformoutput',false));
    if any(any(a~=2 & a~=1))
        warning([mfilename ':controlOutput'],['You have used optimal weights, but for some of the recursions the exitflag from the\n',...
            'optimizer is different than 2. This might indicate that something did not converge appropriately!\',...
            'nCheck weightsAndScores.optResult']);
        disp(a);
    end
end

end
