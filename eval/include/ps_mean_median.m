close all; clc;
% normal mean and median
addpath(genpath('C:\Users\Admin\Documents\3D_Recon\Data\synthetic_data\3DRecon_Algo_Eval'));
rdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/testing/knight';
mask = imread(sprintf('%s/gt/mask.bmp', rdir));
mask(mask > 0) = 1;
norm_map_rgb = imread(sprintf('%s/gt/ps.png', rdir));
norm_map = decode(norm_map_rgb, mask);

% norm_map_rgb1 = imread(sprintf('%s/gt/normal_2.png', rdir));
% norm_map1 = decode(norm_map_rgb1, mask);
% 
% norm_map_gt_rgb = imread(sprintf('%s/gt/ps.png', rdir));
% norm_map_gt = decode(norm_map_gt_rgb, mask);

%% show normal map
% show_surfNorm(norm_map_rgb, norm_map, 10);

%% change the mean and median
mu = 10;
med = 10;
sigma = 1;
prct = 0.1;
imask = find(mask);
normals = zeros(numel(imask), 3);
normals(:, 1) = norm_map(imask);
normals(:, 2) = norm_map(imask + numel(mask));
normals(:, 3) = norm_map(imask + 2 * numel(mask));

% normals1 = zeros(numel(imask), 3);
% normals1(:, 1) = norm_map1(imask);
% normals1(:, 2) = norm_map1(imask + numel(mask));
% normals1(:, 3) = norm_map1(imask + 2 * numel(mask));
% 
% normals_gt = zeros(numel(imask), 3);
% normals_gt(:, 1) = norm_map_gt(imask);
% normals_gt(:, 2) = norm_map_gt(imask + numel(mask));
% normals_gt(:, 3) = norm_map_gt(imask + 2 * numel(mask));
% ang = acosd(sum(normals .* normals_gt, 2));
% ang1 = acosd(sum(normals1 .* normals_gt, 2));
% hist(ang, 100);

% normal to angle
theta = acosd(normals(:, 3));
phi = atan2d(normals(:, 2), normals(:, 1));
phi = mod(phi + 360, 360);

% change the angle theta
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
height_map = integrate_horn2(n_x, n_y, double(mask), 50000, 1);
write_ply(sprintf('%s/gt/sphere_ps.ply', rdir), height_map, norm_map_test, mask);