function [x, delta] = cubic(a, b, c, d)
%CUBIC Compute the roots of cubic polynomial
%   Using Cardano-Tartaglia exact formula for cubic
p = c/a - b^2/3/a^2;
q = d/a - b*c/3/a^2 + 2*b^3/27/a^3;

delta = q^2/4 + p^3/27;

u = (-q/2 + sqrt(delta))^(1/3);
v = (-q/2 - sqrt(delta))^(1/3);

omega = exp(1i * 2 * pi / 3);

x1 = u + v;
x2 = u*omega + v*omega^2;
x3 = u*omega^2 + v*omega;

x = [x1, x2, x3] - b/3/a;

end

