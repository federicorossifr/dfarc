

fp8_e4m3=generate_fp(4,3);
fp8_e5m2=generate_fp(5,2);
[fp8_e4int,fp8_e4int_FT]=generate_fp(4,3,-2);
bfloat16=generate_fp(8,7);
binary16=generate_fp(5,10);


uu_e4m3 = length(unique(fp8_e4m3))
uu_e5m2 = length(unique(fp8_e5m2))

