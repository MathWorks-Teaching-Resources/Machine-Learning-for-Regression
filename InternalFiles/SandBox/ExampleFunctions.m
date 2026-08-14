
% Function to make example datasets for decision trees


% Draw a 2x2 tiled layout showing example patterns
DefaultStyle = InitializeDefaultStyle();
fig = figure;
ApplyFullscreenFigure(fig)
tiledlayout(fig,2,2,Padding="compact",TileSpacing="compact")

rng shuffle
% Mostly linear trend
ax1 = nexttile;
X = linspace(-10,10,100)';
Y = 3*X + 5 + randn(size(X))*5;
scatter(ax1,X,Y,12,"filled",MarkerFaceAlpha=0.7)
title(ax1,"Mostly Linear Trend")
xlabel(ax1,"x")
ylabel(ax1,"y")
grid(ax1,"on")
box(ax1,"on")
ApplyDefaultAxesStyle(ax1,DefaultStyle)

% Smooth global nonlinear pattern (parabola)
ax2 = nexttile;
X = linspace(-10,10,200)';
Y = 0.5*X.^2 - 2*X + 3 + randn(size(X))*8;
scatter(ax2,X,Y,12,"filled",MarkerFaceAlpha=0.7)
title(ax2,"Smooth Global Nonlinear Pattern")
xlabel(ax2,"X")
ylabel(ax2,"Y")
grid(ax2,"on")
box(ax2,"on")
ApplyDefaultAxesStyle(ax2,DefaultStyle)

% Thresholds / segmented regions
ax3 = nexttile;
X = rand(200,1)*10;
Y = 10 + 6*(X>4) - 3*(X>7) + randn(200,1)*1.5;
scatter(ax3,X,Y,12,"filled",MarkerFaceAlpha=0.7)
title(ax3,"Thresholds / Segmented Regions")
xlabel(ax3,"x")
ylabel(ax3,"y")
grid(ax3,"on")
box(ax3,"on")
ApplyDefaultAxesStyle(ax3,DefaultStyle)

% Complex nonlinear patterns with noise (periodic + trend)
ax4 = nexttile;
X = linspace(0,24,300)';
Y = 50 + 10*sin(X/24*4*pi) + 0.8*X + randn(size(X))*6;
scatter(ax4,X,Y,12,"filled",MarkerFaceAlpha=0.7)
title(ax4,"Complex Nonlinear Pattern with Noise")
xlabel(ax4,"x (time)")
ylabel(ax4,"y")
grid(ax4,"on")
box(ax4,"on")
ApplyDefaultAxesStyle(ax4,DefaultStyle)