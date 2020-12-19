
%%
n=8;
l = positlist(n,0);
op='/'; % not yet
op='/'; % 
op='/'; % 105c for posit4
op='+'; % 
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

problem = [];
problem.ny = ny;
problem.nx = length(l);
problem.op = op;
%problem.A = A; % too big and not needed
%problem.zero = zz; % index of null
problem.p = p; % shorter
problem.b= b;
problem.x = x;
problem.y = y;
problem.name = sprintf('posit%d,0 %s',n,op);


f = fopen('problem.json','w');
fwrite(f,jsonencode(problem));
fclose(f);
%%
problem
%%
%TODO
% verify solution file