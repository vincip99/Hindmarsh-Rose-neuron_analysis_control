%% Enhanced Hindmarsh-Rose Bifurcation Analysis
% Parameters
a = 1;
b = 3;
c = 1;
d = 5;
s = 4;
x_r = -8/5;
r = 0.001;

% I vector with higher resolution near bifurcation points
I = linspace(0, 8, 500);

% Initialize storage
lambdas = cell(1, length(I));
eq = cell(1, length(I));
num_eq = zeros(1, length(I));
stability = cell(1, length(I));

% Bifurcation detection thresholds
TOL_ZERO = 1e-3;
TOL_IMAG = 1e-6;

% Initialize bifurcation storage
hopf_points = [];
sn_points = [];
hopf_I = [];
sn_I = [];

%% Main Loop
fprintf('Analyzing equilibria and bifurcations...\n');
for i = 1:length(I)
    % Find Equilibria
    [current_eq, num_eq(i)] = hr_equilibria(a, b, c, d, s, x_r, I(i));
    eq{i} = current_eq;
    
    current_lambdas = zeros(3, num_eq(i));
    current_stability = cell(1, num_eq(i));
    
    % Classify equilibria
    for j = 1:num_eq(i)
        % Compute Jacobian
        J_j = hr_jacobian(current_eq(1, j), a, b, d, r, s);
        
        % Compute eigenvalues
        eigenval = eig(J_j);
        [~, ind] = sort(abs(imag(eigenval)), 'ascend');
        current_lambdas(:, j) = eigenval(ind);
        
        % Determine stability type
        real_parts = real(eigenval);
        imag_parts = imag(eigenval);
        
        if all(real_parts < -TOL_ZERO)
            current_stability{j} = 'Stable';
        elseif any(abs(real_parts) < TOL_ZERO)
            current_stability{j} = 'Marginal';
            
            % Check for Hopf bifurcation (complex conjugate pair crossing)
            for k = 1:3
                if abs(real_parts(k)) < TOL_ZERO && abs(imag_parts(k)) > TOL_IMAG
                    if i > 1
                        prev_real = real(lambdas{i-1}(k, j));
                        if prev_real < -TOL_ZERO
                            hopf_points = [hopf_points; I(i), current_eq(1, j)];
                            hopf_I = [hopf_I, I(i)];
                            fprintf('Hopf bifurcation detected at I = %.4f\n', I(i));
                        end
                    end
                end
            end
            
            % Check for Saddle-Node bifurcation (real eigenvalue crossing zero)
            if any(abs(real_parts) < TOL_ZERO & abs(imag_parts) < TOL_IMAG)
                if i > 1 && i < length(I)
                    if (num_eq(i-1) ~= num_eq(i+1)) || ...
                       (abs(real_parts(1)) < TOL_ZERO && abs(real_parts(2)) > TOL_ZERO)
                        sn_points = [sn_points; I(i), current_eq(1, j)];
                        sn_I = [sn_I, I(i)];
                        fprintf('Saddle-Node bifurcation detected at I = %.4f\n', I(i));
                    end
                end
            end
        else
            if sum(real_parts > TOL_ZERO) == 1
                current_stability{j} = 'Saddle (index 1)';
            elseif sum(real_parts > TOL_ZERO) == 2
                current_stability{j} = 'Saddle (index 2)';
            else
                current_stability{j} = 'Unstable';
            end
        end
    end
    
    lambdas{i} = current_lambdas;
    stability{i} = current_stability;
end

%% Extract eigenvalue data
re_parts = cellfun(@(alpha) real(alpha), lambdas, 'UniformOutput', false);
re_array = horzcat(re_parts{:});

im_parts = cellfun(@(beta) imag(beta), lambdas, 'UniformOutput', false);
im_array = horzcat(im_parts{:});

%% Create Publication-Quality Plots
% Color scheme
colors = struct(...
    'lambda1', [0.0000, 0.4470, 0.7410], ...  % Blue
    'lambda2', [0.8500, 0.3250, 0.0980], ...  % Orange
    'lambda3', [0.9290, 0.6940, 0.1250], ...  % Yellow
    'zero_line', [0.8000, 0.8000, 0.8000], ... % Gray
    'hopf', [0.8500, 0.1000, 0.1000], ...      % Red
    'sn', [0.0000, 0.5000, 0.0000]);          % Green

% Figure 1: Real Parts
fig1 = figure('Name', 'Real Parts of Eigenvalues', ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [2, 2, 18, 14], ...
    'PaperPositionMode', 'auto');

% Create subplots
for k = 1:3
    subplot(3, 1, k);
    hold on;
    
    % Plot eigenvalue
    plot(I, re_array(k, :), 'Color', colors.(sprintf('lambda%d', k)), ...
        'LineWidth', 2.5);
    
    % Zero line
    yline(0, '--', 'Color', colors.zero_line, 'LineWidth', 1.5);
    
    % Mark bifurcation points
    if ~isempty(hopf_I)
        for h_idx = 1:length(hopf_I)
            xline(hopf_I(h_idx), ':', 'Color', colors.hopf, ...
                'LineWidth', 2, 'Alpha', 0.7);
        end
    end
    
    if ~isempty(sn_I)
        for s_idx = 1:length(sn_I)
            xline(sn_I(s_idx), '--', 'Color', colors.sn, ...
                'LineWidth', 2, 'Alpha', 0.7);
        end
    end
    
    % Labels and formatting
    title(sprintf('Real Part of $\\lambda_%d$', k), ...
        'Interpreter', 'latex', 'FontSize', 14);
    xlabel('Applied Current $I$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel(sprintf('$\\Re(\\lambda_%d)$', k), ...
        'Interpreter', 'latex', 'FontSize', 12);
    grid on;
    box on;
    
    % Set axis limits
    xlim([0, 8]);
    ylim_vals = ylim;
    ylim([min(ylim_vals(1), -0.1), max(ylim_vals(2), 0.1)]);
end

% Add legend for bifurcations (only in first subplot)
subplot(3, 1, 1);
h = zeros(3, 1);
h(1) = plot(NaN, NaN, '-', 'Color', colors.lambda1, 'LineWidth', 2);
h(2) = plot(NaN, NaN, ':', 'Color', colors.hopf, 'LineWidth', 2);
h(3) = plot(NaN, NaN, '--', 'Color', colors.sn, 'LineWidth', 2);
legend(h, {'Eigenvalue', 'Hopf Bifurcation', 'Saddle-Node Bifurcation'}, ...
    'Location', 'best', 'Interpreter', 'latex', 'FontSize', 10, ...
    'Box', 'off');

% Global formatting
set(findall(fig1, '-property', 'FontSize'), 'FontSize', 11);
set(findall(fig1, '-property', 'TickLabelInterpreter'), ...
    'TickLabelInterpreter', 'latex');

% Figure 2: Imaginary Parts
fig2 = figure('Name', 'Imaginary Parts of Eigenvalues', ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [22, 2, 18, 14], ...
    'PaperPositionMode', 'auto');

for k = 1:3
    subplot(3, 1, k);
    hold on;
    
    % Plot eigenvalue
    plot(I, im_array(k, :), 'Color', colors.(sprintf('lambda%d', k)), ...
        'LineWidth', 2.5);
    
    % Zero line
    yline(0, '--', 'Color', colors.zero_line, 'LineWidth', 1.5);
    
    % Mark bifurcation points
    if ~isempty(hopf_I)
        for h_idx = 1:length(hopf_I)
            xline(hopf_I(h_idx), ':', 'Color', colors.hopf, ...
                'LineWidth', 2, 'Alpha', 0.7);
        end
    end
    
    % Labels
    title(sprintf('Imaginary Part of $\\lambda_%d$', k), ...
        'Interpreter', 'latex', 'FontSize', 14);
    xlabel('Applied Current $I$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel(sprintf('$\\Im(\\lambda_%d)$', k), ...
        'Interpreter', 'latex', 'FontSize', 12);
    grid on;
    box on;
    xlim([0, 8]);
end

set(findall(fig2, '-property', 'FontSize'), 'FontSize', 11);
set(findall(fig2, '-property', 'TickLabelInterpreter'), ...
    'TickLabelInterpreter', 'latex');

%% Create Bifurcation Diagram
fig3 = figure('Name', 'Bifurcation Diagram', ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [12, 12, 16, 12], ...
    'PaperPositionMode', 'auto');

hold on;

% Plot equilibrium branches
for i = 1:length(I)
    if num_eq(i) > 0
        for j = 1:num_eq(i)
            % Determine stability for color coding
            stab = stability{i}{j};
            if contains(stab, 'Stable')
                color = [0, 0.5, 0];  % Green for stable
                linewidth = 2;
            elseif contains(stab, 'Saddle')
                color = [0.8, 0, 0];  % Red for saddle
                linewidth = 1.5;
            else
                color = [0.5, 0.5, 0.5];  % Gray for unstable
                linewidth = 1;
            end
            
            plot(I(i), eq{i}(1, j), '.', 'Color', color, ...
                'MarkerSize', 8);
        end
    end
end

% Mark bifurcation points
if ~isempty(hopf_points)
    plot(hopf_points(:, 1), hopf_points(:, 2), 'o', ...
        'Color', colors.hopf, 'MarkerSize', 12, ...
        'LineWidth', 2, 'MarkerFaceColor', 'none');
end

if ~isempty(sn_points)
    plot(sn_points(:, 1), sn_points(:, 2), '^', ...
        'Color', colors.sn, 'MarkerSize', 12, ...
        'LineWidth', 2, 'MarkerFaceColor', 'none');
end

xlabel('Applied Current $I$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Equilibrium $x$', 'Interpreter', 'latex', 'FontSize', 12);
title('Bifurcation Diagram: Equilibrium Branches', ...
    'Interpreter', 'latex', 'FontSize', 14);
grid on;
box on;

% Legend
h = zeros(4, 1);
h(1) = plot(NaN, NaN, '.', 'Color', [0, 0.5, 0], 'MarkerSize', 15);
h(2) = plot(NaN, NaN, '.', 'Color', [0.8, 0, 0], 'MarkerSize', 15);
h(3) = plot(NaN, NaN, 'o', 'Color', colors.hopf, 'MarkerSize', 10);
h(4) = plot(NaN, NaN, '^', 'Color', colors.sn, 'MarkerSize', 10);
legend(h, {'Stable', 'Saddle', 'Hopf', 'Saddle-Node'}, ...
    'Location', 'best', 'Interpreter', 'latex', 'FontSize', 10);

set(findall(fig3, '-property', 'FontSize'), 'FontSize', 11);
set(findall(fig3, '-property', 'TickLabelInterpreter'), ...
    'TickLabelInterpreter', 'latex');

%% Save Figures (High Quality)
% Uncomment to save figures
% exportgraphics(fig1, 'eigenvalues_real.pdf', 'ContentType', 'vector');
% exportgraphics(fig2, 'eigenvalues_imag.pdf', 'ContentType', 'vector');
% exportgraphics(fig3, 'bifurcation_diagram.pdf', 'ContentType', 'vector');
% saveas(fig1, 'eigenvalues_real.png');
% saveas(fig2, 'eigenvalues_imag.png');
% saveas(fig3, 'bifurcation_diagram.png');

%% Generate Summary Report
fprintf('\n=== BIFURCATION ANALYSIS SUMMARY ===\n');
fprintf('Hopf Bifurcations detected at I = ');
if ~isempty(hopf_I)
    fprintf('%.4f ', unique(hopf_I));
else
    fprintf('None');
end
fprintf('\nSaddle-Node Bifurcations detected at I = ');
if ~isempty(sn_I)
    fprintf('%.4f ', unique(sn_I));
else
    fprintf('None');
end
fprintf('\n=====================================\n');

%% Display bifurcation table
if ~isempty(hopf_I) || ~isempty(sn_I)
    fprintf('\nDetailed Bifurcation Points:\n');
    fprintf('%-20s %-15s %-15s\n', 'Type', 'I Value', 'x-coordinate');
    fprintf('%-20s %-15s %-15s\n', '----', '-------', '------------');
    
    for i = 1:size(hopf_points, 1)
        fprintf('%-20s %-15.4f %-15.4f\n', 'Hopf', ...
            hopf_points(i, 1), hopf_points(i, 2));
    end
    
    for i = 1:size(sn_points, 1)
        fprintf('%-20s %-15.4f %-15.4f\n', 'Saddle-Node', ...
            sn_points(i, 1), sn_points(i, 2));
    end
end