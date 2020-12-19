
%%
n=4;
l = positlist(n,0);
t = bsxfun(@(x,y) x+y,l,l');
[y,~,it] = unique(t); % totals, and the map from every matrix element to eacy y
ny = length(y);

zz=find(l==0); % index of z
yb = zeros(length(l),1); % maps of xa to Ya
for I=1:length(l)
    yb(I) = it(sub2ind(size(t),I,zz)); % find index of sum of zero with l(I)
end
% assert(y(yb)==l)



%%
% build constraints using the
c = length(l)*(length(y)+1)/2;
A=zeros(c,ny);
p=zeros(c,2); % just two needed
b=zeros(c,1);
% half of them!
q=0;
for I=1:length(l)
    for J=I:length(l)
        k = sub2ind(size(t),I,J);
        q = q + 1;
        if yb(I) == yb(J)
            A(q,yb(I)) = 2;
        else
            A(q,yb(I)) = 1;
            A(q,yb(J)) = 1;
        end
        p(q,:)= [yb(I),yb(J)]; % also for combinations
        b(q) = it(k);
        % find L(yb(I))+L(yb(J)) == L(it(k))
        assert(y(yb(I))+y(yb(J)) == y(it(k)))
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
problem.A = A;
problem.p = p; % shorter
problem.b=b;

f = fopen('problem.json','w');
fwrite(f,jsonencode(problem));
fclose(f);