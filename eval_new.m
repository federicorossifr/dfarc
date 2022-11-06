

n = 3;
k = 0;
Nx = (2^(n - 1) - 1);
op = @times;
prob = genProblemNew(n,k,op);
disp("Problem setup completed");
plist = positlist(n,k);
ptab = bsxfun(op, plist,plist');
disp("Solver started...");
res = intlinprog(prob.f,prob.intcon,prob.A,prob.b,prob.Aeq,prob.beq,prob.lb,prob.ub);
disp("Solver finished");
resx = int64(res(1:Nx));
resy = int64(res(Nx+1:2*Nx));
solution = struct;

solution.op = getFunctionName(op);
solution.ophandle = op;
solution.p  = plist;
solution.optab = ptab;
solution.Lx = resx;
solution.Ly = resy;
solution.Lz = resx + resy';

solution


function name = getFunctionName(op)
    if isequal(op,@times)
        name = "mul";
    elseif isequal(op,@plus)
        name = "sum";
    end
end

function lz2z = genLz2z(Lz,optab)
    lz2z = [];
end
