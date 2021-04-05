% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=6;
pk=0;
rname = sprintf('posit%d,%d',n,pk);
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % ful
lpg1 = lp(lp > 1);
lpl1 = lp(lp < 1);
lpn1 =lp(lp~=1);
lp0 = lp(lp >= 1 & lp<2);

p1=opomg.create('+',lp);        
p2=opomg.create('*',lp);
p20=opomg.create('*',lp0);
p3=opomg.create('-',lp); % not
p4=opomg.create('/',lp); % not
p5=opomg.create('^',lpg1,lp);% not
p5n=opomg.create('^',lpl1,lp);% not
p5.ename = '(x>1)';
p5n.ename = '(x<1)';
p6=opomg.create('atan2',lp);% not

pp = {p1,p2,p3,p4,p5,p5n,p6};
%pp = {p1,p2};
pp={p2,p20};
rr = {};
rrs=[];
for I=1:length(pp)
    p =pp{I};
    s=opomg.setup(p);
    %s.args = '--firstsol';
    %s.app='solve0.py';
    if s.op =='/'
    s.samex = true; % for division and atan2 without negative
    s.negative=true;
    end
    if s.op =='-'
    s.negative=true;
    end
    if strcmp(s.op,'atan2')
        s.samex = false;
        s.mono=false;
    end
    r=opomg.solve(s);
    v=opomg.verify(r);
    rr{end+1}= v;
    rs = struct();    
    rs.name = rname;
    if isfield(p,'ename')
        rs.name =[rs.name  ' ' p.ename];
    end
    rs.op = p.op;
    rs.app=s.app;
    rs.solved = v.solved;
    rs.verified = v.verified;
    rs.nx = size(s.x1,1);
    rs.ny = size(s.y,1);
    rs.negative = s.negative;
    rs.mono = s.mono;
    rs.commutative = s.commutative;
    rs.samex = s.samex;
    if v.solved 
        rs.maxLx = max(r.Lx1);
        rs.maxLy = max(r.Ly);
    else
        rs.maxLx = 0;
        rs.maxLy = 0;        
    end       
    rs.elapsed = r.elapsed;
    rrs = [rrs; rs];
end
rrs = struct2table(rrs);
'done'
rrs
%%
ra=rr{1};
r=rr{2};
r05 = opomg.binexpand(r,-1);
r025 = opomg.binexpand(r05,-1);
r2 = opomg.binexpand(r);
r4 = opomg.binexpand(r2);
r8 = opomg.binexpand(r4);
disp('showbinades all')
countbinades(ra.x1)
disp('showbinades')
countbinades(r025.x1)
countbinades(r05.x1)
countbinades(r.x1)
countbinades(r2.x1)
countbinades(r4.x1)
countbinades(r8.x1)
disp('showranges')
[r025.x1(1),r025.x1(end)]
[r05.x1(1),r05.x1(end)]
[r.x1(1),r.x1(end)]
[r2.x1(1),r2.x1(end)]
[r4.x1(1),r4.x1(end)]
[r8.x1(1),r8.x1(end)]
disp('verify');
 v025=opomg.verify(r025);
 v05=opomg.verify(r05);
 v2=opomg.verify(r2);
 v4=opomg.verify(r4);
 v8=opomg.verify(r8);
 v05.verified
 v.verified
 v2.verified
 v4.verified
 v8.verified