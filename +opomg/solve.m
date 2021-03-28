function r = solve(problem)

if iscell(problem)
    r={};
    for I=1:length(problem)
        r=[r;opomg.solve(problem{I})];
    end
    return;
end

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
if isfield(problem,'maxint') == 0
    problem.maxint = 32768*4;
end

if ispc
    cmd=sprintf('python %s "%s" %s %s %s --maxint %d -o "%s"',problem.app,fpp,problem.args,first0,mono,problem.maxint,fp);
system(cmd);
else
    cmd=sprintf('env -i bash -l -c ''python3 %s "%s" %s %s %s  --maxint %d -o "%s"''',problem.app,fpp,problem.args,first0,mono,problem.maxint,fp);
system(cmd);
end
e = toc;
if exist(fp,'file')     
    r = opomg.loadsolution(fp);
else
    r = [];
    r.solved = false;
end
    r.cmd=cmd;
        r.elapsed  = e;
