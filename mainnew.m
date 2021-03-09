
% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=4;
pk=0;
l2 = [2,3,4]; % positive only
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % full

p1=opomg.create('+',lp);        
p1b=opomg.create('+',l,l2);
p2=opomg.create('*',lp);
p3=opomg.create('-',[0;lp]); % not
p4=opomg.create('/',lp); % not
p5=opomg.create('^',lp);% not
p6=opomg.create('atan2',lp);% not

p=p6;
s=opomg.setup(p);
s.samex = true; % for division and atan2 without negative
s.negative=true;
r=opomg.solve(s);
v=opomg.verify(r);
v
[min(v.Lx1),max(v.Lx1);min(v.Ly),max(v.Ly)]
v.Lq