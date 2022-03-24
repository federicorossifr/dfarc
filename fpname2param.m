function [E,M,bias] = fpname2param(name)

bias=[]; % (2^(E-1)-1)
switch name
    case 'fp8_e5'
        E=5;
        M=2;
    case 'fp8_e4'
        E=4;
        M=3;
    case 'fp8_e4i'
        % e.g. https://en.wikipedia.org/wiki/Minifloat
        E=4;
        M=3;
        bias=-2; % only for integers
    case 'bfloa16'
        E=8;
        M=7;
    case 'binary16'
        E=5;
        M=10;
    case 'binary32'
        E=8;
        M=23;
end
