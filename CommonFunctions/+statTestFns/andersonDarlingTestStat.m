function [p, n] = andersonDarlingTestStat( PIT )
% andersonDarlingTestStat - test for assessing normality of a sample data. See  
% Trujillo-Ortiz, A., R. Hernandez-Walls, K. Barba-Rojo and A. Castro-Perez. 
% (2007).
%   
% Input:
%   PIT       [vector](t x 1)   where t is number of vintages (can contain NaNs)
%
% Output:
%   p         [scalar]          p-value
%   n         [scalar]          number of observations used for computing n 
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

idx = isnan( PIT );
pit = PIT( idx == 0 );

n   = length( pit );
x   = sort( pit );

fx  = normcdf(x, mean(x), std(x));
i   = 1:n;
        
S       = sum( (((2 * i) - 1) / n) * (log(fx) + log(1 - fx(n + 1 - i))) );
AD2     = - n - S;

AD2a    = AD2*(1 + 0.75/n + 2.25/n^2); %correction factor for small sample sizes: case normal
        
if (AD2a >= 0.00 && AD2a < 0.200);
    p   = 1 - exp(-13.436 + 101.14*AD2a - 223.73*AD2a^2);

elseif (AD2a >= 0.200 && AD2a < 0.340);
    p   = 1 - exp(-8.318 + 42.796 * AD2a - 59.938 * AD2a^2);

elseif (AD2a >= 0.340 && AD2a < 0.600);
    p   = exp(0.9177 - 4.279 * AD2a - 1.38 * AD2a^2);

else (AD2a >= 0.600 && AD2a <= 13);
    p   = exp(1.2937 - 5.709 * AD2a + 0.0186 * AD2a^2);
end
        

