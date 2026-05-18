clearvars
close all
clc

%% Parameters
a = 1;
b = 3;
c = 1;
d = 5;
s = 4;
x_r = -8/5;

%% Eigenvalues loop changing only I
r = 0.003;
% I vector
I = linspace(0, 4, 100);
% initialize eigenvalues vector cell
lambdas = cell(1, length(I));
% initialize eq vector cell
eq = cell(1, length(I));
num_eq = zeros(1, length(I));
eq_stability = cell(1, length(I));
% Loop
for i = 1:length(I)
    % Find Equilibria
    [current_eq, num_eq(i)] = hr_equilibria(a, b, c, d, s, x_r, I(i));
    eq{i} = current_eq;
    
    current_lambdas = zeros(3, num_eq(i));
    current_stability = cell(1, num_eq(i));
    % Classify equilibria
    for j = 1 : num_eq(i)
        % compute the jacobians in the equilibrium points
        J_j = hr_jacobian(current_eq(1, j), a, b, d, r, s); 
    
        % compute eigenvalues
        % eig does not always return the eigenvalues in sorted order
        eigenval = eig(J_j); % eig produces a column
        [~, ind] = sort(abs(imag(eigenval)), 'ascend');
        current_lambdas(:, j) = eigenval(ind);

        % Check stability of each eq eigenvalues
        if all(real(eigenval) < 0) && any(imag(eigenval) == 0)
            current_stability{j} = 'stable node';
        elseif all(real(eigenval) < 0) && any(imag(eigenval) ~= 0)
            current_stability{j} = 'stable focus';
        elseif all(real(eigenval) > 0) && any(imag(eigenval) == 0)
            current_stability{j} = 'unstable node';
        elseif all(real(eigenval) > 0) && any(imag(eigenval) ~= 0)
            current_stability{j} = 'unstable focus';
        else
            current_stability{j} = 'saddle';
        end
    end
      
    lambdas{i} = current_lambdas;
    eq_stability{i} = current_stability;
end

% extract real and imag parts
re_parts = cellfun(@(alpha) real(alpha), lambdas, 'UniformOutput',false);
re_array = horzcat(re_parts{:});

im_parts = cellfun(@(beta) imag(beta), lambdas, 'UniformOutput',false);
im_array = horzcat(im_parts{:});

% crossing detection for hopf bifurcations 
% (not necessarly an hopf but i've cecked on matcont)
[hopf_param_1, ~] = find_hopf(I, re_array(1, :), im_array(1, :));
[hopf_param_2, ~] = find_hopf(I, re_array(2, :), im_array(2, :));
[hopf_param_3, ~] = find_hopf(I, re_array(3, :), im_array(3, :));

% ------------- Plots ---------------
% adjust my plot from hyrman project
% -----------------------------------
fig1 = figure('Name','Eigenvalues plots', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 10], 'Color', 'w');
lay1 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','tight');
% plot of re lambda_1
nexttile    % usig it instead of subplot to better aesthetics
grid on; hold on;
plot(I, re_array(1, :), 'Color', [0, 0.4470, 0.7410], 'LineWidth', 2, ...
    'DisplayName', '$\Re(\lambda_1)$')
% crossing detection
if ~isempty(hopf_param_1)
    xline(hopf_param_1,'--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    plot(hopf_param_1, zeros(size(hopf_param_1)), 'rx', ...
    'MarkerSize', 10, ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Hopf');
end
yline(0, '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
title('Real part of $\lambda_1$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% plot of re lambda_2
nexttile
grid on; hold on;
plot(I, re_array(2, :), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2, ...
    'DisplayName', '$\Re(\lambda_2)$')
if ~isempty(hopf_param_2)
    xline(hopf_param_2,'--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    plot(hopf_param_2, zeros(size(hopf_param_2)), 'rx', ...
    'MarkerSize', 10, ...
    'LineWidth', 1.5, ...
    'DisplayName', 'Hopf');
end
yline(0, '--k','LineWidth', 1, 'HandleVisibility', 'off');
title('Real part of $\lambda_2$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% plot of re lambda_3
nexttile
grid on; hold on;
plot(I, re_array(3, :), 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2,  ...
    'DisplayName', '$\Re(\lambda_3)$')
% crossing detection
if ~isempty(hopf_param_3)
    xline(hopf_param_3,'--r','LineWidth', 1.5, 'HandleVisibility', 'off');
    plot(hopf_param_3, zeros(size(hopf_param_3)), 'rx', ...
        'MarkerSize', 10, ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Hopf');
end
yline(0, '--k','LineWidth', 1, 'HandleVisibility', 'off');
title('Real part of $\lambda_3$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
legend('Location', 'northwest', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% Global formatting
set(findall(fig1, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig1, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

fig2 = figure('Name','Eigenvalues plots', 'Color', 'w', 'Units', ...
    'centimeters', 'Position', [2, 2, 20, 10], 'Color', 'w');
lay2 = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding','tight');
% plot of im lambda_1
nexttile    % usig it instead of subplot to better aesthetics
grid on; hold on;
plot(I, im_array(1, :), 'Color', [0, 0.4470, 0.7410], 'LineWidth', 2, ...
    'DisplayName', '$\Im(\lambda_1)$')
if ~isempty(hopf_param_1)
    xline(hopf_param_1,'--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
end
yline(0, '--k','LineWidth', 1, 'HandleVisibility', 'off');
title('Immaginary part  of $\lambda_1$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% plot of im lambda_2
nexttile
grid on; hold on;
plot(I, im_array(2, :), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2, ...
    'DisplayName', '$\Im(\lambda_2)$')
if ~isempty(hopf_param_2)
    xline(hopf_param_2,'--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
end
yline(0, '--k','LineWidth', 1, 'HandleVisibility', 'off');
title('Immaginary part of $\lambda_2$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
% Plot an invisible line for the legend
plot(nan, nan, '--r', 'LineWidth', 1.5, 'DisplayName', 'Hopf');
legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% plot of im lambda_3
nexttile
grid on; hold on;
plot(I, im_array(3, :), 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2, ...
    'DisplayName', '$\Im(\lambda_2)$')
if ~isempty(hopf_param_3)
    xline(hopf_param_3,'--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
end
yline(0, '--k','LineWidth', 1, 'HandleVisibility', 'off');
title('Immaginary part  of $\lambda_3$', 'Interpreter', 'latex')
xlabel('$I$', 'Interpreter', 'latex')
% Plot an invisible line for the legend
plot(nan, nan, '--r', 'LineWidth', 1.5, 'DisplayName', 'Hopf');
legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% Global formatting
set(findall(fig2, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig2, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

% Export figures
exportgraphics(fig1, 'figures/hr_real_eigenvalues_I.png', 'Resolution',600);
exportgraphics(fig2, 'figures/hr_imag_eigenvalues_I.png', 'Resolution',600);

fig3 = figure('Name','Bifurcation diagram x vs I','Color', 'w');
box on; grid on; hold on;

% Plot equilibrium branches
for i = 1:length(I)
    if num_eq(i) > 0
        for j = 1:num_eq(i)
            % Determine stability for color coding
            stab = eq_stability{i}{j};
            if contains(stab, 'stable')
                color = [0, 0.5, 0];  % Green for stable
                marker = '.';
                markersize = 10;
            elseif contains(stab, 'saddle')
                color = [0.8, 0, 0];  % Red for saddle
                marker = '.';
                markersize = 8;
            else
                color = [0.5, 0.5, 0.5];  % Gray for unstable
                marker = '.';
                markersize = 6;
            end
            
            plot(I(i), eq{i}(1, j), marker, 'Color', color, ...
                'MarkerSize', markersize, 'HandleVisibility', 'off');
        end
    end
end

% Mark Hopf bifurcation points
hopf_values = [];
hopf_x = [];

for h = 1:length(hopf_param_1)
    [~, idx] = min(abs(I - hopf_param_1(h)));
    if idx <= length(eq) && ~isempty(eq{idx})
        for j = 1:num_eq(idx)
            hopf_values = [hopf_values; hopf_param_1(h)];
            hopf_x = [hopf_x; eq{idx}(1, j)];
        end
    end
end

for h = 1:length(hopf_param_2)
    [~, idx] = min(abs(I - hopf_param_2(h)));
    if idx <= length(eq) && ~isempty(eq{idx})
        for j = 1:num_eq(idx)
            hopf_values = [hopf_values; hopf_param_2(h)];
            hopf_x = [hopf_x; eq{idx}(1, j)];
        end
    end
end

for h = 1:length(hopf_param_3)
    [~, idx] = min(abs(I - hopf_param_3(h)));
    if idx <= length(eq) && ~isempty(eq{idx})
        for j = 1:num_eq(idx)
            hopf_values = [hopf_values; hopf_param_3(h)];
            hopf_x = [hopf_x; eq{idx}(1, j)];
        end
    end
end

if ~isempty(hopf_values)
    plot(hopf_values, hopf_x, 'o', ...
        'Color', [0.8, 0, 0], 'MarkerSize', 10, ...
        'LineWidth', 2, 'MarkerFaceColor', 'none', ...
        'DisplayName', 'Hopf Bifurcations');
end

xlabel('Applied Current $I$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Equilibrium $x$', 'Interpreter', 'latex', 'FontSize', 12);
title('Bifurcation Diagram: Equilibrium Branches', ...
    'Interpreter', 'latex', 'FontSize', 14);
grid on;
box on;
legend('Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 10, 'Box', 'on')

% Global formatting
set(findall(fig3, '-property', 'Fontsize'), 'Fontsize', 11);
set(findall(fig3, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');


%% Eigenvalues loop changing only r
I = 2;
% r vector
r = linspace(10e-4, 0.05, 100);
% initialize eigenvalues vector
lambdas = zeros(3, length(r));
% initialize eq vector
eq = zeros(3, length(r));
% Loop
for i = 1:length(r)
    % Find Equilibria
    % from y = c - d*x^2; z = s*(x - x_r);
    % => -a*x^3 + (b-d)*x^2 - s*x - s*x_r + I + c;
    eq(:, i) = hr_equilibria(a, b, c, d, s, x_r, I);

    % Classify equilibria
    % compute the jacobians in the equilibrium points
    J_i = hr_jacobian(eq(1, i), a, b, d, r(i), s); 

    % compute eigenvalues
    % eig does not always return the eigenvalues in sorted order
    eigenval = eig(J_i); % eig produces a column
    [~, ind] = sort(abs(imag(eigenval)), 'ascend');
    lambdas(:, i) = eigenval(ind);
end

% Plot in the complex plane
figure('Color', 'w')
hold on; grid on;
plot(real(lambdas(1, :)), imag(lambdas(1, :)), 'b.', 'MarkerSize', 5, 'DisplayName', '$\lambda_1$')
plot(real(lambdas(2, :)), imag(lambdas(2, :)), 'r.', 'MarkerSize', 5, 'DisplayName', '$\lambda_2$')
plot(real(lambdas(3, :)), imag(lambdas(3, :)), 'g.', 'MarkerSize', 5, 'DisplayName', '$\lambda_3$')
xline(0, 'r--', 'LineWidth', 1.5, 'Label', 'Imaginary Axes', 'HandleVisibility','off');
yline(0, 'k:', 'HandleVisibility','off');

% First eigenvalues mark
plot(real(lambdas(1, 1)), imag(lambdas(1, 1)), 'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'HandleVisibility','off')
plot(real(lambdas(2, 1)), imag(lambdas(2, 1)), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility','off')
plot(real(lambdas(3, 1)), imag(lambdas(3, 1)), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'HandleVisibility','off')

% Last eigenvalues mark
plot(real(lambdas(1, end)), imag(lambdas(1, end)), 'ks', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'HandleVisibility','off')
plot(real(lambdas(2, end)), imag(lambdas(2, end)), 'ks', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility','off')
plot(real(lambdas(3, end)), imag(lambdas(3, end)), 'ks', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'HandleVisibility','off')

xlabel('Real Part');
ylabel('Immaginary Part');
title('Eigenvalues Evolution');
axis equal;
legend('Location','best', 'Interpreter','latex')

% Plot of real part and immaginary part of eigenvalues 1,2,3 with I varying
figure('Name','Eigenvalues 1-2-3 vs Current I', 'Color', 'w')

% plot of lambda_1
subplot(3, 1, 1)
hold on; grid on;
plot(r, real(lambdas(1,:)), 'b-' ,'DisplayName', '$Re[\lambda_{1}]$', 'LineWidth', 1.5)
plot(r, imag(lambdas(1,:)), 'r-' ,'DisplayName', '$Im[\lambda_{1}]$', 'LineWidth', 1.5)

xlabel('Current ($I$)','Interpreter', 'latex')
ylabel('Real Part')
title('Evolution of eigenvalues $\lambda_1$', 'Interpreter','latex')
legend('Location','best', 'Interpreter','latex')

% plot of real part lambda_2,3
subplot(3, 1, 2)
hold on; grid on;
plot(r, real(lambdas(2,:)), 'b-' ,'DisplayName', '$Re[\lambda_{2}]$', 'LineWidth', 1.5)
plot(r, real(lambdas(3,:)), 'r-' , 'DisplayName', '$Re[\lambda_{3}]$', 'LineWidth', 1.5)

xlabel('Current ($I$)','Interpreter', 'latex')
ylabel('Real Part')
title('Evolution of eigenvalues $\lambda_2, \lambda_3$', 'Interpreter','latex')
legend('Location','best', 'Interpreter','latex')

% plot of immaginary part lambda_2,3
subplot(3, 1, 3)
hold on; grid on;
plot(r, imag(lambdas(2,:)),'b-' , 'DisplayName', '$Im[\lambda_{2}]$', 'LineWidth', 1.5)
plot(r, imag(lambdas(3,:)),'r-' , 'DisplayName', '$Im[\lambda_{3}]$', 'LineWidth', 1.5)

xlabel('Current ($I$)','Interpreter', 'latex')
ylabel('Immaginary Part')
title('Evolution of eigenvalues $\lambda_2, \lambda_3$', 'Interpreter','latex')
legend('Location','best', 'Interpreter','latex')

%% Eigenvalues loop changing only b
I = 2;
% r vector
r = 0.001;
% B vector
b = linspace(0, 10, 100);
% initialize eigenvalues and eq cell 
eq_cell = cell(1, length(b));
lambdas_cell = cell(1, length(b));
num_eq_vec = zeros(1, length(b));
% Loop
for i = 1:length(b)
    % Find Equilibria
    % from y = c - d*x^2; z = s*(x - x_r);
    % => -a*x^3 + (b-d)*x^2 - s*x - s*x_r + I + c;
    [current_eq, num_eq] = hr_equilibria(a, b(i), c, d, s, x_r, I);

    num_eq_vec(i) = num_eq;
    eq_cell{i} = current_eq;
    current_lambdas = zeros(3, num_eq);
    
    for j=1:num_eq
        % Classify equilibria    
        % compute the jacobians in the equilibrium points
        x_eq = current_eq(1, j);
        J_j = hr_jacobian(x_eq, a, b(i), d, r, s); 
    
        % compute eigenvalues
        % eig does not always return the eigenvalues in sorted order
        eigenval = eig(J_j); % eig produces a column
        [~, ind] = sort(abs(imag(eigenval)), 'ascend');
        current_lambdas(:, j) = eigenval(ind);
    end

    lambdas_cell{i} = current_lambdas;
end

% % Plot in the complex plane
% figure('Color', 'w')
% hold on; grid on;
% plot(real(lambdas(1, :)), imag(lambdas(1, :)), 'b.', 'MarkerSize', 5, 'DisplayName', '$\lambda_1$')
% plot(real(lambdas(2, :)), imag(lambdas(2, :)), 'r.', 'MarkerSize', 5, 'DisplayName', '$\lambda_2$')
% plot(real(lambdas(3, :)), imag(lambdas(3, :)), 'g.', 'MarkerSize', 5, 'DisplayName', '$\lambda_3$')
% xline(0, 'r--', 'LineWidth', 1.5, 'Label', 'Imaginary Axes', 'HandleVisibility','off');
% yline(0, 'k:', 'HandleVisibility','off');
% 
% % First eigenvalues mark
% plot(real(lambdas(1, 1)), imag(lambdas(1, 1)), 'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'HandleVisibility','off')
% plot(real(lambdas(2, 1)), imag(lambdas(2, 1)), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility','off')
% plot(real(lambdas(3, 1)), imag(lambdas(3, 1)), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'HandleVisibility','off')
% 
% % Last eigenvalues mark
% plot(real(lambdas(1, end)), imag(lambdas(1, end)), 'ks', 'MarkerFaceColor', 'b', 'MarkerSize', 8, 'HandleVisibility','off')
% plot(real(lambdas(2, end)), imag(lambdas(2, end)), 'ks', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'HandleVisibility','off')
% plot(real(lambdas(3, end)), imag(lambdas(3, end)), 'ks', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'HandleVisibility','off')
% 
% xlabel('Real Part');
% ylabel('Immaginary Part');
% title('Eigenvalues Evolution');
% axis equal;
% legend('Location','best', 'Interpreter','latex')
% 
% % Plot of real part and immaginary part of eigenvalues 1,2,3 with I varying
% figure('Name','Eigenvalues 1-2-3 vs Current I', 'Color', 'w')
% 
% % plot of lambda_1
% subplot(3, 1, 1)
% hold on; grid on;
% plot(b, real(lambdas(1,:)), 'b-' ,'DisplayName', '$Re[\lambda_{1}]$', 'LineWidth', 1.5)
% plot(b, imag(lambdas(1,:)), 'r-' ,'DisplayName', '$Im[\lambda_{1}]$', 'LineWidth', 1.5)
% 
% xlabel('Current ($I$)','Interpreter', 'latex')
% ylabel('Real Part')
% title('Evolution of eigenvalues $\lambda_1$', 'Interpreter','latex')
% legend('Location','best', 'Interpreter','latex')
% 
% % plot of real part lambda_2,3
% subplot(3, 1, 2)
% hold on; grid on;
% plot(b, real(lambdas(2,:)), 'b-' ,'DisplayName', '$Re[\lambda_{2}]$', 'LineWidth', 1.5)
% plot(b, real(lambdas(3,:)), 'r-' , 'DisplayName', '$Re[\lambda_{3}]$', 'LineWidth', 1.5)
% 
% xlabel('Current ($I$)','Interpreter', 'latex')
% ylabel('Real Part')
% title('Evolution of eigenvalues $\lambda_2, \lambda_3$', 'Interpreter','latex')
% legend('Location','best', 'Interpreter','latex')
% 
% % plot of immaginary part lambda_2,3
% subplot(3, 1, 3)
% hold on; grid on;
% plot(b, imag(lambdas(2,:)),'b-' , 'DisplayName', '$Im[\lambda_{2}]$', 'LineWidth', 1.5)
% plot(b, imag(lambdas(3,:)),'r-' , 'DisplayName', '$Im[\lambda_{3}]$', 'LineWidth', 1.5)
% 
% xlabel('Current ($I$)','Interpreter', 'latex')
% ylabel('Immaginary Part')
% title('Evolution of eigenvalues $\lambda_2, \lambda_3$', 'Interpreter','latex')
% legend('Location','best', 'Interpreter','latex')

figure('Name', 'Hindmarsh-Rose Equilibria vs b', 'Color', 'w')
hold on; grid on;

% Loop through each step of b
for i = 1:length(b)
    % Extract all x-coordinates for the i-th value of b
    % current_x will have 1 or 3 elements based on your previous loop
    current_x = eq_cell{i}(1, :); 
    
    % Plot points for this value of b
    % We use a single color initially to see the structure
    plot(repmat(b(i), 1, length(current_x)), current_x, 'k.', 'MarkerSize', 6);
end

% Formatting
xlabel('Parameter $b$', 'Interpreter', 'latex')
ylabel('Equilibrium Potential $x^*$', 'Interpreter', 'latex')
title('Bifurcation Diagram: Equilibrium States vs. $b$', 'Interpreter', 'latex')

% Optional: Highlight the transition
num_eqs = cellfun(@(c) size(c, 2), eq_cell);
bifurcation_idx = find(num_eqs > 1, 1);
if ~isempty(bifurcation_idx)
    xline(b(bifurcation_idx), 'r--', 'Label', 'Saddle-Node Bifurcation', 'Interpreter', 'latex');
end

figure('Color', 'w')
hold on; grid on;
xline(0, 'r--', 'LineWidth', 1.5, 'Label', 'Imaginary Axis');
yline(0, 'k:');

% Iterate through the cell array
for i = 1:length(b)
    current_lambdas = lambdas_cell{i}; % This is a 3 x num_eq matrix
    num_pts = size(current_lambdas, 2);
    
    for k = 1:num_pts
        % Use different markers/colors based on how many equilibria exist
        if num_pts == 1
            p1 = plot(real(current_lambdas(:, k)), imag(current_lambdas(:, k)), 'b.', 'MarkerSize', 4);
        else
            % If 3 eq exist, color them based on their branch k
            colors = ['g', 'm', 'c']; % Green=Rest, Magenta=Saddle, Cyan=Active
            p2 = plot(real(current_lambdas(:, k)), imag(current_lambdas(:, k)), '.', 'Color', colors(k), 'MarkerSize', 4);
        end
    end
end

figure('Name','Eigenvalue Branches vs b', 'Color', 'w')

% Subplot for Real Parts
subplot(2, 1, 1)
hold on; grid on;
for i = 1:length(b)
    reals = real(lambdas_cell{i});
    % Plot all real parts found for this b
    plot(repmat(b(i), 1, size(reals,1)*size(reals,2)), reals(:), 'k.', 'MarkerSize', 3);
end
ylabel('Real Part $Re[\lambda]$', 'Interpreter', 'latex')
title('Real Part of all Eigenvalues vs Parameter $b$', 'Interpreter', 'latex')

% Subplot for Imaginary Parts
subplot(2, 1, 2)
hold on; grid on;
for i = 1:length(b)
    imags = imag(lambdas_cell{i});
    plot(repmat(b(i), 1, size(imags,1)*size(imags,2)), imags(:), 'r.', 'MarkerSize', 3);
end
ylabel('Imaginary Part $Im[\lambda]$', 'Interpreter', 'latex')
xlabel('Parameter $b$', 'Interpreter', 'latex')
title('Imaginary Part of all Eigenvalues vs Parameter $b$', 'Interpreter', 'latex')

% %% Eigenvalues loop changing I, b
% b = linspace(1, 4, 10);
% 
% all_lambdas = zeros(3, length(I), length(b));
% 
% r = 0.001;
% I = linspace(2, 10, 10);
% 
% for i = 1:length(I)
%     for j = 1:length(b)
%         % Find Equilibria
%         % from y = c - d*x^2; z = s*(x - x_r);
%         % => -a*x^3 + (b-d)*x^2 - s*x - s*x_r + I + c;
%         eq = hr_equilibria(a, b(j), c, d, s, x_r, I(i));
% 
%         % Classify equilibria    
%         for k = 1:length(eq(1, :))
%             % compute the jacobians in the equilibrium points
%             J_i = hr_jacobian(eq(1, k), a, b(j), d, r, s);  
% 
%             % compute eigenvalues
%             all_lambdas(:, i, j) = eig(J_i);  % eig produces a column
% 
%         end
%     end
% end
% 
% % Plot in the complex plane
% figure('Color', 'w')
% hold on; grid on;
% plot(real(all_lambdas(1, :)), imag(all_lambdas(1, :)), 'b.', 'MarkerSize', 5, 'DisplayName', '$\lambda_1$')
% plot(real(all_lambdas(2, :)), imag(all_lambdas(2, :)), 'r.', 'MarkerSize', 5, 'DisplayName', '$\lambda_2$')
% plot(real(all_lambdas(3, :)), imag(all_lambdas(3, :)), 'g.', 'MarkerSize', 5, 'DisplayName', '$\lambda_3$')
% xline(0, 'r--', 'LineWidth', 1.5, 'Label', 'Imaginary Axes');
% yline(0, 'k:');
% 
% xlabel('Real Part');
% ylabel('Immaginary Part');
% title('Eigenvalues');
% axis equal;