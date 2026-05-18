close all
clear
clc

addpath('functions')
%% initial conditions
x_0 = [0.1; 0.1; 0.1];

% parameters
a = 1;            
b = 3;
c = 1;
d = 5;
s = 4;
x_r = -8/5;
r = 0.003;

% integration
t0 = 0;
tf = 5000;

t_tr = 2000; % steady state time 

%% Bifurcation analisys with poincarè maps
I = linspace(1, 4, 1000);

y_crossing = cell(length(I), 1);
options = odeset('RelTol', 1e-7, 'AbsTol', 1e-9);

% iterate fixing every value of I
for i = 1:length(I)
    
    % simulate 
    fun = @(t, x)hr_dynamics(x, I(i), a, b, c, d, r, s, x_r);
    
    [t, x_sol] = ode15s(fun, [t0 tf], x_0, options);

    % Continuation (faster updates)
    x_0 = x_sol(end, :);

    % truncate solution
    idx_steady = find(t >= t_tr);
    t_s = t(idx_steady);
    x_s = x_sol(idx_steady, :);

    % find indices before crossing from poistive to negative values
    idx_cross = find(x_s(1:end-1, 1) > 0 & x_s(2:end, 1) <= 0);

    % Using linear interpolation to have more precision
    y_interp = zeros(length(idx_cross), 1);
    for k = 1:length(idx_cross)
        % Creating the line interpolations
        x_start = x_s(idx_cross(k), 1);
        x_end = x_s(idx_cross(k)+1, 1);
        y_start = x_s(idx_cross(k), 2);
        y_end = x_s(idx_cross(k)+1, 2);

        % linear interpolation formula
        y_interp(k) = y_start - x_start * (y_end - y_start)/(x_end - x_start);
    end

    % save results
    y_crossing{i} = y_interp;
    
end

% plots
fig1 = figure('Name','Poincaré Bifurcation', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 18, 10], 'Color', 'w');
hold on; grid on;
% Loop trough cells to make the plot
for i = 1 : length(I)
    if ~isempty(y_crossing{i})
        plot(I(i)*ones(size(y_crossing{i})), y_crossing{i}, 'k.', 'MarkerSize', 1.0)
    end
end
title('Bifurcation Diagram $x_2$ vs $I$', 'Interpreter','latex')
xlabel('External current $I$', 'interpreter', 'latex')
ylabel('Recovery variable $x_2$ (with $x_1=0$)', 'interpreter', 'latex')

% Globaòl options
set(findall(fig1, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig1, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

exportgraphics(fig1, 'figures/bifurcation_poincare.png', 'Resolution', 600);
exportgraphics(fig1, 'figures/bifurcation_poincare.pdf', 'ContentType', 'vector');

%% Bifurcation analisys with poincarè maps
I = linspace(1, 4, 1000);

x_crossing = cell(length(I), 1);
options = odeset('RelTol', 1e-7, 'AbsTol', 1e-9);

% iterate fixing every value of I
for i = 1:length(I)
    
    % simulate 
    fun = @(t, x)hr_dynamics(x, I(i), a, b, c, d, r, s, x_r);
    
    [t, x_sol] = ode15s(fun, [t0 tf], x_0, options);

    % Continuation (faster updates)
    x_0 = x_sol(end, :);

    % truncate solution
    idx_steady = find(t >= t_tr);
    t_s = t(idx_steady);
    x_s = x_sol(idx_steady, :);

    % find indices before crossing from poistive to negative values
    idx_cross = find(x_s(1:end-1, 2) > 0 & x_s(2:end, 2) <= 0);

    % Using linear interpolation to have more precision
    x_interp = zeros(length(idx_cross), 1);
    for k = 1:length(idx_cross)
        % Creating the line interpolations
        x_start = x_s(idx_cross(k), 1);
        x_end = x_s(idx_cross(k)+1, 1);
        y_start = x_s(idx_cross(k), 2);
        y_end = x_s(idx_cross(k)+1, 2);

        % linear interpolation formula
        x_interp(k) = x_start - y_start * (x_end - x_start)/(y_end - y_start);
    end

    % save results
    x_crossing{i} = x_interp;
    
end

% plots
fig3 = figure('Name','Poincaré Bifurcation', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 18, 10], 'Color', 'w');
hold on; grid on;
% Loop trough cells to make the plot
for i = 1 : length(I)
    if ~isempty(x_crossing{i})
        plot(I(i)*ones(size(x_crossing{i})), x_crossing{i}, 'k.', 'MarkerSize', 1.0)
    end
end
title('Bifurcation Diagram $x_1$ vs $I$', 'Interpreter','latex')
xlabel('External current $I$', 'interpreter', 'latex')
ylabel('Recovery variable $x_1$ (with $x_2=0$)', 'interpreter', 'latex')

% Globaòl options
set(findall(fig3, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig3, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

exportgraphics(fig3, 'figures/bifurcation_poincare_x.png', 'Resolution', 600);
exportgraphics(fig3, 'figures/bifurcation_poincare_x.pdf', 'ContentType', 'vector');

%% Bifurcation analysis with ISI
I = linspace(1.2, 3.5, 1000);

isi = cell(length(I), 1);
options = odeset('RelTol', 1e-7, 'AbsTol', 1e-9);

% iterate fixing every value of I
for i = 1:length(I)
    
    % simulate 
    fun = @(t, x)hr_dynamics(x, I(i), a, b, c, d, r, s, x_r);
    tspan = t0 : 0.1 : tf;
    [t, x_sol] = ode45(fun, tspan, x_0, options);

    if I(i) > 1.4
        % Continuation (faster updates)
        x_0 = x_sol(end, :);
    else
        x_0 = [0.1; 0.1; 0.1];
    end

    % truncate solution
    idx_steady = find(t >= t_tr);
    t_s = t(idx_steady);
    x_s = x_sol(idx_steady, 1);

    % find indices of x considering two consecutive zeros
    dx = diff(x_s);
    idx = find(dx(1:end-1) > 0 & dx(2:end) <= 0);

    % Keep only local maxima above zeros
    idx = idx(x_s(idx) > 0);
    % Using linear interpolation to have more precision
    t_spikes = zeros(length(idx), 1);
    for k = 1:length(idx)
        % Creating the line interpolations
        x_start = dx(idx(k));
        x_end = dx(idx(k)+1);
        t_start = t_s(idx(k));
        t_end = t_s(idx(k)+1);

        % linear interpolation formula
        t_spikes(k) = t_start - x_start * (t_end - t_start)/(x_end - x_start);
    end
    
    if length(idx) > 2
        % save results
        isi{i} = diff(t_spikes);
    else
        isi{i} = [];
    end

end

% plots
fig2 = figure('Name','ISI Bifurcation', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 18, 10], 'Color', 'w');
hold on; grid on;
% Loop trough cells to make the plot
for i = 1 : length(I)
    if ~isempty(isi{i})
        plot(I(i)*ones(size(isi{i})), isi{i}, 'k.', 'MarkerSize', 1.0)
    end
end
title('Bifurcation Diagram $I$ vs ISI', 'Interpreter','latex')
xlabel('External current $I$', 'interpreter', 'latex')
ylabel('Inter-Spike Interval (ISI)', 'interpreter', 'latex')

% Globaòl options
set(gca, 'YScale', 'log');
set(findall(fig2, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig2, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

exportgraphics(fig2, 'figures/bifurcation_isi.png', 'Resolution', 600);
exportgraphics(fig2, 'figures/bifurcation_isi.pdf', 'ContentType', 'vector');