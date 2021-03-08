function p = create(op,l1,l2)

p = [];
p.l1 = l1;
if nargin < 3
    l2 = [];
end
if isempty(l2)
    l2 = l1;
end
l2=l2(:);
l1=l1(:);
p.l2 = l2;
p.op = op;
p.type = 'omgop';
commutative=false;

switch(op)
    case '+'
        %l = [-l; 0; l];
        fx = @(x,y) x+y;    
        commutative = true;
    case '-'
        % only positive
        fx = @(x,y) x-y;
    case '*'
        % only positive
        fx = @(x,y) x.*y;
        commutative = true;
    case '/'
        fx = @(x,y) x./y;
    case '^'
        fx = @(x,y) x.^y;
    otherwise
        fx =op;
        p.op = 'fx';
end
t = bsxfun(fx,l1,l2');

p.t = t;
p.name = op;
p.commutative=commutative;
