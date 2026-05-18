clc
close all
clearvars

addpath('functions')
% Run the init script
run('params.m');

% put the choice;
choice = 0;
uncertainty = 0;
regulation = 0;
if regulation == 1
    T = T_reg;
else 
    T = T_track;
    I = 0;
    x_0 = hr_equilibria(a,b,c,d,s,x_r,I);
    I_eq = 1.28;
    % Regulation eq
    eq = hr_equilibria(a,b,c,d,s,x_r,I_eq);
    x_eq = eq(1,1);
end

%% FBL
% Run the IO FBL control
fbl_out = sim("hr_io_feedback_linearization.slx");

% extract signals from simulation
r_fbl = fbl_out.r;
e_fbl = fbl_out.e;
u_fbl = fbl_out.u;
x_1_fbl = fbl_out.x_1;
x_2_fbl = fbl_out.x_2;
x_3_fbl = fbl_out.x_3;

% tracking metrics
[rmse_fbl, max_e_fbl, u_max_fbl, ...
    c_energy_fbl] = compute_metrics(x_1_fbl, r_fbl, u_fbl);

fprintf('\n=== FBL Performance Metrics ===\n');
fprintf('RMSE: %.6f\n', rmse_fbl);
fprintf('Max Tracking Error: %.6f\n', max_e_fbl);

%% Plots
% Plot reference vs output (x)
fig5 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
hold on;
plot(x_1_fbl.Time, x_1_fbl.Data, '-', 'Color', '#0072BD', 'LineWidth', 2, ...
    'DisplayName', '$x_1(t)$')
plot(r_fbl.Time, r_fbl.Data, '--', 'Color', '#7F8C8D', 'LineWidth', 2, ...
    'DisplayName', 'reference')
title('Reference vs $x_1(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
grid on;

% Plot states
fig6 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
lay6 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','loose');
% x plot
nexttile;
plot(x_1_fbl.Time, x_1_fbl.Data, 'Color', '#0072BD', 'LineWidth', 2, ...
    'DisplayName','membrane potential $x_1(t)$')
title('$x_1(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% y plot
nexttile;
plot(x_2_fbl.Time, x_2_fbl.Data, 'Color', '#D95319', 'LineWidth', 2, ...
    'DisplayName','fast variable $x_2(t)$')
title('$x_2(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_2(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% z plot
nexttile;
plot(x_3_fbl.Time, x_3_fbl.Data, 'Color', '#77AC30', 'LineWidth', 2, ...
    'DisplayName','slow variable $x_3(t)$')
title('$x_3(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_3(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;

% plot input
fig7 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(u_fbl.Time, u_fbl.Data, 'Color', '#8E44AD', 'LineWidth', 2, ...
    'DisplayName', 'input $u(t)$')
title('Control Input $u(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$u(t)$', 'Interpreter', 'latex')
legend('Location', 'southeast', 'Interpreter','latex')
grid on;

% plot error
fig8 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(e_fbl.Time, e_fbl.Data, 'Color', '#E91E63', 'LineWidth', 2, ...
    'DisplayName', 'error $e(t)$')
title('Error $e(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$e(t)$', 'Interpreter', 'latex')
legend('Location', 'southeast', 'Interpreter','latex')
grid on;

% export figures
exportgraphics(fig5, 'figures/fbl_ref_vs_x_track.pdf', 'ContentType','vector');
exportgraphics(fig6, 'figures/fbl_time_series_track.pdf', 'ContentType','vector');
exportgraphics(fig7, 'figures/fbl_control_input_track.pdf', 'ContentType','vector');
exportgraphics(fig8, 'figures/fbl_error_track.pdf', 'ContentType','vector');

%% SMC
% continue with the SMC
sim_smc = sim('hr_sliding_mode_control.slx');

% extract signal from simulink
x_1_smc = sim_smc.x_1;
x_2_smc = sim_smc.x_2;
x_3_smc = sim_smc.x_3;
sigma = sim_smc.sigma;
e_smc = sim_smc.e;
u_smc = sim_smc.u;
r_smc = sim_smc.r;

% tracking metrics
[rmse_smc, max_e_smc, u_max_smc, ...
    c_energy_smc] = compute_metrics(x_1_smc, r_smc, u_smc);

fprintf('\n=== FBL Performance Metrics ===\n');
fprintf('RMSE: %.15f\n', rmse_smc);
fprintf('Max Tracking Error: %.6f\n', max_e_smc);

%% plots
% Plot reference vs output (x)
fig9 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
hold on;
plot(x_1_smc.Time, x_1_smc.Data, '-', 'Color', '#0072BD', 'LineWidth', 2,...
    'DisplayName', '$x_1(t)$')
plot(r_smc.Time, r_smc.Data, '--', 'Color', '#7F8C8D', 'LineWidth', 2,...
    'DisplayName', 'reference')
title('Reference vs $x_1(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1$', 'Interpreter', 'latex')
legend('Location','northeast', 'Interpreter', 'latex')
grid on;

% Plot states
fig10 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
lay10 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','loose');
% x plot
ax1 = nexttile;
plot(x_1_smc.Time, x_1_smc.Data, 'Color', '#0072BD', 'LineWidth', 2, ...
    'DisplayName', 'membrane potential $x_1(t)$')
title('$x_1(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% y plot
ax2 = nexttile;
plot(x_2_smc.Time, x_2_smc.Data, 'Color', '#D95319', 'LineWidth', 2, ...
    'DisplayName', 'fast variable $x_2(t)$')
title('$x_2(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_2$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% z plot
ax3 = nexttile;
plot(x_3_smc.Time, x_3_smc.Data, 'Color', '#77AC30', 'LineWidth', 2, ...
    'DisplayName', 'slow variable $x_3(t)$')
title('$x_3(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_3$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;

% plot input
fig11 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(u_smc.Time, u_smc.Data, 'Color', '#8E44AD', 'LineWidth', 2, ...
    'DisplayName', 'input $u(t)$')
title('Control Input $u(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$u$', 'Interpreter', 'latex')
legend('Location','southeast', 'Interpreter', 'latex')
grid on;

% plot error
fig12 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(e_smc.Time, e_smc.Data, 'Color', '#E91E63', 'LineWidth', 2, ...
    'DisplayName', 'error $e(t)$')
title('Error $e(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$e$', 'Interpreter', 'latex')
legend('Location','southeast', 'Interpreter', 'latex')
grid on;

% plot sigma
fig13 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(sigma.Time, sigma.Data, 'Color', '#D4AF37', 'LineWidth', 2, ...
    'DisplayName', 'Sigma $\sigma(t)$')
title('Sigma $\sigma(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$\sigma$', 'Interpreter', 'latex')
legend('Location','southeast', 'Interpreter', 'latex')
grid on;

% export figures
exportgraphics(fig9, 'figures/smc_ref_vs_x_track.pdf', 'ContentType','vector');
exportgraphics(fig10, 'figures/smc_time_series_track.pdf', 'ContentType','vector');
exportgraphics(fig11, 'figures/smc_control_input_track.pdf', 'ContentType','vector');
exportgraphics(fig12, 'figures/smc_error_track.pdf', 'ContentType','vector');
exportgraphics(fig13, 'figures/smc_sigma_track.pdf', 'ContentType','vector');

function [rmse, max_error, max_u, control_energy] = compute_metrics(x_data, ...
    r_data, u_data)

    idx = x_data.Time >= 500;

    error = x_data.Data(idx) - r_data.Data(idx);
    abs_error = abs(error);
    rmse = sqrt(mean(error.^2));
    max_error = max(abs_error);

    % Max control effort
    max_u = max(abs(u_data.Data(idx)));

    % Control energy
    control_energy = trapz(u_data.Time, u_data.Data.^2);
end