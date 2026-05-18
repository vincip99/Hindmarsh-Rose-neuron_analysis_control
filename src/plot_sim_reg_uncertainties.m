clc
close all
clearvars

addpath('functions')
% Run the init script
run('params.m');

% put the choice;
choice = 0;
uncertainty = 1;
regulation = 1;
if regulation == 1
    T = T_reg;
else 
    T = T_track;
end

%% PID
% Run the IO FBL control
pid_out = sim("hr_PID.slx");

% extract signals from simulation
r_pid = pid_out.r;
e_pid = pid_out.e;
u_pid = pid_out.u;
x_1_pid = pid_out.x_1;
x_2_pid = pid_out.x_2;
x_3_pid = pid_out.x_3;

% regulation metrics
[T_a2_pid, S_overshoot_pid, ss_error_pid, u_max_pid, ...
    c_energy_pid] = compute_metrics(x_1_pid, r_pid, u_pid);

fprintf('\n=== PID Performance Metrics ===\n');
fprintf('Overshoot: %.2f%%\n', S_overshoot_pid);
fprintf('Settling time (2%% band): %.4f s\n', T_a2_pid);
fprintf('Steady-state error: %.14f\n', ss_error_pid);
fprintf('Max Control effort: %.6f\n', u_max_pid);
fprintf('Control Energy: %.6f\n', c_energy_pid);
%% Plots 
% Plot reference vs output (x)
fig1 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
hold on;
plot(x_1_pid.Time, x_1_pid.Data, '-', 'Color', '#0072BD', 'LineWidth', 2, ...
    'DisplayName', '$x_1(t)$')
yline(r_pid.Data, '--', 'Color', '#7F8C8D', 'LineWidth', 2, ...
    'DisplayName', 'reference');
% xline(T_a2, '-.', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, ...
%     'DisplayName','settling time');
% hold on;
% plot(x_pid.Time(peak_idx), overshoot_peak, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, ...
%     'DisplayName','overshoot')
title('Reference vs $x_1(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
grid on;

% Plot states
fig2 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
lay2 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','loose');
% x plot
nexttile;
plot(x_1_pid.Time, x_1_pid.Data, 'Color', '#0072BD', 'LineWidth', 2, ...
    'DisplayName','membrane potential $x(t)$')
title('$x_1(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_1(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% x plot
nexttile;
plot(x_2_pid.Time, x_2_pid.Data, 'Color', '#D95319', 'LineWidth', 2, ...
    'DisplayName','fast variable $x_2(t)$')
title('$x_2(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_2(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;
% x plot
nexttile;
plot(x_3_pid.Time, x_3_pid.Data, 'Color', '#77AC30', 'LineWidth', 2, ...
    'DisplayName','slow variable $x_3(t)$')
title('$x_3(t)$ time series', 'Interpreter','latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$x_3(t)$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter','latex')
hold on; grid on;

% plot input
fig3 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(u_pid.Time, u_pid.Data, 'Color', '#8E44AD', 'LineWidth', 2, ...
    'DisplayName', 'input $u(t)$')
title('Control Input $u(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$u(t)$', 'Interpreter', 'latex')
legend('Location', 'southeast', 'Interpreter','latex')
grid on;

% plot error
fig4 = figure('Name','Time Series Analysis', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 15], 'Color', 'w');
plot(e_pid.Time, e_pid.Data, 'Color', '#E91E63', 'LineWidth', 2, ...
    'DisplayName', 'error $e(t)$')
title('error $e(t)$', 'Interpreter', 'latex')
xlabel('$t$', 'Interpreter', 'latex')
ylabel('$e(t)$', 'Interpreter', 'latex')
legend('Location', 'southeast', 'Interpreter','latex')
grid on;

% export figures
exportgraphics(fig1, 'figures/pid_ref_vs_x_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig2, 'figures/pid_time_series_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig3, 'figures/pid_control_input_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig4, 'figures/pid_error_reg_unc.pdf', 'ContentType','vector');

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

% regulation metrics
[T_a2_fbl, S_overshoot_fbl, ss_error_fbl, u_max_fbl, ...
    c_energy_fbl] = compute_metrics(x_1_fbl, r_fbl, u_fbl);

fprintf('\n=== FBL Performance Metrics ===\n');
fprintf('Overshoot: %.2f%%\n', S_overshoot_fbl);
fprintf('Settling time (2%% band): %.4f s\n', T_a2_fbl);
fprintf('Steady-state error: %.20f\n', ss_error_fbl);
fprintf('Max Control effort: %.6f\n', u_max_fbl);
fprintf('Control Energy: %.6f\n', c_energy_fbl);

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
exportgraphics(fig5, 'figures/fbl_ref_vs_x_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig6, 'figures/fbl_time_series_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig7, 'figures/fbl_control_input_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig8, 'figures/fbl_error_reg_unc.pdf', 'ContentType','vector');

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

% regulation metrics
[T_a2_smc, S_overshoot_smc, ss_error_smc, u_max_smc, ...
    c_energy_smc] = compute_metrics(x_1_smc, r_smc, u_smc);

fprintf('\n=== SMC Performance Metrics ===\n');
fprintf('Overshoot: %.2f%%\n', S_overshoot_smc);
fprintf('Settling time (2%% band): %.4f s\n', T_a2_smc);
fprintf('Steady-state error: %.20f\n', ss_error_smc);
fprintf('Max Control effort: %.6f\n', u_max_smc);
fprintf('COntrol Energy: %.6f\n', c_energy_smc);

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
exportgraphics(fig9, 'figures/smc_ref_vs_x_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig10, 'figures/smc_time_series_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig11, 'figures/smc_control_input_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig12, 'figures/smc_error_reg_unc.pdf', 'ContentType','vector');
exportgraphics(fig13, 'figures/smc_sigma_reg_unc.pdf', 'ContentType','vector');

function [T_a2, S_overshoot, ss_error, max_u, control_energy] = compute_metrics(x_data, ...
    r_data, u_data)

    % regulation metrics
    x_final = x_data.Data(end);
    x_initial = x_data.Data(1);
    step_diff = x_final - x_initial;
    step_magnitude = abs(step_diff);
    target_ref = r_data.Data(end);
    
    if step_diff < 0
        % if initial condition is > than ref value take min value as
        % overshoot
        [peak_val, ~] = min(x_data.Data); 
        overshoot_abs = abs(peak_val - x_final);
    else
        % Normal overshoot
        [peak_val, ~] = max(x_data.Data);
        overshoot_abs = abs(peak_val - x_final);
    end
    S_overshoot = overshoot_abs / abs(step_diff)*100;
    
    regulation_error = abs(x_data.Data - target_ref);
    tolerance_band = 0.02 * step_magnitude; % T_a2 settling time
    % Find indices of value outside the 2% band
    indices_beyond_tolerance = find(regulation_error > tolerance_band);
    if isempty(indices_beyond_tolerance)
        % already settled
        T_a2 = x_data.Time(1);
    else
        % last settling in the 2% band
        T_a2 = x_data.Time(indices_beyond_tolerance(end));
    end

    % Steady state error
    ss_error = abs(x_final - target_ref);

    % Max control effort
    max_u = max(abs(u_data.Data));

    % Control energy
    control_energy = trapz(u_data.Time, u_data.Data.^2);
end