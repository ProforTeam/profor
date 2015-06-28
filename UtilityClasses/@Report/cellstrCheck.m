function c = cellstrCheck(x,y)

if isa(x,'char')
    c = any(strcmpi(x,y));
else
    c = numel(intersect(x,y)) == numel(x);
end