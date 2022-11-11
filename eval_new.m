

n = 4;
k = 0;
Nx = (2^(n - 1) - 1);
op = @plus;
plist = positlist(n,k);
ptab = bsxfun(op, plist,plist');
cloptab = closestPtab(ptab,plist);
disp("Problem setup started...");
prob = genProblemNew(n,k,op,ptab);
disp("Problem setup completed");

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
solution.cloptab = cloptab;
solution.Lx = resx;
solution.Ly = resy;
solution.Lz = resx + resy';

solution.Lz2z = genLz2z(solution.Lz,solution.cloptab,solution.p);


solution.Lx;

verify(solution.optab,solution.cloptab,solution.p,solution.Lx,solution.Ly,solution.Lz2z);


function name = getFunctionName(op)
    if isequal(op,@times)
        name = "mul";
    elseif isequal(op,@plus)
        name = "sum";
    end
end

function ptab = closestPtab(optab,plist)
    r = size(optab,1);
    c = size(optab,2);
    ptab =zeros("like",optab);
    for i=1:r
        for j=1:c
            p = optab(i,j);

            % closest posit and relative index
            [~, idx] = min(abs(plist-p));
            minp = plist(idx);
            ptab(i,j) = minp;
        end
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
            %[~, idx] = min(abs(plist-p));
            %minp = plist(idx);

            % map idx to correspondent z (only if not contained)
            lzv = Lz(i,j);
            if ~ismember(lzv,lz2zKeys)
                lz2zKeys = [lz2zKeys; lzv];
                lz2zVals = [lz2zVals; p];
            end
        end
    end
    lz2z.keys = lz2zKeys;
    lz2z.vals = lz2zVals;
end

function optab1d = setSecDiagToOne(optab)
    r = size(optab,1);
    optab1d = optab;

    dd = fliplr(diag(ones(r,1)));
    dd1m = 1 - dd;

    optab1d = (optab1d .* dd1m) + dd;

end

function verified = verify(optab,cloptab,plist,Lx,Ly,Lz2z)
    r = size(Lx,1);
    r1 = size(Ly,1);
    assert(r == r1,"Lx,Ly sizes do not match");
    for i=1:r
        for j=1:r
            result = cloptab(i,j);
            Lxi = Lx(i);
            Lyj = Ly(j);
            Lzij = Lxi + Lyj;
            
            Lzidx = find(Lz2z.keys == Lzij);
            z = Lz2z.vals(Lzidx);
               
            if z ~= result 
                fprintf("===== Error on %d,%d =====\n",i,j);
                fprintf("z=%f, exp=%f, exact=%f\n",z,result,optab(i,j));
                fprintf("x=%f, y=%f\n",plist(i),plist(j));
                fprintf("lx=%d, ly=%d\n", Lxi,Lyj);
                fprintf("lz=%d, lzidx=%d\n",Lzij,Lzidx);
            end

        end
    end
    verified = true;
end
