function xdot = hr_dynamics(x, I, a, b, c, d, r, s, x_r)
%HR_DYNAMICS Summary of this function goes here
%   Detailed explanation goes here
    xdot = [x(2) - a*x(1)^3 + b*x(1)^2 - x(3) + I;...
            c - d*x(1)^2 - x(2);...
            r*(s*(x(1) - x_r) - x(3));];
end

