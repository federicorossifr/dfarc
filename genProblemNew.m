function [prob] = genProblemNew(nbits,esbits,fun)

    % List of posit numbers
    plist = positlist(nbits,esbits);

    % Table of operation
    tabop = bsxfun(fun,plist,plist');

    % Number of problem variables
    % Nx = 2^{nbits - 1} - 1
    % Ny = Nx
    % tot = 2*Nx
    Nx = (2^(nbits - 1) - 1);
    N = 2*Nx;
    prob = struct;
    prob.intcon = 1:N;

    % Lower bound is 0 for every variable
    prob.lb = zeros([N 1]);

    % Upper bound is Nx for first var (L1x or L1y) and inf for others
    prob.ub = Inf(N,1);
    prob.ub(1) = Nx;
    prob.ub(Nx + 1) = Nx;

    % Inequality constraints [mono inc on Lx Ly]
    % Ax <= b
    % We have (Nx - 1)*2 constraints for mono inc
    aRows = (Nx - 1)*2;
    k = Nx - 2;
    nV = (k + 1)*k/2;
    prob.A = zeros([aRows N]);
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
    
    % right hand size (b vector) is -1 for <=
    prob.b = -1*ones(size(prob.A,1),1);

    % Using diagonal elements as pivot for additional inequalities
    % and equalities. We exploit the actual "tabop" tabulated 
    % posit result to impose equality between Lzs or inequalities
    % for now inequalities are expressed as <=
    % For simmetry, we only operate on the bottom half triangular matrix
    for d = 2:Nx-1
        pvt1 = struct;
        pvt1.r = d;
        pvt1.c = d;
        constr = genConstr(pvt1,Nx,tabop);
        prob.A = [prob.A ; constr.A];
        prob.b = [prob.b ; constr.b];
        prob.Aeq = [prob.Aeq; constr.Aeq];
        prob.beq = [prob.beq; constr.beq];
        
        pvt1.r = d+1;
        constr = genConstr(pvt1,Nx,tabop);
        prob.A = [prob.A ; constr.A];
        prob.b = [prob.b ; constr.b];
        prob.Aeq = [prob.Aeq; constr.Aeq];
        prob.beq = [prob.beq; constr.beq];    
    end



    % Equality constraints
    % Symmetric across the diagonal
    % Lzij = Lzji
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

    %objective function min sum of all variables
    prob.f = ones(N,1);
    
    %solver type
    prob.solver = "intlinprog";

    %options -- not working in direct call of intlinprog (see eval_new.m)
    prob.options = optimoptions('intlinprog');
end