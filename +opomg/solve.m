function r = solve(problem)

problem.fx = [];
fpp = 'problem.json';
f = fopen(fpp,'w');
fwrite(f,jsonencode(problem));
fclose(f);
fp = 'result.json';
if exist(fp,'file')
    delete(fp,'file');
end
tic
if problem.nonmono
    nonmono = '--nonmono'
else
    nonmono='';
end
if ispc
system(sprintf('python solve.py "%s" %s -o "%s"',fpp,nonmono,fp));
else
system(sprintf('env -i bash -l -c ''python3 solve.py "%s" %s --f0 -o "%s"''',fpp,nonmono,fp));
end
e = toc;
if exist(fp,'file')     
    r = opomg.loadsolution(fp);
    if ~isempty(r)
        r.elapsed  = e;
    end
else
    r = [];
end
