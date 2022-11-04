function [prob] = genProblemNew(nbits)
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
    % We have additional inequalities nV
    % k = Nx - 2 ; nV = (k+1)k/2

    aRows = (Nx - 1)*2;
    k = Nx - 2;
    nV = (k + 1)*k/2;
    prob.A = zeros([aRows N]);
    for r = 1:( aRows)
        c = r;
        if( r > aRows/2)
            c = c + 1;
        end
        prob.A(r,c) = 1;
        prob.A(r,c+1) = -1;
    end

    prob.b = -1*ones(aRows+nV,1);
    for d = 2:Nx-1
        pvt1 = struct;
        pvt1.r = d;
        pvt1.c = d;
        prob.A = [prob.A ; genConstr(pvt1,Nx)];

        pvt1.r = d+1;
        prob.A = [prob.A ; genConstr(pvt1,Nx)];
    end

    % Equality constraints
    % Symmetric across the diagonal
    % Lzij = Lzji
    prob.Aeq = [];

    for r=2:Nx
        for c=1:r-1
            constrRow = zeros(N,1)';
            constrRow(r) = 1;
            constrRow(c+Nx) = 1;
            constrRow(c) = -1;
            constrRow(r+Nx) = -1;
            
            prob.Aeq = [prob.Aeq; constrRow];
        end
    end
    prob.beq = zeros(size(prob.Aeq,1),1);

    %objective function min sum of all variables
    prob.f = ones(N,1);
    

    %solver type
    prob.solver = "intlinprog";

    %options
    prob.options = optimoptions('intlinprog');


end