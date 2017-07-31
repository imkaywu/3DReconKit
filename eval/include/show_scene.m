% plot the 3D scene
dsample = 10;
X = voxels.XData(1 : dsample : end);
Y = voxels.YData(1 : dsample : end);
Z = voxels.ZData(1 : dsample : end);
plot3(X, Y, Z, 'r.'); hold on;

for cc = 1 : numel(cameras)
    [K, R, t] = decomposeP(P(:, :, cc));
    draw_camera(K, R, t);
end