% rearrange the normal map and estimate the height map
close all;

mask_tar = imread(data.name_mask_tar);
mask_tar(mask_tar > 0) = 1;
mask_tar_ind = find(mask_tar);
mask_reso = numel(mask_tar);
img_tar = imread(data.name_img_tar{1});

% normals = read_normals([data.dir, 'data/norm_map.txt']);

norm_map = zeros(size(mask_tar, 1), size(mask_tar, 2), 3);
norm_map(mask_tar_ind + mask_reso * 0) = normals(1, :);
norm_map(mask_tar_ind + mask_reso * 1) = normals(2, :);
norm_map(mask_tar_ind + mask_reso * 2) = normals(3, :);

% show normal map
show_surfNorm(img_tar, norm_map, 10);

% write to normal map (color coded)
norm_map_rgb = encode(norm_map, mask_tar);
imwrite(norm_map_rgb, sprintf('%s/normal.png', data.dir));
clear norm_map_rgb;

% integrate the normal to get the surface
DfG = 0; % depth from gradients
if DfG
% solution 1, solving a sparse system of linear equations
% h_tar_map = compute_heightMap(norm_map, mask_tar);

% solution 2, horn's method
n_z = norm_map(:, :, 3);
mask_tar(mask_tar > 0) = 1;
n_z(n_z < 0.01) = 1;
n_x = norm_map(:, :, 1) ./ n_z;
n_y = norm_map(:, :, 2) ./ n_z;
h_tar_map = integrate_horn2(n_x, n_y, double(mask_tar), 100000, 1);
% [slant, tilt] = grad2slanttilt(n_x, n_y);
% h_tar_map = shapeletsurf(slant, tilt, 6, 1, 2, 'slanttilt');

% solution 3
% h_tar_map = frankotchellappa(n_x, n_y);

% write to .ply file
write_ply([data.dir, '/', data.obj_name, '_ps.ply'], h_tar_map, norm_map, img_tar, mask_tar);
end