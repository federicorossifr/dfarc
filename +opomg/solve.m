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
if isfield(problem,'mono') == 0
    problem.mono = false;
end
if isfield(problem,'first0') == 0
    problem.first0 = false;
end
if problem.mono
    mono = '--mono';
else
    mono='';
end
if problem.first0
    first0 = '--first0';
else
    first0='';
end
if isfield(problem,'args') == 0
    problem.args = '';
end
if isfield(problem,'app') == 0
    problem.app = 'solve.py';
end
if ispc
system(sprintf('python %s "%s" %s %s %s -o "%s"',problem.app,fpp,problem.args,first0,mono,fp));
else
system(sprintf('env -i bash -l -c ''python3 %s "%s" %s %s %s -o "%s"''',problem.app,fpp,problem.args,first0,mono,fp));
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
