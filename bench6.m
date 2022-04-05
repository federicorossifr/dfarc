% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=6;
K=2;
pk=2;
rname = sprintf('posit%d,%d',n,pk);
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % ful
lpg1 = lp(lp > 1);
lpl1 = lp(lp < 1);
lpn1 =lp(lp~=1);

p1=opomg.create('+',lp,[],rname,K);        
p2=opomg.create('*',lp,[],rname,K);
p3=opomg.create('-',lp,[],rname,K); % not
p4=opomg.create('/',lp,[],rname,K); % not
p5=opomg.create('^',lpg1,lp,[rname '(x>1)'],K);% not
p5n=opomg.create('^',lpl1,lp,[rname '(x<1)'],K);% not
p6=opomg.create('atan2',lp,[],rname,K);% not

pp = {p1,p2,p3,p4,p5,p5n,p6};
%pp = {p1,p2,p3,p4}; %,p5,p5n,p6};
%pp={p4};
%pp = {p1,p2};
rr = {};
rrs=[];
for I=1:length(pp)
    p =pp{I};
    s=opomg.setup(p);
    %s.args = '--firstsol';
    %s.app='solve0.py';
%     
%     if s.op =='/'
%     s.samex = true; % for division and atan2 without negative
%     s.negative=true;
%     s.mono=true;
%     end
%     if strcmp(s.op,'atan2')
%         s.samex = false;
%         s.mono=false;
%     end
    if iscell(s) == 0
        s={s};
    end
    r=opomg.solve(s);
%     if iscell(r) == 0
%         r={r};
%     end
%     v=opomg.verify(r);
%     if iscell(v) == 0
%         v={v};
%     end
%     vv=v;
%     ss=s;
%     rr=r;
%     for J=1:length(vv)
%         s=ss{J};
%         v=vv{J};
%         r=rr{J};
%         rr{end+1}= v;
%         rs = struct();
%         rs.name = rname;
%         if isfield(p,'ename')
%             rs.name =[rs.name  ' ' p.ename];
%         end
%         rs.op = s.op;
%         rs.app=s.app;
%         rs.solved = v.solved;
%         rs.verified = v.verified;
%         rs.nx = size(s.x1,1);
%         rs.ny = size(s.y,1);
%         rs.negative = s.negative;
%         rs.mono = s.mono;
%         rs.commutative = s.commutative;
%         rs.samex = s.samex;
%         if v.solved 
%             rs.maxLx = max(r.Lx1);
%             rs.maxLy = max(r.Ly);
%         else
%             rs.maxLx = 0;
%             rs.maxLy = 0;        
%         end       
%         rs.elapsed = r.elapsed;
%         rrs = [rrs; rs];
end
rrs = []
'done'
rrs