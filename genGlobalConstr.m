function [constr] = genGlobalConstr(pivot,Nx,tabop)
    A = zeros(Nx*(Nx+1)/2,2*Nx);
    b = zeros(Nx*(Nx+1)/2,1);
    Aeq = [];
    beq = [];
    % Gen <,>,= constr on global table tabop
    pVal = tabop(pivot.c,pivot.r);
    r = pivot.r;
    c = pivot.c;
    counter = 1;
    for i=1:Nx
        if i == r
            continue
        end
        for j=1:i
            opVal = tabop(i,j);

            %aRow = zeros(2*Nx,1)';
            %aeqRow = zeros(2*Nx,1)';

            %aRow(r) = 1;
            %aRow(c+Nx) = 1;

            %aeqRow(r) = 1;
            %aeqRow(c+Nx) = 1;


            %aRow(i) = -1;
            %aRow(j+Nx) = -1;

            %aeqRow(i) = -1;
            %aeqRow(j+Nx) = -1;

            if pVal < opVal 
                %fprintf("Applied constraint on: %f < %f (%d,%d) < (%d,%d)\n",pVal,opVal,r,c,i,j);
                %A(counter,:) = aRow;

                A(counter,r) = 1;
                A(counter,c+Nx) = 1;
                A(counter,i) = -1;
                A(counter,j+Nx) = -1;


                b(counter) = -1;
                counter = counter+1;
            elseif pVal == opVal
                %fprintf("Applied constraint on: %f = %f (%d,%d) = (%d,%d)\n",pVal,opVal,r,c,i,j);
                %Aeq = [Aeq; aeqRow];
                %beq = [beq; 0];
            end
        end
    end
    maxRow=counter;
    constr.A = A(1:maxRow,:);
    constr.Aeq = Aeq;
    constr.beq = beq;
    constr.b = b(1:maxRow,:);
end