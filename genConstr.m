function [constr] = genConstr(pivot,Nx)
    c = pivot.c;
    r = pivot.r;
    constr = [];
    while c > 1 && r < Nx
        constrRow = zeros(2*Nx,1)';
        constrRow(r) = 1;
        constrRow(c+Nx) = 1;

        r = r + 1;
        c = c - 1;

        constrRow(r) = -1;
        constrRow(c+Nx) = -1;

        constr = [constr; constrRow];
    end


end