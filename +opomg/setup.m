function p = setup(pp)

l1 = pp.l1;
l2 = pp.l2;
op= pp.op;
commutative= pp.commutative;
name = pp.name;
t  = pp.t;

%%
[x1,~,itx1] = unique(l1);
assert(all(diff(x1)) > 0); % ordered
[x2,~,itx2] = unique(l2);
assert(all(diff(x2)) > 0); % ordered
[y,~,ity] = unique(t); % totals, andt the map from every matrix element to eacy y
assert(all(diff(y)) > 0); % ordered
ny = length(y);

x1b = itx1;
x2b = itx2;
commutative = commutative && length(l1) == length(l2);

if commutative 
    yb = zeros(length(l1),1); % maps of xa to Ya for identity
    for I=1:length(l1)
        yb(I) = find(y == l1(I));
    end
    hasidentity = all(all(y(yb)==l1));
else
    hasidentity= false;
end

% build constraints using the
if commutative  == 0
    c = length(l1)*length(l2);
else
    c = length(l1)*(length(l2)+1)/2; % max due to symmetry
end
%A=zeros(c,ny);
p=zeros(c,2); % index pairs due to binop, also for a op a
b=zeros(c,1);
% half of them!
q=0;
for I=1:length(l1)
    if commutative == 0
        J0=1; % all pairs
    else
        J0=I; % symmetry
    end
    for J=J0:length(l2)
        k = sub2ind(size(t),I,J); % index in table t of product and of mapping
        q = q + 1;
%         if hasidentity && x1b(I) == x2b(J)
%             if y(ity(k)) == x1(x1b(I))
%                 % skip null op
%                 % 1*1 = 1 shall not be ha
%                 % 0+0 = 0 shall not count
%                 %q = q - 1;
%                 %continue
%             end
%             % a+a = 2a
%             % a*a = a^2 
%             % a/a = 1
%             %A(q,xb(I)) = 2;
%         else
%             % La+Lnull=La because they are all positive...
%             if 0==1
%             if x1(x1b(I)) == y(ity(k)) || x2(x1b(J)) == y(ity(k))
%                 % skip null op
%                 %q = q-1;
%                 %continue
%             end
%             end
%             %A(q,xb(I)) = 1;
%             %A(q,xb(J)) = 1;
%         end
        p(q,:)= [x1b(I),x2b(J)]; % also for combinations in Lx
        b(q) = ity(k); % in Ly
        % find L(yb(I))+L(yb(J)) == L(it(k))
        if op=='+'
            assert(x1(x1b(I))+x2(x2b(J)) == y(ity(k)))
        elseif op=='*'
            assert(x1(x1b(I))*x2(x2b(J)) == y(ity(k)))
        elseif op=='/'
           % assert(x1(x1b(I))/x2(x2b(J)) == y(ity(k)))
        elseif op=='^'
            assert(x1(x1b(I))^x2(x2b(J)) == y(ity(k)))
        end
        % yb(I) L1 + yb(J) L2 = it(k) Lx 
        %
        % assert  A(k,:)*L = b(k)  so that   
        %   yb(I) + yb(H) = it(k)
        %   y(yb(I))+y(yb(J))=y(it(k))
        % where L is integer
    end
end
%A = A(1:q,:);
b = b(1:q,:);
p = p(1:q,:);
%assert(all(sum(A,2) ==2))
nx1 = length(l1);
nx2 = length(l2);

problem = [];
problem.ny = ny;
problem.nx1 = nx1;
problem.nx2 = nx2;
problem.op = op;
%problem.A = A; % too big and not needed
%problem.zero = zz; % index of null
problem.p = p; % shorter
problem.b= b;
problem.commutative = commutative;
problem.samex = nx1 == nx2 && all(l1 == l2);
problem.x1 = x1;
problem.x2 = x2;
problem.y = y;
problem.hasidentity = hasidentity;
problem.name = name;
problem.type = 'omgproblem';
p = problem;
