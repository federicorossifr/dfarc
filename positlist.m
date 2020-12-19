function r = positlist(n,k)

if k ~= 0
    r=[];
            return;
else
switch(n)
    case 4
        r = posit4list();
    case 6
        r = posit6list();
    case 8
        r = posit8list();
    otherwise
            r = [];
            return;
end

r = [-r; 0; r];
end
