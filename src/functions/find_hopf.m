function [hopf_param,idx] = find_hopf(param, data, imag_data)
%FIND_HOPF Only checks crossing with nonzero velocity!!!
%   Detailed explanation goes here
s = sign(data);
idx = find(diff(s) ~= 0);
hopf_param = zeros(1, length(idx));

for i = 1:length(idx)
   j = idx(i);
   if imag_data(j) ~= 0 || imag_data(j+1) ~= 0
      hopf_param(i) = param(j) - data(j) * (param(j+1) - param(j)) / (data(j+1) - data(j));
   else
       idx(i) = [];
   end
end
end

