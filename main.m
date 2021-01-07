
%%
n=4;
pk=0;
l = positlist(n,pk);
op='/'; % not yet
op='/'; % 
op='/'; % 105c for posit4
op='*'; % 
if op =='+'
    % all numbers
l = [-l; 0; l];
t = bsxfun(@(x,y) x+y,l,l');
elseif op =='*'
    % obly positive > 1
t = bsxfun(@(x,y) x*y,l,l');
elseif op =='/'
    % obly positive > 1
t = bsxfun(@(x,y) x/y,l,l');
end
[x,~,itx] = unique(l);
assert(all(diff(x)) > 0); % ordered
[y,~,ity] = unique(t); % totals, andt the map from every matrix element to eacy y
assert(all(diff(y)) > 0); % ordered
ny = length(y);

xb = itx;
yb = zeros(length(l),1); % maps of xa to Ya
for I=1:length(l)
    yb(I) = find(y == l(I));
end
assert(all(y(yb)==l))



% build constraints using the
if op == '/'
    c = length(l)*length(l);
else
    c = length(l)*(length(l)+1)/2; % max due to symmetry
end
%A=zeros(c,ny);
p=zeros(c,2); % index pairs due to binop, also for a op a
b=zeros(c,1);
% half of them!
q=0;
for I=1:length(l)
    if op =='/'
        J0=1; % all pairs
    else
        J0=I; % symmetry
    end
    for J=J0:length(l)
        k = sub2ind(size(t),I,J); % index in table t of product and of mapping
        q = q + 1;
        if xb(I) == xb(J)
            if y(ity(k)) == x(xb(I))
                % skip null op
                % 1*1 = 1 shall not be ha
                % 0+0 = 0 shall not count
                %q = q - 1;
                %continue
            end
            % a+a = 2a
            % a*a = a^2 
            % a/a = 1
            %A(q,xb(I)) = 2;
        else
            % La+Lnull=La because they are all positive...
            if x(xb(I)) == y(ity(k)) || x(xb(J)) == y(ity(k))
                % skip null op
                %q = q-1;
                %continue
            end
            %A(q,xb(I)) = 1;
            %A(q,xb(J)) = 1;
        end
        p(q,:)= [xb(I),xb(J)]; % also for combinations in Lx
        b(q) = ity(k); % in Ly
        % find L(yb(I))+L(yb(J)) == L(it(k))
        if op=='+'
            assert(x(xb(I))+x(xb(J)) == y(ity(k)))
        elseif op=='*'
            assert(x(xb(I))*x(xb(J)) == y(ity(k)))
        elseif op=='/'
            assert(x(xb(I))/x(xb(J)) == y(ity(k)))
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
nx = length(l);

problem = [];
problem.ny = ny;
problem.nx = nx;
problem.op = op;
%problem.A = A; % too big and not needed
%problem.zero = zz; % index of null
problem.p = p; % shorter
problem.b= b;
problem.x = x;
problem.y = y;
problem.name = sprintf('posit%d,%d %s',n,pk,op);


f = fopen('problem.json','w');
fwrite(f,jsonencode(problem));
fclose(f);
%%
problem

%%
%problem to ILP problem
%DX1 DY1 is first value (>= 0)
%DXi DYi is the delta (> 0)
%LXi = sum of all previous
%LYi = sum of all prevpios
%A is c x n matrix built from p(I,1) p(I,2) -> b(I,3)
%
%ILP graph is every pairs ine very row
nc = length(b);
Ac1 = zeros(nc,nx+ny); 
Ac2 = Ac1;

% for Ax<=b equality means two equations A_i x<=b_i and -A_i x <= -b_i
bc1 = zeros(nc,1);
bc2 = bc1;
bnx1 = zeros(nx,1);
bny1 = zeros(ny,1);

for I=1:nc
    % .... <= 0
    Ac1(I,1:p(I,1)) = 1; % Li = D1 ... Di
    Ac1(I,1:p(I,2)) = Ac1(I,1:p(I,2))+1; % Lj = D1..Dj (overlap)
    Ac1(I,nx+(1:b(I))) = -1; % out Lij = Q1..Qij neg 

    % -(...) <= 0
    Ac2(I,1:p(I,1)) = -1; % Li = D1 ... Di
    Ac2(I,1:p(I,2)) = Ac2(I,1:p(I,2))-1; % Lj = D1..Dj (overlap)
    Ac2(I,nx+(1:b(I))) = 1; % out Lij = Q1..Qij neg 
end

% enforce: x_i > 0
% as: -x_i <= -1
Anx1 = zeros(nx,nx+ny);
Any1 = zeros(ny,nx+ny);
for I=1:nx
    Anx1(I,I) = -1;
    bnx1(I) = -1;
end
for I=1:ny
    Any1(I,nx+I) = -1;
    bny1(I) = -1;
end

Aq = [Ac1;Ac2;Anx1;Any1];
bq = [bc1;bc2;bnx1;bny1];

Q=Aq'; %dual graph
Q=Aq;  %primal
G = zeros(size(Q,2),size(Q,2));

%an edge between vertices si and j exists if A contains a row which is nonzero in coordinates i and 
for I=1:size(G,1)
    cI = Q(:,I) ~= 0;
    for J=I+1:size(G,1)
        cJ = Q(:,J) ~= 0;
        c = cI & cJ;
        if any(c) 
            G(I,J) = 1;
            G(J,I) = 1;
        end
    end
end
dG= det(G) 

a=max(abs(Q(:))); % = 2
%The treedepth of a graph denoted td(G) is the smallest height of a rooted forest
%F such that each edge of G is between vertices which are in a descendant-ancestor relationship
%in F
d=1; % fully connected

%%
spy(Aq)
%%
spy(G)
