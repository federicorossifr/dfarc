function [constr] = genConstr(pivot,Nx,tabop)
    c = pivot.c;
    r = pivot.r;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    constr = struct;

    % Walk back from the pivot 
    % in anti-diagonal direction
    % we build both equalities and inequalities
    % at the same time
    % if elements are equal in the tabop, 
    % also the Lzs must be equal
    % If they are not equal, we impose that the Lz
    % with higher row index must be higher (we can do otherwise?)
    while c > 1 && r < Nx
            aRow = zeros(2*Nx,1)';
            aeqRow = zeros(2*Nx,1)';

            aRow(r) = 1;
            aRow(c+Nx) = 1;

            aeqRow(r) = 1;
            aeqRow(c+Nx) = 1;

            r1 = r + 1;
            c1 = c - 1;

            aRow(r1) = -1;
            aRow(c1+Nx) = -1;

            aeqRow(r1) = -1;
            aeqRow(c1+Nx) = -1;

            rc = double(tabop(r,c));
            r1c1 = double(tabop(r1,c1));

        if rc < r1c1 % sum case
            fprintf("Applied constraint on: %f < %f (%d,%d) < (%d,%d)\n",tabop(r,c),tabop(r1,c1),r,c,r1,c1);
            A = [A; aRow];
            b = [b; -1];
        elseif rc > r1c1 % mul case
            fprintf("Applied constraint on: %f > %f (%d,%d) > (%d,%d)\n",tabop(r,c),tabop(r1,c1),r,c,r1,c1);
            A = [A; -aRow];
            b = [b; -1];
        else
            fprintf("Applied constraint on: %f = %f (%d,%d) = (%d,%d)\n",tabop(r,c),tabop(r1,c1),r,c,r1,c1);
            Aeq = [Aeq; aeqRow];
            beq = [beq; 0];
        end
        r=r1;
        c=c1;
    end
    constr.A = A;
    constr.Aeq = Aeq;
    constr.beq = beq;
    constr.b = b;
end