function p = create(op,l1,l2,lz,name,K)

if nargin < 6
    K=1;
end

if nargin < 5
    name='';
end

if nargin < 3
    l2 = [];
end
if nargin < 4
    lz = [];%any
end
if isempty(l2)
    l2 = l1;
end
l2=l2(:);
l1=l1(:);
lz=lz(:);
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
            ps = opomg.create(op,al1,al2,lz,ename,1);
            p=[p;ps];
        end
    end
    return;
end

p = [];
p.l1 = l1;
p.l2 = l2;
p.lz =lz;
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
t = real(t); 
if isempty(lz) == 0
    tw = t(:);
    idzero = find(lz==0,1,'first');        
    [reo,ui,uii] = unique(tw);
    if isempty(idzero) == 0
        lzz = lz(lz ~= 0);
        lzi = setdiff(1:length(lz),idzero(1));
    else
        lzz = lz;
        lzi = 1:length(lz);
    end
    reo_to_z= zeros(length(reo),1);
    for I=1:length(reo)
        if isempty(idzero) == 0% has zero
            if reo(I) == 0 
                reo_to_z(I) = idzero(1);
            else
                [~,zi]=min(abs(reo(I)-lzz)); % nearest except zero
                reo_to_z(I) = lzi(zi);       % new indixex in lz
            end
        else            
            [~,zi]=min(abs(reo(I)-lz));
            reo_to_z(I) = zi;       % new indixex in lz
        end
    end
    % then map every 
    tw = reo_to_z(uii); % original index to new index in lz
    t = reshape(tw,size(t));
end
p.t = t;
p.name = op;
p.ename=name;
p.commutative=commutative;



