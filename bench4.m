% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=4;
pk=0;
rname = sprintf('posit%d,%d',n,pk);
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % full

p1=opomg.create('+',lp);        
p2=opomg.create('*',lp);
p3=opomg.create('-',lp); % not
p4=opomg.create('/',lp); % not
p5=opomg.create('^',lp);% not
p6=opomg.create('atan2',lp);% not

pp = {p1,p2,p3,p4,p5,p6};
%pp = {p1,p2};
rr = {};
rrs=[];
for I=1:length(pp)
    p =pp{I};
    s=opomg.setup(p);
    %s.args = '--firstsol';
    %s.app='solve0.py';
    if s.op =='/'
    s.samex = false; % for division and atan2 without negative
    s.negative=true;
    end
    if s.op =='-'
    s.negative=true;
    end
    if s.op =='^'
        s.samex = true;
        s.mono =false;
    end
    r=opomg.solve(s);
    v=opomg.verify(r);
    rr{end+1}= v;
    rs = struct();
    rs.name = rname;
    rs.op = s.op;
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