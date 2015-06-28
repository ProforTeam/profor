function [Vprior, Tprior, vprior, Qprior] = getMinnesotaPrior(y, nlag, constant, minnesotaSettings)
% getMinnesotaPrior - 
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

[T, nvary]  = size(y);          
   
abar1 = minnesotaSettings.abar1;
abar2 = minnesotaSettings.abar2;
abar3 = minnesotaSettings.abar3;
type  = minnesotaSettings.type.x{:};

%% Output

% vprior
vprior              = round((minnesotaSettings.vprior/100)*T);

% Qprior
[yy, xx]            = varUtilitiesFns.varOrderData(y, nvary, nlag,...
                                                        'constant', constant);    
[~, ~, ~, Qprior]   = varUtilitiesFns.varEst(yy, xx, constant);   

% Tprior
Tprior              = getTprior(y, constant, nlag, type); 

% Vprior
Vprior              = getVprior(y, constant, nlag, abar1, abar2, abar3);                                    

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Vprior = getVprior(y,constant,nlag,abar1,abar2,abar3)                                     

% Preliminaries
numVar = size(y,2);          
% Get total number of variables/coeffs 
if constant
    K = 1 + (nlag*numVar);
else
    K = (nlag*numVar);
end
% Empty matrix for prior mean on VAR regression coefficients            
sigma_sq = zeros(numVar, 1);
for i = 1 : numVar
    % Create lags of dependent variable in i-th equation to get sigmas
    [estY,estX]             = varUtilitiesFns.varOrderData(y(:,i),...
                                                1, nlag, 'constant', constant);    
    [~,~,~, sigma_sq(i,1)]   = varUtilitiesFns.varEst(estY, estX, constant);
end;

% Create an array of dimensions K x M, which will contain the K diagonal
% elements of the covariance matrix, in each of the M equations.
V_i = zeros(K, numVar);
% index in each equation which are the own lags
ind = zeros(numVar, nlag);
for i = 1 : numVar
    if constant
        ind(i, :) = 1 + i : numVar : nlag*numVar + 1;
    else
        ind(i, :) = i : numVar : nlag*numVar;
    end
end
for i = 1 : numVar  % for each i-th equation
    for j = 1 : K   % for each j-th RHS variable
        if constant % if there is constant in the model use this code:
            if j == 1
                V_i(j, i) = abar3*sigma_sq(i, 1); % variance on constant                
            elseif find( j == ind(i, :) ) > 0
                V_i(j, i) = abar1./(nlag^2); % variance on own lags           
            else
                for kj = 1 : numVar
                    if find( j == ind(kj, :) ) > 0
                        ll = kj;                   
                    end
                end                 % variance on other lags   
                V_i(j, i) = ( abar2*sigma_sq(i, 1))./((nlag^2)*sigma_sq(ll, 1) );      
            end
        else  % if there is no constant in the model use this:
            if find( j == ind(i, :) ) > 0
                V_i(j, i) = abar1./(nlag^2); % variance on own lags
            else
                for kj = 1 : numVar
                    if find( j == ind(kj, :) ) > 0
                        ll = kj;
                    end                        
                end                 % variance on other lags  
                V_i(j, i) = (abar2*sigma_sq(i, 1))./((nlag^2)*sigma_sq(ll, 1));            
            end
        end
    end
end
% Now V is a diagonal matrix with diagonal elements the V_i
Vprior = diag( V_i(:) );
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aprior = getTprior(y, constant, nlag, type)                                                

% Preliminaries
numVar = size(y, 2);          
% Get total number of variables/coeffs 
if constant
    K = 1 + (nlag*numVar);
else
    K = (nlag*numVar);
end;
% Empty matrix for prior mean on VAR regression coefficients
A_prior = zeros(K, numVar);
for i = 1 : numVar
    switch lower(type)
        case {'ar'}               
            [estY, estX]    = varUtilitiesFns.varOrderData(y(:,i), 1, 1,...
                                                          'constant', constant);    
            [~, beta]       = varUtilitiesFns.varEst(estY, estX, constant);
        case {'fix'}
            beta = 0.9;                        
        case {'rw'}
            beta = 1;
        otherwise
            error('getaprior:err','The provided type is not in use')               
    end
    if constant
        A_prior(1+i, i) = beta(1);
    else
        A_prior(i, i)   = beta(1);        
    end;
end
% stack the prior into a vector
aprior = A_prior(:);                           

end              