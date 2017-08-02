clear; close all; clc;
% normal mean and median
addpath(genpath('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/3DRecon_Algo_Eval/algo/PS/EPS/'));
rdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/sphere';
mask = imread(sprintf('%s/gt/mask.bmp', rdir));
mask(mask > 0) = 1;
norm_map_rgb = imread(sprintf('%s/gt/ps.png', rdir));
norm_map = decode(norm_map_rgb, mask);

norm_map_rgb1 = imread(sprintf('%s/gt/normal_080208.png', rdir));
norm_map1 = decode(norm_map_rgb1, mask);

n_z = norm_map1(:, :, 3);
mask(mask > 0) = 1;
n_z(n_z < 0.01) = 1;
n_x = norm_map1(:, :, 1) ./ n_z;
n_y = norm_map1(:, :, 2) ./ n_z;
height_map = DepthFromGradient(n_x, n_y);
height_map = height_map - height_map(end, end);
height_map(mask < 1) = 0;
[X, Y] = meshgrid(1:1280, 1:720);
mesh(X, Y, -height_map);
axis equal; view(-30, 20); colormap('default');

norm_map_rgb2 = imread(sprintf('%s/gt/normal_080502.png', rdir));
norm_map2 = decode(norm_map_rgb2, mask);

% n_z = norm_map2(:, :, 3);
% mask(mask > 0) = 1;
% n_z(n_z < 0.01) = 1;
% n_x = norm_map2(:, :, 1) ./ n_z;
% n_y = norm_map2(:, :, 2) ./ n_z;
% height_map = DepthFromGradient(n_x, n_y);
% height_map = height_map - height_map(end, end);
% height_map(mask < 1) = 0;
% [X, Y] = meshgrid(1:1280, 1:720);
% figure;mesh(X, Y, -height_map);
% axis equal; view(-30, 20); colormap('default');

%% show normal map
% show_surfNorm(norm_map_rgb, norm_map, 10);

%% change the mean and median
imask = find(mask);
normals = zeros(numel(imask), 3);
normals(:, 1) = norm_map(imask);
normals(:, 2) = norm_map(imask + numel(mask));
normals(:, 3) = norm_map(imask + 2 * numel(mask));

normals1 = zeros(numel(imask), 3);
normals1(:, 1) = norm_map1(imask);
normals1(:, 2) = norm_map1(imask + numel(mask));
normals1(:, 3) = norm_map1(imask + 2 * numel(mask));

normals2 = zeros(numel(imask), 3);
normals2(:, 1) = norm_map2(imask);
normals2(:, 2) = norm_map2(imask + numel(mask));
normals2(:, 3) = norm_map2(imask + 2 * numel(mask));

% ang1 = real(acosd(sum(normals .* normals1, 2)));
% ang2 = real(acosd(sum(normals .* normals2, 2)));
ang1 = sqrt(sum((normals - normals1).^2, 2));
ang2 = sqrt(sum((normals - normals2).^2, 2));
% hist(ang1, 100);
% figure; hist(ang2, 100);
% imask_ang1 = imask(ang1 < 5);
% imask_ang2 = imask(ang2 < 5);
% [y1, x1] = ind2sub(size(mask), imask_ang1);
% [y2, x2] = ind2sub(size(mask), imask_ang2);
% figure; imshow(norm_map_rgb1); hold on; plot(x1, y1, 'r.');
% figure; imshow(norm_map_rgb2); hold on; plot(x2, y2, 'r.');

ang_map1 = zeros(size(mask));
ang_map1(imask) = ang1;
ang_map2 = zeros(size(mask));
ang_map2(imask) = ang2;

% gradient of angle map: doesn't work
% [ang_map_mag1, ~] = imgradient(ang_map1, 'prewitt');
% [ang_map_mag2, ~] = imgradient(ang_map2, 'prewitt');
% figure; imshowpair(ang_map_mag1, ang_map_mag2, 'montage');
% title('Gradient Magnitude, Gmag (left), and Gradient Direction, Gdir (right), using Prewitt method')
% ang_mag1 = ang_map_mag1(imask);
% ang_mag2 = ang_map_mag2(imask);
% figure; hist(ang_mag1);
% figure; hist(ang_mag2);

% edge detection
sigma = 20;
thre = [0.1, 0.4];
ang_edge1 = edge(imgaussfilt(ang_map1, sigma), 'canny', thre);
ang_edge2 = edge(imgaussfilt(ang_map2, sigma), 'canny', thre);
figure; imshowpair(ang_edge1, ang_edge2, 'montage');
% ang_map_tmp1 = zeros(size(mask));
% ang_map_tmp1(ang_edge1) = ang_map1(ang_edge1);
% ang_map_tmp2 = zeros(size(mask));
% ang_map_tmp2(ang_edge2) = ang_map2(ang_edge2);
% figure; imshowpair(uint8(ang_map_tmp1), uint8(ang_map_tmp2), 'montage');

% normal to angle
theta = acosd(normals(:, 3));
phi = atan2d(normals(:, 2), normals(:, 1));
phi = mod(phi + 360, 360);

% change the angle theta
mu = 8;
med = 5;
sigma = 1;
prct = 0.1;
ang1 = med + sigma .* randn(numel(imask), 1);
[ang1, ind] = sort(ang1);
ang2 = (mu - med) / prct + sigma .* randn(round(numel(imask) * prct), 1);
ang1(round(2/3*numel(imask)) : round(2/3*numel(imask)) + numel(ang2) - 1) = ang1(round(2/3*numel(imask)) : round(2/3*numel(imask)) + numel(ang2) - 1) + ang2;
% figure;hist(ang, 100);
ang(ind) = ang1;
rnd = rand(numel(theta), 1);
ang(rnd > 0.5) = -ang(rnd > 0.5); % make half of these negative angle
theta = theta + ang';
theta(theta>90) = 90;

% angle to normal
normals_test = zeros(numel(imask), 3);
normals_test(:, 1) = sind(theta) .* cosd(phi);
normals_test(:, 2) = sind(theta) .* sind(phi);
normals_test(:, 3) = cosd(theta);
norm_map_test = zeros(size(norm_map));
norm_map_test(imask) = normals_test(:, 1);
norm_map_test(imask + numel(mask)) = normals_test(:, 2);
norm_map_test(imask + 2 * numel(mask)) = normals_test(:, 3);
show_surfNorm(mask, norm_map_test, 10);

%% integrate surface
n_z = norm_map_test(:, :, 3);
mask(mask > 0) = 1;
n_z(n_z < 0.01) = 1;
n_x = norm_map_test(:, :, 1) ./ n_z;
n_y = norm_map_test(:, :, 2) ./ n_z;
height_map = DepthFromGradient(n_x, n_y);
height_map = height_map - height_map(end, end);
height_map(mask < 1) = 0;
[X, Y] = meshgrid(1:1280, 1:720);
mesh(X, Y, -height_map);
axis equal; view(-30, 20); colormap('default');