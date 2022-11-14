function [constr] = genGlobalConstr(pivot,Nx,tabop)
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    constr = struct;
    % Gen <,>,= constr on global table tabop
    pVal = tabop(pivot.c,pivot.r);
    r = pivot.r;
    c = pivot.c;
    for i=1:Nx
        if i == r
            continue
        end
        for j=1:i
            opVal = tabop(i,j);

            aRow = zeros(2*Nx,1)';
            aeqRow = zeros(2*Nx,1)';

            aRow(r) = 1;
            aRow(c+Nx) = 1;

            aeqRow(r) = 1;
            aeqRow(c+Nx) = 1;


            aRow(i) = -1;
            aRow(j+Nx) = -1;

            aeqRow(i) = -1;
            aeqRow(j+Nx) = -1;

            if pVal < opVal 
                %fprintf("Applied constraint on: %f < %f (%d,%d) < (%d,%d)\n",pVal,opVal,r,c,i,j);
                A = [A; aRow];
                b = [b; -1];
            elseif pVal == opVal
                %fprintf("Applied constraint on: %f = %f (%d,%d) = (%d,%d)\n",pVal,opVal,r,c,i,j);
                %Aeq = [Aeq; aeqRow];
                %beq = [beq; 0];
            end
        end
    end
    constr.A = A;
    constr.Aeq = Aeq;
    constr.beq = beq;
    constr.b = b;

end