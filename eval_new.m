%[a,b]   = genSolution(4,0,@plus)
%[a1,b1] = genSolution(4,0,@times)
%[a2,b2] = genSolution(6,0,@plus,false)
%[a3,b4] = genSolution(6,2,@times)

%genSolution(8,0,@times,true)


%[divs,divp] = genSolution(4,0,@rdivide);
[divs,divp] = genSolution(6,2,@rdivide);

sym = checkAntiSymmetry(divp.cloptab);



function diffs = checkAntiSymmetry(tab)
    [r,c] = size(tab);
    diffs = zeros(r,c);
    for i=1:r
        for j=1:c
            ii = c-j+1;
            jj = r-i+1;
            diffs(i,j) = (tab(i,j) ~= tab(ii,jj));
            if (tab(i,j) ~= tab(ii,jj))
                fprintf("(%d,%d) diff from (%d,%d), %f != %f\n",i,j,ii,jj,tab(i,j),tab(ii,jj));
            end
        end
    end

end
