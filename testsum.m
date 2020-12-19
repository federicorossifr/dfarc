
%%
n=8;
l = positlist(n,0);
op='+'; % 105c for posit4
op='*'; % 

if op =='+'
    % all numbers
l = [-l; 0; l];
t = bsxfun(@(x,y) x+y,l,l');
else
    % obly positive > 1
t = bsxfun(@(x,y) x*y,l,l');
end
[x,~,itx] = unique(l);
[y,~,it] = unique(t); % totals, and the map from every matrix element to eacy y
assert(all(diff(y)) > 0); % ordered
ny = length(y);

xb = itx;
yb = zeros(length(l),1); % maps of xa to Ya
for I=1:length(l)
    yb(I) = find(y == l(I));
end
assert(all(y(yb)==l))



% build constraints using the
c = length(l)*(length(l)+1)/2; % max due to symmetry
A=zeros(c,ny);
p=zeros(c,2); % index pairs due to binop, also for a op a
b=zeros(c,1);
% half of them!
q=0;
for I=1:length(l)
    for J=I:length(l)
        k = sub2ind(size(t),I,J); % index in table t of product and of mapping
        q = q + 1;
        if xb(I) == xb(J)
            if y(it(k)) == x(xb(I))
                % skip null op
                % 1*1 = 1 shall not be ha
                % 0+0 = 0 shall not count
                %q = q - 1;
                %continue
            end
            % a+a = 2a
            % a*a = a^2 
            A(q,xb(I)) = 2;
        else
            % La+Lnull=La because they are all positive...
            if x(xb(I)) == y(it(k)) || x(xb(J)) == y(it(k))
                % skip null op
                %q = q-1;
                %continue
            end
            A(q,xb(I)) = 1;
            A(q,xb(J)) = 1;
        end
        p(q,:)= [xb(I),xb(J)]; % also for combinations
        b(q) = it(k);
        % find L(yb(I))+L(yb(J)) == L(it(k))
        if op=='+'
            assert(x(xb(I))+x(xb(J)) == y(it(k)))
        else
            assert(x(xb(I))*x(xb(J)) == y(it(k)))
        end
        % yb(I) L1 + yb(J) L2 = it(k) Lx 
        %
        % assert  A(k,:)*L = b(k)  so that   
        %   yb(I) + yb(H) = it(k)
        %   y(yb(I))+y(yb(J))=y(it(k))
        % where L is integer
    end
end
A = A(1:q,:);
b = b(1:q,:);
p = p(1:q,:);
assert(all(sum(A,2) ==2))

problem = [];
problem.ny = ny;
problem.nx = length(l);
%problem.A = A; % too big and not needed
%problem.zero = zz; % index of null
problem.p = p; % shorter
problem.b=b;
problem.name = sprintf('posit%d,0 %s',n,op);


f = fopen('problem.json','w');
fwrite(f,jsonencode(problem));
fclose(f);

%%
y
p
b
% 0.5 1 2
% #2*#2=#1  0.5*0.5=0.25
% #2*#4=#3    0.5*2 = 1
% #4*#4=#¥      2*2=4
%
% what about identities?
%
% we have also 1+1=2
%
% problem
%   L2+L2=L1
%   L2+L4=L3
%   L4+L4=L5
%   