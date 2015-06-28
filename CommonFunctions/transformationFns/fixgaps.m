function y = fixgaps(x)
% fixgaps - Linearly interpolates gaps in a time series 

y = x; 

if all(isnan(x))    
    return
end

bd = isnan(x); 
gd = find(~bd); 

bd([1:(min(gd) - 1) (max(gd) + 1):end]) = 0; 

y(bd) = interp1(gd, x(gd), find(bd)); 