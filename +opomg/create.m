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
p.mono = false;
commutative=false;

switch(op)
    case '+'
        %l = [-l; 0; l];
        fx = @(x,y) x+y;    
        commutative = true;
        p.mono = true;
    case '-'
        % only positive
        fx = @(x,y) x-y;
        p.mono = true;
    case '*'
        % only positive
        fx = @(x,y) x.*y;
        commutative = true;
        p.mono = true;
    case '/'
        fx = @(x,y) x./y;
        p.mono = true;
    case '^'
        fx = @(x,y) x.^y;
    case 'atan2'
        fx = @(x,y) atan2(x,y);
    otherwise
        fx =op;
        p.op = 'fx';
end
t = bsxfun(fx,l1,l2');

p.t = t;
p.name = op;
p.commutative=commutative;
