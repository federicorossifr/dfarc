

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

lz2z = genLz2z(solution.Lz,solution.optab,solution.p)


solution


function name = getFunctionName(op)
    if isequal(op,@times)
        name = "mul";
    elseif isequal(op,@plus)
        name = "sum";
    end
end

function lz2z = genLz2z(Lz,optab,plist)
    % We map the Lz set to the original z (optab) set
    % We want to discard duplicates, since they map to the
    % same element in z
    % Elements of optab may not be present in z (round to nearest)

    r = size(optab,1);
    c = size(optab,2);
    
    lz2zKeys = [];
    lz2zVals = [];
    lz2z = struct;
    for i=1:r
        for j=1:c
            p = optab(i,j);

            % closest posit and relative index
            [~, idx] = min(abs(plist-p));
            minp = plist(idx);

            % map idx to correspondent z (only if not contained)
            lzv = Lz(i,j);
            if ~ismember(lzv,lz2zKeys)
                lz2zKeys = [lz2zKeys; lzv];
                lz2zVals = [lz2zVals; minp];
            end
        end
    end
    lz2z.keys = lz2zKeys;
    lz2z.vals = lz2zVals;
end
