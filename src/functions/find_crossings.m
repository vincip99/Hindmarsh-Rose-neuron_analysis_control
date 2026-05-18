function [null_param, idx] = find_crossings(param, data)
%FIND_CROSSINGS Summary of this function goes here
%   Detailed explanation goes here
% detect changing sign
s = sign(data);
idx = find(diff(s) ~= 0);
null_param = zeros(1, length(idx));

for i = 1:length(idx)
   j = idx(i);
   null_param(i) = param(j) - data(j) * (param(j+1) - param(j)) / (data(j+1) - data(j));
end

end

