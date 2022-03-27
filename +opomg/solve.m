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
if isfield(problem,'xpolicy') == 0 && isfield(problem,'ypolicy') == 0
    % enforce mono
    if isfield(problem,'mono') == 0
        problem.xpolicy = 'distinct';
        problem.ypolicy = 'distinct';
    else
        problem.xpolicy = 'mono';
        problem.ypolicy = 'mono';
    end
end
if isfield(problem,'first0') == 0
    problem.first0 = false;
end
xpolicy = ['--xpolicy ' problem.xpolicy];
ypolicy = ['--ypolicy ' problem.ypolicy];

if problem.first0
    first0 = '--first0';
else
    first0='';
end
if isfield(problem,'args') == 0
    problem.args = '';
end
if isfield(problem,'timelimit') == 0
    problem.timelimit = 0;
end
if isfield(problem,'app') == 0
    problem.app = 'solve.py';
end
if isfield(problem,'target') == 0
    problem.target = 'sum';
end
if isfield(problem,'firstsol') == 0
    problem.firstsol = false;
end
if isfield(problem,'minint') == 0
    minint = '';
else
    if isnan(problem.minint)
        minint = '';
    else
        minint = sprintf('--minint %d',problem.minint);
    end
end
if isfield(problem,'maxint') == 0
    problem.maxint = 0;
end
if problem.firstsol
    firstsol = '--firstsol';
else
    firstsol = '';
end
if problem.timelimit ~= 0
    timelimit = sprintf('--time-limit %d',problem.timelimit);
else
    timelimit = '';
end
if ispc
    cmd=sprintf('python %s "%s" %s %s %s %s %s --maxint %d -o "%s" --target %s %s %s',problem.app,fpp,problem.args,first0,xpolicy,ypolicy,minint,problem.maxint,fp,problem.target,firstsol,timelimit);
system(cmd);
else
    py='/Users/eruffaldi/venv/bin/python3';
 cmd=sprintf('env -i bash -l -c ''%s %s "%s" %s %s %s %s %s --maxint %d -o "%s" --target %s %s %s''',py,problem.app,fpp,problem.args,first0,xpolicy,ypolicy,minint,problem.maxint,fp,problem.target,firstsol,timelimit);
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
