rmame='specialpow';
x=[3/2,2,4];
y=[1/4,1/2,3/4,1,3/2,2,4];
% monotone strictly increasing in both x y when x > 1 and y > 0
p5=opomg.create('^',x,y);% not
rname='specialpow'; 
pp = {p5};
rr = {};
rrs=[];
for I=1:length(pp)
    p =pp{I};
    s=opomg.setup(p);
    if s.op =='^'
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