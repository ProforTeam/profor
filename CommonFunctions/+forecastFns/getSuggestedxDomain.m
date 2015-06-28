function [minlim, maxlim]=getSuggestedxDomain(modelPath, modelName, period, variableNames)            
% getSuggestedxDomain - 
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

mti=Model.loado([modelPath '\' modelName '\results\' period '\m']);

N=numel(variableNames);
mappedForecastIndex=nan(1,N);

if strcmpi(mti.method,'bdfm')                                
    % Call this to construct xDomain
    mti.forecast.predictionsYDTransf;    
    
    xDomain=mti.forecast.xDomainYTransf;
    for i=1:N
        if any(strcmpi(variableNames{i},mti.forecast.selectionY));
            %[~,~,ib]=intersect(lower(variableNames{i}),lower(model.forecast.selection.x));
            mappedForecastIndex(i)=i;
        end;
    end;    
elseif strcmpi(mti.method,'favar')
    % Call this to construct xDomain
    mti.forecast.predictionsDXTransf;
    
    xDomain=mti.forecast.xDomainXTransf;
    for i=1:N
        if any(strcmpi(variableNames{i},mti.forecast.selectionFavar.x));            
            mappedForecastIndex(i)=i;
        end;
    end;    
else
    mti.forecast.predictionsDTransf;
        
    xDomain=mti.forecast.xDomainTransf;
    for i=1:N
        if any(strcmpi(variableNames{i},mti.forecast.selection.x));            
            mappedForecastIndex(i)=i;
        end;
    end;        
end;

xDomain=xDomain(:,mappedForecastIndex);
minlim=min(xDomain);
maxlim=max(xDomain);


