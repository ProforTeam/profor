function X=splice(x,y)

nanIndex=isnan(x);
X=x;
X(nanIndex)=y(nanIndex);
