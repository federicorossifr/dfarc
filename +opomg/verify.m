function r = verifysolution(sol)

if isempty(sol)
    r.solved = false;
    r.verified = false;
    return;
end
if ~sol.solved
    r = sol; 
    r.verified = false;
    return
end

if sol.samex
    sol.Lx2 = sol.Lx1;
end
sol.r_monox1 = all(diff(sol.Lx1)>0);
if sol.samex
    sol.r_samex = true;
    sol.r_monox2 = sol.r_monox1;
else
    if length(sol.Lx1) == length(sol.Lx2)
        sol.r_samex = all(sol.Lx1 == sol.Lx2);
    else
        sol.r_samex = false;
    end
    sol.r_monox2 = all(diff(sol.Lx2)>0);
end
if isfield(sol,'negative')==0
    sol.negative=false;
end
if sol.negative
    w = all(sol.Ly(sol.b) == sol.Lx1(sol.p(:,1)) - sol.Lx2(sol.p(:,2))  + sol.Lq);
else
    w = all(sol.Ly(sol.b) == sol.Lx1(sol.p(:,1)) + sol.Lx2(sol.p(:,2)));
end
r = sol;
r.verified = all(w);
