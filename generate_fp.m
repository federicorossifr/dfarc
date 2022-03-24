function [w,ftype] = generate_fp(E,M,ebias)
%
% generate positive fp values with given Exponent Mantissa bits 
%
% If bias is not provided uses the IEEE rule (2^(E-1)-1)
%
% ftype is 1=sub 2=infinity_nan 3=regular
if nargin == 2 || isempty(ebias)
    ebias = 2^(E-1)-1;
end
Mmask=bitshift(1,M)-1;
powve = 2.^(-(1:M));
emax=2^E-1;

N=E+M;
assert(N <= 32);
if N > 16
    d = uint32((1:(2^N-1))');
elseif N > 8    
    d = uint16((1:(2^N-1))');
else
    d = uint8((1:(2^N-1))');
end
w = zeros(length(d),1);
ee=w;
ftype=zeros(length(d),1);
for I=1:length(d)
    e = bitshift(d(I),-M);
    m = dec2bin(bitand(d(I),Mmask))-'0';
    m = [zeros(1,length(powve)-length(m)),m];
    ee(I)=e;
    if e == 0 % subnormal
        e = -double(ebias)+1;
        w(I) = 2^e*(0+sum(powve.*m));  
        ftype(I) = 1;
    else
        if e == emax % this is infintiy or nan
            ftype(I) = 2;
        else
            ftype(I) = 1;
        end
        e = double(e) - ebias;
        % 1.mmmmmm
        w(I) = 2^e*(1+sum(powve.*m));
    end
end


