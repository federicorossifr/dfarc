function [prob] = genMonoIncProblem(nbits,tabop)

  
    % Table of operation
    %tabop = bsxfun(fun,plist,plist');

    % Number of problem variables
    % Nx = 2^{nbits - 1} - 1
    % Ny = Nx
    % tot = 2*Nx
    Nx = (2^(nbits - 1) - 1);
    N = 2*Nx;
    prob = struct;
    prob.intcon = 1:N;

    % Lower bound is 0 for every variable
    prob.lb = zeros(N,1);

    % Upper bound is Nx for first var (L1x or L1y) and inf for others
    prob.ub = Inf(N,1);
    prob.ub(1) = Nx;
    prob.ub(Nx + 1) = Nx;

    % Inequality constraints [mono inc on Lx Ly]
    % Ax <= b
    % We have (Nx - 1)*2 constraints for mono inc
    % In the paper:
    % {L^x_i}{\ge L^x_j + 1}{\quad i>j}
    % {L^y_i}{\ge L^y_j + 1}{\quad i>j}
    aRows = (Nx - 1)*2;
    maxInnerRows = Nx*(Nx+1)/2;
    maxRows = maxInnerRows*(Nx*(Nx-1)/2)/2;    
    prob.A = zeros(aRows+maxRows,N,'int8');
    prob.Aeq = [];
    prob.beq = [];
    for r = 1:( aRows)
        c = r;
        if( r > aRows/2)
            c = c + 1;
        end
        prob.A(r,c) = 1;
        prob.A(r,c+1) = -1;
    end
    disp("[Monotonic constraints set]");
    
    % right hand size (b vector) is -1 for <=
    prob.b = -1*ones(aRows,1);

    % Global constraints
    % In the paper:
    % {L^x_i + L^y_j + 1}{\le L^x_k + L^y_q}{\quad \forall i,j,k,q~s.t.~x_i \otimes y_j < x_k \otimes y_q} 
    counter = aRows+1;
    counterI=1;
    constrRowsColl = zeros(Nx*(Nx+1)/2,1);
    for i=1:Nx-1
	msg = sprintf("%d/%d",i,Nx-1);
	disp(msg);
        for j=1:i
            %fprintf("[Setting global constraints for: (%d,%d) ]\n",i,j);
            pvt = struct;
            pvt.r = i;
            pvt.c = j;
            constr = genGlobalConstr(pvt,Nx,tabop);
            constrRows = size(constr.A,1);
            constrRowsColl(counterI) = constrRows;
            prob.A(counter:counter+constrRows-1,:) = constr.A;
            counter = counter+constrRows;
            prob.b = [prob.b; constr.b];   
            counterI=counterI+1;
        end
    end
    prob.A = prob.A(1:size(prob.b,1),:);
    disp("[Global constraints set]");

    % Trasnform int8 A into sparse double A
    disp("[TRANSFORMIG INT8 MATRIX INTO SPARSE DOUBLE]")
    Al = sparse(logical(uint8(prob.A)));
    An = -prob.A;
    clear prob.A;
    Aln = sparse(logical(uint8(An)));
    clear An;
    Ad = double(Al) - double(Aln);
    clear Al;
    clear Aln;
    prob.A = Ad;
    clear Ad;


    % Equality constraints
    % Symmetric across the diagonal
    % Lzij = Lzji
    % In the paper
    % {L^x_i + L^y_j}{= L^x_j + L^y_i}{\quad \forall i, \forall j}
    for r=2:Nx
        for c=1:r-1
            constrRow = zeros(N,1)';
            constrRow(r) = 1;
            constrRow(c+Nx) = 1;
            constrRow(c) = -1;
            constrRow(r+Nx) = -1;
            
            prob.Aeq = [prob.Aeq; constrRow];
            prob.beq = [prob.beq; 0];
        end
    end
    disp(counterI)
    %objective function min sum of all variables
    prob.f = ones(N,1);
    prob.Nx = Nx;
    %solver type
    prob.solver = "intlinprog";

    %options -- not working in direct call of intlinprog (see eval_new.m)
    prob.options = optimoptions('intlinprog');
end
