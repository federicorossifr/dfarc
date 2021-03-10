
% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=8;
pk=0;
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % full

p1=opomg.create('+',lp);        
p2=opomg.create('*',lp);
p3=opomg.create('-',lp); % not
p4=opomg.create('/',lp); % not
p5=opomg.create('^',lp);% not
p6=opomg.create('atan2',lp);% not

pp = {p1,p2,p3,p4,p6};
rr = {};
for I=1:length(pp)
    p =pp{I};
    s=opomg.setup(p);
    s.mono=false;
    s.args = '--firstsol';
    if s.op =='/'
    s.samex = false; % for division and atan2 without negative
    s.negative=true;
    end
    r=opomg.solve(s);
    v=opomg.verify(r);
    rr{end+1}= v;
end