rm = opomg.loadsolution('result_posit80_mul.json');
rd = opomg.loadsolution('result_posit80_div.json');
vm = opomg.verify(rm);
vd = opomg.verify(rd);

%%
plot([rm.Lx1,rd.Lx1,rd.Lx2]);
legend({'mul(x=y)','div(x)','div(y)'});
ylabel('Lx*');
%%
plot([rd.Lx1-rm.Lx1,rd.Lx2-rm.Lx1]);
legend({'div(x)-mul(x)','div(y)-mul(x)'});
ylabel('Lz');

%%
plot(rm.Ly);
hold on
plot(rd.Ly);
hold off
ylabel('Lz');
legend({'mul(z)','div(z)'});

