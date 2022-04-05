% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=4;
pk=0;
rname = sprintf('posit%d,%d',n,pk);
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp;NaN]; % ful
lpg1 = lp(lp > 1);
lpl1 = lp(lp < 1);
lpn1 =lp(lp~=1);
lpz = l(l>0);

lx1 = [lp];
lx2 = lx1;

p1=opomg.create('*',lpz,[],lpz,'mul');
p2=opomg.create('+',lpz,[],lpz,"plus");      

%p3=opomg.create('-',lx1,lx2,[],'minus'); 
p4=opomg.create('/',lpz,[],lpz,'div'); % full=1 not working if 0 lp
%p5=opomg.create('^',lx1,lx2,[],'exp');
%p6=opomg.create('atan2',lx1,lx2,[],'atan2');

pp = {p1,p2,p4};
%pp = {p1,p2,p6};
%pp = {p1,p2,p6};
%pp={p1};
rr = {};
rrs=[];
for I=1:length(pp)
    p =pp{I};
    p.full=1;
    s=opomg.setup(p);
    s.firstsol=false;
    s.timelimit = 240;
    if p.full == 1
        s.xpolicy = 'distinct';
        s.ypolicy = 'none';
        
        s.target = "sum"; % sum
        s.samex=false;
        s.negative=false;
    else
    
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
    end
    r=opomg.solve(s);
%     v=opomg.verify(r);
%     rr{end+1}= v;
%     rs = struct();    
%     rs.name = rname;
%     if isfield(p,'ename')
%         rs.name =[rs.name  ' ' p.ename];
%     end
%     rs.op = p.op;
%     rs.app=s.app;
%     rs.solved = v.solved;
%     rs.verified = v.verified;
%     rs.nx = size(s.x1,1);
%     rs.ny = size(s.y,1);
%     rs.negative = s.negative;
%     rs.xppolicy = s.xpolicy;
%     rs.full = s.full;
%     rs.commutative = s.commutative;
%     rs.samex = s.samex;
%     if v.solved 
%         rs.maxLx1 = max(r.Lx1);
%         if isfield(r,'Lx2')
%             rs.maxLx2 = max(r.Lx2);
%         else
%             rs.maxLx2 = rs.maxLx1;
%         end
%         rs.maxLy = max(r.Ly);
%     else
%         rs.maxLx1 = 0;
%         rs.maxLx2 = 0;
%         rs.maxLy = 0;        
%     end       
%     rs.elapsed = r.elapsed;
%     rrs = [rrs; rs];
end
%naivesize_y=(rs(1).nx-1)*rs(1).nx+(rs(1).nx-1)
rrs = []
'done'
rrs
