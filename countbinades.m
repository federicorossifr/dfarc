
function [r,c] = countbinades(x)

x = x(x > 0);
x2 = floor(log2(x));
c=min(x2):max(x2);
if length(c) == 1 
    r = length(x);
else
    r = histc(x2,c);%'BinMethod','integers');
end