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
r = 0.003;
I = 1.309;

%% Find Equilibria
eq = hr_equilibria(a, b, c, d, s, x_r, I)

%% Classify equilibria
for i = 1:length(eq(1,:))
    % compute the jacobians in the equilibrium points
    J_i = hr_jacobian(eq(1, i), a, b, d, r, s);

    % compute eigenvalues
    lambda = eig(J_i)

end

%% Plot Eigenvalues
figure('Color', 'w')
scatter(real(lambda), imag(lambda), 60, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5)
xline(0, 'r--', 'LineWidth', 1.5, 'Label', 'Imaginary Axes');
yline(0, 'k:');

xlabel('Real Part ($\alpha$)', 'Interpreter', 'latex');
ylabel('Imaginary Part ($j\omega$)', 'Interpreter', 'latex');
title('\bf Eigenvalues', 'Interpreter', 'latex');

set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex', 'Box', 'on');
