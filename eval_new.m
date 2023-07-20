addpath('positlist')

%[a,b,e]   = genSolution(4,0,@plus)
%[a1,b1,e] = genSolution(4,0,@times);
%[s,p,e] = genSolution(6,2,@times,true);
%[a3,b4] = genSolution(6,2,@times)

[~,p,~] = genSolution(8,2,@times,true);
%load p8_2_times.mat
%[s,p,e] = just_solve(p);

%[divs,divp,e] = genSolution(4,0,@rdivide);
%[divs,divp] = genSolution(6,2,@rdivide);

%sym = checkAntiSymmetry(divp.cloptab);


%saveToFile("p8_0_plus_solution.json",e)

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


function saveToFile(fname,encoded)
	id = fopen(fname,'w');
	fprintf(id,'%s',encoded);
	fclose(id);
end
