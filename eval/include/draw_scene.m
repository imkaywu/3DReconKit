addpath('../../algo');
% plot the 3D scene
dsample = 10;
X = voxels.XData(1 : dsample : end);
Y = voxels.YData(1 : dsample : end);
Z = voxels.ZData(1 : dsample : end);
plot3(X, Y, Z, 'r.');

[~, ~, ncams] = size(P);
for cc = 1 : ncams
    [K, R, t] = decomposeP(P(:, :, cc));
    hold on;
    draw_camera;
end