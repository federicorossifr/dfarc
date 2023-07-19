function [problem, solution, json_sol] = just_solve(prob)
    disp("Solver started");
    problem = prob;
    Nx = prob.Nx;
    res = intlinprog(problem.f,problem.intcon,problem.A,problem.b,problem.Aeq,problem.beq,problem.lb,problem.ub);
    disp("Solver finished");
    resx = int64(res(1:Nx));
    resy = int64(res(Nx+1:2*Nx));
    solution = struct;    
        
    [name,sym] = getFunctionName(problem.op);
    solution.op = name;
    solution.ophandle = problem.op;
    solution.p  = problem.plist;
    solution.optab = problem.ptab;
    solution.cloptab = problem.cloptab;
    solution.Lx = resx;

    if(antiSym)
        solution.Ly = flip(resy);
    else
        solution.Ly = resy;
    end


    solution.Lz = solution.Lx + solution.Ly';
    
    solution.Lz2z = genLz2z(solution.Lz,solution.cloptab,solution.p);
    solution.verified = verify(solution.optab,solution.cloptab,solution.p,solution.Lx,solution.Ly,solution.Lz2z);
    solution.op = sym;
    json_sol = toJsonEncodedSolution(solution);   
end