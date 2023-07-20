function [problem, solution, json_sol] = just_solve(prob)
    disp("Solver started");
    problem = prob;
    clear prob;
    Nx = problem.Nx;
    options = optimoptions(@intlinprog,'Display','iter');
    res = intlinprog(problem.f,problem.intcon,problem.A,problem.b,problem.Aeq,problem.beq,problem.lb,problem.ub,options);
    disp("Solver finished");
    resx = int64(res(1:Nx));
    resy = int64(res(Nx+1:2*Nx));
    solution = struct;    
        
    [name,sym] = getFunctionName(problem.op);
    solution.op = name;
    solution.ophandle = problem.op;
    solution.p  = problem.p;
    solution.optab = problem.optab;
    solution.cloptab = problem.cloptab;
    solution.Lx = resx;

    if(problem.anti_sym)
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




function [name,sym] = getFunctionName(op)
    if isequal(op,@times)
        name = "mul";
        sym = "*";
    elseif isequal(op,@plus)
        name = "sum";
        sym = "+";
    elseif isequal(op,@rdivide)
        name = "div";
        sym = "/";
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
            else
                Lzidx = find(lz2zKeys == lzv);
                z = lz2zVals(Lzidx);
                if double(z) ~= double(p)
                    fprintf("=====Error on %d,%d=====\n",i,j);
                    fprintf("%d already in with value: %f (new value: %f)\n",lzv,z,p );
                end
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
    verified = true;
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
                %fprintf("x=%f, y=%f\n",plist(i),plist(j));
                %fprintf("lx=%d, ly=%d\n", Lxi,Lyj);
                %fprintf("lz=%d, lzidx=%d\n",Lzij,Lzidx);

                verified = false;
            end

        end
    end
end

function antisym = checkAntiSymmetry(tab)
    [r,c] = size(tab);
    diffs = zeros(r,c);
    antisym = true;
    for i=1:r
        for j=1:c
            ii = c-j+1;
            jj = r-i+1;
            diffs(i,j) = (tab(i,j) ~= tab(ii,jj));
            if (tab(i,j) ~= tab(ii,jj))
                %fprintf("(%d,%d) diff from (%d,%d), %f != %f\n",i,j,ii,jj,tab(i,j),tab(ii,jj));
                antisym = false;
                return;
            end
        end
    end
end


function encoded = toJsonEncodedSolution(solution)
     jstruct = struct;
     jstruct.Lx1 = solution.Lx;
     jstruct.Lx2 = solution.Ly;
     jstruct.op = solution.op;
     jstruct.Ly  = reshape(solution.Lz.',1,[]);
     jstruct.uLy2y = [solution.Lz2z.keys solution.Lz2z.vals];
     jstruct.x1 = solution.p;
     jstruct.y = reshape(solution.optab.',1,[]);
        
     encoded = jsonencode(jstruct);
     
end

