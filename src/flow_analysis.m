close all
clear
clc

addpath('functions')
%% Nonlynear system simulation
% parameters
a = 1;            
b = 3;
c = 1;
d = 5;
s = 4;
x_r = -8/5;
r = 0.003;
I_1 = 1.26; %1.277; %1.275737; %1.259784;
I_2 = 1.277;
I_3 = 1.277;
I_4 = 1.302;
I_5 = 1.31;
I_6 = 1.306;

I_vect = [I_1, I_2, I_3, I_4, I_5, I_6];
regime_names = {'I_1_26_global_focus','I_1_277_cycle', 'I_1_277_stable_focus', ...
    'I_1_302_fold_cycle', 'I_1_306_saddle_focus', 'I_1_305_fold_cycle'};

% initial conditions
x_0_generic = [0.1; 0.1; 0.1];
% near eq conditions
epsilon = 1e-3*ones(3, 1);
x_0_near_eq = zeros(3, length(I_vect));

for i=1:length(I_vect)
    x_0_near_eq(:, i) = hr_equilibria(a, b, c, d, s, x_r, I_vect(i)) + epsilon;
end

x_0_vect = [x_0_generic, x_0_generic, x_0_near_eq(:, 3), x_0_generic, ...
    x_0_near_eq(:, 5) , x_0_generic];

% integration
t0 = 0;
tf = 5000;
t_tr = 2000; % steady state time 

for i=1:length(I_vect)
    fun = @(t, x)hr_dynamics(x, I_vect(i), a, b, c, d, r, s, x_r);
    options = odeset('RelTol', 1e-10, 'AbsTol', 1e-12); % Reducing tollerances
    [t, x] = ode45(fun, [t0 tf], x_0_vect(:,i), options);
    % Find Equilibria
    eq = hr_equilibria(a, b, c, d, s, x_r, I_vect(i));

    % find where to truncate the solution
    index = find(t >= t_tr); 
    
    % plots (follwing
    % https://it.mathworks.com/help/matlab/ref/tiledlayout.html)
    fig1 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
        'centimeters', 'Position', [2, 2, 20, 11], 'Color', 'w');
    lay1 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','compact');
    % plot of x
    nexttile    % usig it instead of subplot to better aesthetics
    plot(t(index), x(index, 1), 'Color', '#0072BD', 'LineWidth', 1.3)
    title('Membrane Potential $x_1(t)$', 'Interpreter', 'latex')
    xlabel('$t$', 'Interpreter', 'latex')
    ylabel('$x_1$', 'Interpreter', 'latex')
    grid on
    % plot of y
    nexttile
    plot(t(index), x(index, 2), 'Color', '#D95319', 'LineWidth', 1.3)
    title('Recovery Variable $x_2(t)$', 'Interpreter', 'latex')
    xlabel('$t$', 'interpreter', 'latex')
    ylabel('$x_2$', 'interpreter', 'latex')
    grid on
    % plot of z
    nexttile
    plot(t(index), x(index, 3), 'Color', '#77AC30', 'LineWidth', 1.3)
    title('Slow Current $x_3(t)$', 'Interpreter', 'latex')
    xlabel('$t$', 'interpreter', 'latex')
    ylabel('$x_3$', 'interpreter', 'latex')
    grid on
    % Global formatting options
    set(findall(fig1, '-property', 'Fontsize'), 'Fontsize', 11);
    set(findall(fig1, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');
    
    % Phase Space Plots
    fig2 = figure('Name','Phase Space Analysis', 'Color', 'w', 'Units', ...
        'centimeters', 'Position', [5, 5, 24, 10], 'Color', 'w');
    lay2 = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding','loose');
    % 3D plot
    ax1 = nexttile;
    plot3(x(index, 1), x(index, 2), x(index, 3), 'LineWidth', 1.2,'Color',[0, 0.3, 0.6], ...
        'HandleVisibility','off');
    title('Phase Space Plot', 'Interpreter','latex')
    xlabel('$x_1$', 'Interpreter', 'latex')
    ylabel('$x_2$', 'Interpreter', 'latex')
    zlabel('$x_3$', 'Interpreter', 'latex')
    grid on; view(45, 20);
    hold on;
    % initial point
    scatter3(x(index(1), 1), x(index(1), 2), x(index(1), 3), 20, ...
        'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', '#006B3D', ...
        'DisplayName','Initial point')
    % final point
    scatter3(x(index(end), 1), x(index(end), 2), x(index(end), 3),20, ...
        'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', '#DC143C', ...
        'DisplayName','Final point')
    % equilibria plot, if i want to understand the homoclinic
    scatter3(eq(1, 1), eq(2, 1), eq(3, 1),20, ...
        'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', '#E6E22E', ...
        'DisplayName','Equilibrium')
    % add arrow direction
    % d_start = hr_dynamics(x(index(1), :), I, a, b, c, d, r, s, x_r);
    % quiver3(x(index(1), 1), x(index(1), 2), x(index(1), 3), ...
    %         d_start(1), d_start(2), d_start(3), 0.5, ...
    %         'Color', 'b', 'LineWidth', 1.2, 'MaxHeadSize', 10);
    % 2D projection on x-y
    ax2 = nexttile;
    plot(x(index, 1), x(index, 2), 'LineWidth', 1,'Color',[0.7 0 0])
    title('$x_1-x_2$ Projection', 'Interpreter', 'latex')
    xlabel('$x_1$', 'Interpreter', 'latex')
    ylabel('$x_2$', 'Interpreter', 'latex')
    grid on;
    % 2D projection on x-z 
    ax3 = nexttile;
    plot(x(index, 1), x(index, 3), 'LineWidth', 1,'Color',[0.7 0 0])
    title('$x_1-x_3$ Projection', 'Interpreter', 'latex')
    xlabel('$x_1$', 'Interpreter', 'latex')
    ylabel('$x_3$', 'Interpreter', 'latex')
    grid on; 
    lgd = legend(ax1,'Interpreter','latex');
    lgd.Location = 'southeast';
    % Global formatting
    set(findall(fig2, '-property', 'Fontsize'), 'Fontsize', 11);
    set(findall(fig2, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');
    
    allLines = findall(fig2, 'Type', 'Line');
    set(allLines, 'LineWidth', 0.6);
    set(fig1, 'Renderer', 'Painters');
    set(fig2, 'Renderer', 'Painters');
    exportgraphics(fig1, sprintf('figures/hr_time_series_%s.pdf', regime_names{i}), ...
        'ContentType', 'vector');
    exportgraphics(fig2, sprintf('figures/hr_phase_space_%s.pdf', regime_names{i}), ...
        'ContentType', 'vector');
end
