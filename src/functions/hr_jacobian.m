function J = hr_jacobian(x, a, b, d, r, s)
%HR_JACOBIAN Analytical expression of Hindmarsh-Rose Jacobian
%   x' = y - ax^3 + bx^2 - z + I
%   y' = c - dx^2 - y
%   z' = r(s(x - x_r) - z)
J = [
    2*b*x - 3*a*x^2, 1, -1;
    -2*d*x, -1, 0;
    r*s, 0, -r;
];

end

