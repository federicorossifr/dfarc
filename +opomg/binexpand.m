function s = square(s,up)
%
% TODO:makecorrexb binadee check
% TODO:optimize Ly skipping previous part

if nargin == 1
    up = 1;
end
fx = @(x,y) x.*y;

z = floor(log2(s.x1));
du = find(diff(z)>0);
if isempty(du)
    a1=[1,length(s.x1)];
    a1d=a1;
else
    a1=[du(end)+1,length(s.x1)];
    a1d= [1,du(1)];
end
if isfield(s,'Lx2')
    z = floor(log2(s.x2));
    du = find(diff(z)>0);
    if isempty(du)
        a2=[1,length(s.x2)];
        a2d=a2;
    else
        a2=[du(end)+1,length(s.x2)];        
        a2d =[1,du(1)];
    end

else
    a2=[];
end
on1 = length(s.Lx1);
if up ==1
    s.Lx1 = [s.Lx1; s.Lx1(end)+s.Lx1(a1(1):a1(2))]; % if s.Lx1==0 then one less
    s.x1 = [s.x1; 2*s.x1(a1(1):a1(2))];  % if s.x1==2 then one less
else
        dx1d = s.Lx1(a1d(end));
    s.Lx1 = [s.Lx1(a1d(1):a1d(2))+dx1d;s.Lx1 ]; % if s.Lx1==0 then one less
    s.x1 = [s.x1(a1d(1):a1d(2))/2;s.x1];  % if s.x1==2 then one less
end

s.nx1 = length(s.x1);
Lx1=s.Lx1;
x1=s.x1;

if isfield(s,'Lx2')
    
    if up ==1
        s.Lx2 = [s.Lx2; s.Lx2(a2(1):a2(2))+s.Lx1(end)];
        s.x2 = [s.x2; 2*s.x2(a2(1):a2(2))];
    else
        dx2d = s.Lx2(a2d(end));
        s.Lx2 = [s.Lx2(a2d(1):a2d(2))+dx2d; s.Lx2];
        s.x2 = [s.x2(a2d(1):a2d(2))/2; s.x2];
    end
    s.nx2 = length(unique(s.x2));    
    Lx2=s.Lx2;
    t = bsxfun(fx,s.x1,s.x2');
    x2=s.x2;
    on2 = length(s.Lx2);

else
    Lx2=s.Lx1;
    t = bsxfun(fx,s.x1,s.x1');
    x2=s.x1;
    on2 = length(s.Lx1);

end

[y,ityu,ity] = unique(t); % totals, andt the map from every matrix element to eacy y
% ityu points to first (#y=#ityu)
% ity  points to each  (#t=#ity)

fullv=0;
if fullv
    % build constraints using the
    c = ceil(length(x1)*(length(x2)+1)/2); % max due to symmetry
    %A=zeros(c,ny);
    p=zeros(c,2); % index pairs due to binop, also for a op a
    b=zeros(c,1);
    q=0;
    
    for I=1:length(l1)
        J0=I; % symmetry
        for J=J0:length(l2)
            k = sub2ind(size(t),I,J); % index in table t of product and of mapping
            q = q + 1;
            p(q,:)= [I,J]; % also for combinations in Lx
            b(q) = ity(k); % in y
            assert(x1(I)*x2(J) == y(ity(k)))
        end
    end
    p =p(1:q,:);
    b=b(1:q,:);
end

if fullv
    % Ly
    c=length(ityu);
    Ly = zeros(c,1);
    for k=1:c
        ti = ityu(k);
        [I,J]=ind2sub(size(t),ti);
        Ly(k) = Lx1(I)+Lx2(J);
    end
else
    % Ly or also p,b
    c=length(ityu);
    Ly = zeros(c,1);
    p=zeros(c,2); % index pairs due to binop, also for a op a
    b=zeros(c,1);
    for k=1:c
        ti = ityu(k);
        [I,J]=ind2sub(size(t),ti);
        p(k,:) = [I,J];
        b(k) = k;
        Ly(k) = Lx1(I)+Lx2(J);
    end
end

s.b = b;
s.p = p;
s.y = y;
s.Ly =Ly;
s.ny = length(s.y);
