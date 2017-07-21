% Example based photometric stereo with one reference object
addpath('/Users/BlacKay/Downloads/Software/flann-1.8.4-src/src/matlab');

%% prepare data
ind_ref = 2;
mask_tar = imread(data.name_mask_tar);
mask_tar(mask_tar > 0) = 1;
mask_ref = imread(data.name_mask_ref{ind_ref});
% range_radius = [150, 180]; % the range of radius is a user-defined parameter
% [center{1}, radius(1), ~] = imfindcircles(mask_ref_edge{ind_ref}, range_radius);
center = 151;
radius = 120.5;
mask_ref(mask_ref > 0) = 1;

img_tar = zeros(size(mask_tar, 1), size(mask_tar, 2), 3 * data.num_img, 'uint8');
img_ref = zeros(size(mask_ref, 1), size(mask_ref, 2), 3 * data.num_img, 'uint8');

n_map_tar = zeros([size(mask_tar), 3]);

ind_img = randperm(data.num_img);
for i = 1 : data.num_img % reshuffle the image
    % target object
    img_tar(:, :, 3 * (i - 1) + 1 : 3 * i) = imread(data.name_img_tar{ind_img(i)});
    
    % reference object
    img_ref(:, :, 3 * (i - 1) + 1 : 3 * i) = imread(data.name_img_ref{ind_img(i), 1});
end

% rearrange the image data so that the data is grouped by channel
r_ind = (1 : 3 : 3 * data.num_img);
g_ind = (1 : 3 : 3 * data.num_img) + 1;
b_ind = (1 : 3 : 3 * data.num_img) + 2;
ind = [r_ind, g_ind, b_ind];
img_tar = img_tar(:, :, ind);
img_ref = img_ref(:, :, ind);
clear ind;

% reshape the data to a (3 * num_img X num_pixel) matrix
OV_tar = reshape(img_tar, [], size(img_tar, 3))';
OV_ref = reshape(img_ref, [], size(img_ref, 3))';

OV_tar_ind = find(mask_tar(:) > 0);
OV_tar = OV_tar(:, OV_tar_ind);

OV_ref_ind = find(mask_ref(:) > 0);
OV_ref = OV_ref(:, OV_ref_ind);

ov_tar = double(OV_tar);
ov_ref = double(OV_ref);
for i = 1 : 3
    OV_tar_chan = ov_tar(1 + (i - 1) * data.num_img : i * data.num_img, :);
    ov_tar(1 + (i - 1) * data.num_img : i * data.num_img, :) = OV_tar_chan ./ repmat(sqrt(sum(OV_tar_chan.^2)), data.num_img, 1);
    OV_ref_chan = ov_ref(1 + (i - 1) * data.num_img : i * data.num_img, :);
    ov_ref(1 + (i - 1) * data.num_img : i * data.num_img, :) = OV_ref_chan ./ repmat(sqrt(sum(OV_ref_chan.^2)), data.num_img, 1);
end
%% old code
% num_img = data.num_img;
% 
% mask_target = imread(data.name_mask_target);
% mask_target(mask_target > 0) = 1;
% mask_ref = imread(data.name_mask_ref);
% range_radius = [150, 170]; % the range of radius is a user-defined parameter
% [center, radius, ~] = imfindcircles(mask_ref, range_radius);
% mask_ref(mask_ref > 0) = 1;
% 
% img_target = cell(num_img, 1);
% img_ref = cell(num_img, 1);
% 
% for i = 1 : data.num_img
%     [img, c_map] = imread(data.name_img_target{i});
%     if(size(img, 3) == 1)
%         img = ind2rgb(img, c_map); % convert grey to rgb
%     end
%     size_img = size(img);
%     img = reshape(img, [], 3);
%     img(mask_target == 0, :) = 0;
%     img_target{i} = reshape(img, size_img);
% 
%     [img, c_map] = imread(data.name_img_ref{i});
% 
%     if(size(img, 3) == 1)
%         img = ind2rgb(img, c_map); % convert grey to rgb
%     end
%     size_img = size(img);
%     img = reshape(img, [], 3);
%     img(mask_ref == 0, :) = 0;
%     img_ref{i} = reshape(img, size_img);
% 
% %     img = [img_ref{i}, img_target{i}];
% %     imshow(img);
% end
% 
% %% construct OV
% size_mask_target = sum(sum(mask_target ~= 0));
% size_mask_ref = sum(sum(mask_ref ~= 0));
% 
% r_target = zeros(num_img, size_mask_target);
% g_target = zeros(num_img, size_mask_target);
% b_target = zeros(num_img, size_mask_target);
% r_ref = zeros(num_img, size_mask_ref);
% g_ref = zeros(num_img, size_mask_ref);
% b_ref = zeros(num_img, size_mask_ref);
% 
% ind_target = find(mask_target ~= 0);
% ind_ref = find(mask_ref ~= 0);
% res_target = size(img_target{1}, 1) * size(img_target{1}, 2);
% res_ref = size(img_ref{1}, 1) * size(img_ref{1}, 2);
% 
% for i = 1 : num_img
%    r_target(i, :) = img_target{i}(ind_target)';
%    g_target(i, :) = img_target{i}(res_target + ind_target)';
%    b_target(i, :) = img_target{i}(2 * res_target + ind_target)';
%    r_ref(i, :) = img_ref{i}(ind_ref)';
%    g_ref(i, :) = img_ref{i}(res_ref + ind_ref)';
%    b_ref(i, :) = img_ref{i}(2 * res_ref + ind_ref)';
% end
% 
% r_ref = r_ref ./ repmat(sqrt(sum(r_ref.^2)), num_img, 1);
% g_ref = g_ref ./ repmat(sqrt(sum(g_ref.^2)), num_img, 1);
% b_ref = b_ref ./ repmat(sqrt(sum(b_ref.^2)), num_img, 1);
% r_target = r_target ./ repmat(sqrt(sum(r_target.^2)), num_img, 1);
% g_target = g_target ./ repmat(sqrt(sum(g_target.^2)), num_img, 1);
% b_target = b_target ./ repmat(sqrt(sum(b_target.^2)), num_img, 1);
% ov_ref = [r_ref; g_ref; b_ref];
% ov_target = [r_target; g_target; b_target];
%}
%% correspondence
build_params.algorithm = 'kdtree';
build_params.trees = ceil(log2(3 * double(data.num_img)));
[index, ~, ~] = flann_build_index(ov_ref, build_params);

k = 1;
search_params.checks = 3 * num_img;
[ind_corr, ~] = flann_search(index, ov_target, k, search_params);

%% normal estimation
[y_ref, x_ref] = find(mask_ref);
n_ref_vec = zeros(size_mask_ref, 3);
n_ref_vec(:, 1) = x_ref - repmat(center(1), size_mask_ref, 1);
n_ref_vec(:, 2) = y_ref - repmat(center(2), size_mask_ref, 1);

r = max(sqrt(n_ref_vec(:, 1).^2 + n_ref_vec(:, 2).^2));
if(radius < r)
    radius = r + 2; % why 2?
end

n_ref_vec(:, 3) = sqrt(repmat(radius, size_mask_ref, 1).^2 - n_ref_vec(:, 1).^2 - n_ref_vec(:, 2).^2);
n_ref_vec = n_ref_vec ./ radius;
n_target_vec = n_ref_vec(ind_corr, :);

% reshape normal
n_map_ref = zeros([size(mask_ref), 3]);
n_map_ref(ind_ref) = n_ref_vec(:, 1);
n_map_ref(res_ref + ind_ref) = n_ref_vec(:, 2);
n_map_ref(2 * res_ref + ind_ref) = n_ref_vec(:, 3);

n_map_target = zeros([size(mask_target), 3]);
n_map_target(ind_target) = n_target_vec(:, 1);
n_map_target(res_target + ind_target) = n_target_vec(:, 2);
n_map_target(2 * res_target + ind_target) = n_target_vec(:, 3);

%% show surface normal
show_surfNorm(img_ref{1}, n_map_ref, 3);
show_surfNorm(img_target{1}, n_map_target, 3);

%% surface integration
% n_z = n_map_ref(:, :, 3);
% n_z(n_z == 0) = 1;
% n_x = -n_map_ref(:, :, 1) ./ n_z;
% n_y = -n_map_ref(:, :, 2) ./ n_z;
% h_ref = integrate_horn2(n_x, n_y, double(mask_ref), 10000, 1);
% write_ply('ref.ply', h_ref, uint8(255 * img_ref{1}));

n_z = n_map_target(:, :, 3);
n_z(n_z == 0) = 1;
n_x = n_map_target(:, :, 1) ./ n_z;
n_y = n_map_target(:, :, 2) ./ n_z;
h_target = integrate_horn2(n_x, n_y, double(mask_target), 15000, 1);
write_ply('target.ply', h_target, uint8(255 * img_target{1}));