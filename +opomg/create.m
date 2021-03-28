function p = create(op,l1,l2,name,K)

if nargin < 5
    K=1;
end

if nargin < 4
    name='';
end

if nargin < 3
    l2 = [];
end
if isempty(l2)
    l2 = l1;
end
l2=l2(:);
l1=l1(:);
if K > 1
    commutative = strcmp(op,'+') || strcmp(op,'*');
    p={};
    p1 =fix(linspace(1,length(l1),K+1));
    p2 =fix(linspace(1,length(l2),K+1));
    for I=1:length(p1)-1
        if commutative
            J1=I;
        else
            J1=1;
        end
        for J=J1:length(p2)-1
            ename = [name sprintf('split%dx%d',I,J)];
            al1 = l1(p1(I):p1(I+1));
            al2 = l2(p2(J):p2(J+1));
            ps = opomg.create(op,al1,al2,ename,1);
            p=[p;ps];
        end
    end
    return;
end

p = [];
p.l1 = l1;
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
        p.negative = true;
    case '*'
        % only positive
        fx = @(x,y) x.*y;
        commutative = true;
        p.mono = true;
    case '/'
        fx = @(x,y) x./y;
        p.mono = true;
       p.samex = true; % for division and atan2 without negative
        p.negative=true;
    case '^'
        fx = @(x,y) x.^y;
    case 'atan2'
        fx = @(x,y) atan2(x,y);
        p.mono = false;
        p.samex = false;
        p.negaive = true;
    otherwise
        fx =op;
        p.op = 'fx';
end
t = bsxfun(fx,l1,l2');

p.t = t;
p.name = op;
p.ename=name;
p.commutative=commutative;



