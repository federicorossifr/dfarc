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
w = all(sol.Ly(sol.b) == sol.Lx1(sol.p(:,1)) + sol.Lx2(sol.p(:,2)));
r = sol;
r.verified = all(w);
