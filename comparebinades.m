
[r4,c40] = countbinades(positlist(4,0));
[r8,c80] = countbinades(positlist(8,0));
[r81,c81] = countbinades(positlist(8,1));
[r82,c82] = countbinades(positlist(8,2));
[r9,c90] = countbinades(positlist(9,0));
[rb8,cb8] = countbinades(bfloat8);

r4
r8
r81
r82
r9
rb8


%%
p82=positlist(8,2);
p82b0=p82(p82>=1 &p82<2);