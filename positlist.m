function r = positlist(n,k)

if k > 2
    r=[];
            return;
else
switch(n)
    case 2
        assert(k==0);
        r=[0.5 1 2]';
    case 4
        assert(k==0);
        r = posit4list();
    case 6
        assert(k==0);
        r = posit6list();
    case 8
        if k == 1
            r = posit8_1list();
        elseif k == 2
            r = posit8_2list();
        else
            r = posit8list();
        end
    otherwise
            r = [];
            return;
end

end
