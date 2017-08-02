function [meanA, medianA, stdA, maxA, angleImg, angle] =  normalAngleEval(N_true, N_est, maskindex)

%Evaluate how well a reconstructed 3D surface is
%N_true and N_est should be (height X width X 3) vectors (unit vector)
masklength = length(maskindex);
N_true1  = zeros(masklength, 3);
N_est1  = zeros(masklength, 3);
[height, width, color] = size(N_true);

for i = 1 : 3
     temp1 = N_true(:, :, i);
     N_true1(:, i) = temp1(maskindex);
     
     temp2 = N_est(:, :, i);
     N_est1(:, i) = temp2(maskindex);
end

dotM = dot(N_true1, N_est1, 2);
angle = (180 .* acos(dotM)) ./ pi;

angle = real(angle);

meanA = mean(angle);
% varA = var(angle);
stdA = std(angle);
medianA = median(angle);
maxA = max(angle);

angleImg = zeros(height, width);
for i = 1 : masklength
    angleImg(maskindex(i)) = angle(i);
end
