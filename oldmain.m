
%%
n=4;
pk=0;
l = positlist(n,pk);
commutative=false;
op='/'; % not yet
op='/'; % 
op='/'; % 105c for posit4
op='/';
op='^'; % 
name = sprintf('posit%d,%d %s',n,pk,op);
if op =='+'
    % all numbers
    l = [-l; 0; l];
    fx = @(x,y) x+y;    
    commutative = true;
elseif op =='*'
    % obly positive > 1
    fx = @(x,y) x.*y;
    commutative = true;
elseif op =='/'
    % obly positive > 1
    fx = @(x,y) x./y;
elseif op =='^'
    % all numbers
    l = [-l; 0; l];
    fx = @(x,y) x.^y;
end
l1 = l;
l2 = l;
l1 = [3/2,2,4];
l2 = [1/4,1/2,3/4,1,3/2,2,4];
%name = 'special';
t = bsxfun(fx,l1,l2');
if length(l1)~=length(l2)
    t = t';
end



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
if problem.samex
    nx = nx1;
else
    nx = nx1+nx2;
end
Ac1 = zeros(nc,nx+ny); 
Ac2 = Ac1;

% for Ax<=b equality means two equations A_i x<=b_i and -A_i x <= -b_i
bc1 = zeros(nc,1);
bc2 = bc1;
bnx1 = zeros(nx1,1);

bny1 = zeros(ny,1);
if problem.samex
    basex2=0;
else
    bnx2 = zeros(nx2,1);
    basex2 = nx1-1;
end
for I=1:nc
    % .... <= 0
    Ac1(I,1:p(I,1)) = 1; % Li = D1 ... Di
    Ac1(I,basex2+1:p(I,2)) = Ac1(I,basex2+1:p(I,2))+1; % Lj = D1..Dj (overlap)
    Ac1(I,nx+(1:b(I))) = -1; % out Lij = Q1..Qij neg 

    % -(...) <= 0
    Ac2(I,1:p(I,1)) = -1; % Li = D1 ... Di
    Ac2(I,basex2+1:p(I,2)) = Ac2(I,basex2+1:p(I,2))-1; % Lj = D1..Dj (overlap)
    Ac2(I,nx+(1:b(I))) = 1; % out Lij = Q1..Qij neg 
end

% enforce: x_i > 0
% as: -x_i <= -1
Anx1 = zeros(nx1,nx+ny);
Any1 = zeros(ny,nx+ny);
for I=1:nx1
    Anx1(I,I) = -1;
    bnx1(I) = -1;
end
if ~problem.samex 
    Anx2 = zeros(nx2,nx+ny);
    for I=1:nx2
        Anx2(I,I) = -1;
        bnx2(I) = -1;
    end
end
for I=1:ny
    Any1(I,nx+I) = -1;
    bny1(I) = -1;
end

if problem.samex
Aq = [Ac1;Ac2;Anx1;Any1];
bq = [bc1;bc2;bnx1;bny1];
else
Aq = [Ac1;Ac2;Anx1;Anx2;Any1];
bq = [bc1;bc2;bnx1;bnx2;bny1];
end

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
