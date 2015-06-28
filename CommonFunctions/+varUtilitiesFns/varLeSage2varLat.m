function [alfa,beta,emat]=varLeSage2varLat(result,nlag,estX)
% varLeSage2varLat - 
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

neqs=max(size(result));

if strcmpi('bvar_g',result(1).meth)
    beta=[];alfa=[];emat=[];
    for i=1:neqs
        betai=[];
        for ii=1:nlag
            betai=cat(2,betai,mean(result(i).bdraw(:,ii:nlag:end-1),1));
        end
        alfai=mean(result(i).bdraw(:,end));                
        yhat=([alfai betai]*estX')';                    
        
        emat=cat(2,emat,result(i).y(nlag+1:end,1)-yhat);
        alfa=cat(1,alfa,alfai);
        beta=cat(1,beta,betai);
    end;    
else
    beta=[];alfa=[];emat=[];
    for i=1:neqs
        betai=[];
        for ii=1:nlag
            betai=cat(2,betai,result(i).beta(ii:nlag:end-1)');
        end
        alfa=cat(1,alfa,result(i).beta(end));
        beta=cat(1,beta,betai);
        emat=cat(2,emat,result(i).resid);
    end;
end;

