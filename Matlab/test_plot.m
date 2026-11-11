f = uifigure;

g = uigridlayout(f,[3 1]);

g.RowHeight = {'2x','1x','1x'};

ax = uiaxes(g);
ax.Layout.Row = [1 2];

plot(ax, peaks);
title('UQAM_1 2026')

txt = uitextarea(g);
txt.Layout.Row = 3;
txt.Value = {'Analysis results go here'};

