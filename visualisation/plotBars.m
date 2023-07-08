function plotBars(vals,lx,ly)


% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create surface
bar3(axes1,vals);
xticks(1:1:size(lx,2));
xticklabels(lx);
xlabel("Lx",'Interpreter','latex')
ylabel("Ly",'Interpreter','latex')
zlabel("Lz=Lx+Ly",'Interpreter','latex')
yticks(1:1:size(ly,2));
yticklabels(ly)

view(axes1,[-150.682191017399 24.1372231283419]);
grid(axes1,'on');
axis(axes1,'ij');
hold(axes1,'off');
% Set the remaining axes properties
set(axes1,'PlotBoxAspectRatio',[1.37532889043741 1.61803398874989 1]);
