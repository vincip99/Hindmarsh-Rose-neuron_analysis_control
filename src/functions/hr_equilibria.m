function [eq, num_eq] = hr_equilibria(a, b, c, d, s, x_r, I)
%HR_EQUILIBRIA Compute Numerical Equilibria of HR model
%   Detailed explanation goes here
% from y = c - d*x^2; z = s*(x - x_r);
% -a*x^3 + (b-d)*x^2 - s*x - s*x_r + I + c;
x_eq = roots([-a, (b-d), -s, (s*x_r + I + c)]); % avoid division by a
% choose only real x_eq
pure_real = abs(imag(x_eq)) < 1e-10;
x_real = real(x_eq(pure_real));

% Sort from lowest potential equilibria (quoiescence)
x_real = sort(x_real, 'ascend');
% Compute corresponding y_eq and z_eq
y_real = c - d*x_real.^2;
z_real = s*(x_real - x_r);

% output real eq. as 3xN matrix
eq = [x_real.'; y_real.'; z_real.'];
num_eq = length(x_real);

end

