
% Concepts
% - list of numbers
% - omg problem
% - setup for resolution (as optimal problem)
% - 
n=9;
pk=2;
l2 = [2,3,4]; % positive only
lp = positlist(n,pk); % positive only
l= [-lp ;0; lp]; % full

p1=opomg.create('+',lp);
p1b=opomg.create('+',l,l2);
p2=opomg.create('*',lp);
p3=opomg.create('-',lp);
p4=opomg.create('/',lp);
p5=opomg.create('^',lp);

p=p1;
s=opomg.setup(p);
r=opomg.solve(s);
v=opomg.verify(r);
v