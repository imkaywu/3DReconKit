mask = imread(sprintf('%s/gt/mask.bmp', data.rdir));
mask(mask > 128) = 1;
norm_map_gt = imread(sprintf('%s/gt/normal.jpg', data.rdir));
norm_map_gt = double(norm_map_gt);
norm_map_gt(:, :, 1 : 2) = norm_map_gt(:, :, 1 : 2) * 2.0 / 255.0 - 1;
norm_map_gt(:, :, 3) = norm_map_gt(:, :, 3) / 255.0;
norm_map_gt(:, :, 2) = -norm_map_gt(:, :, 2);
mask_0_ind = find(mask == 0);
for i = 1 : 3
    norm_map_gt(mask_0_ind + (i - 1) * numel(mask)) = 0;
end
show_surfNorm(255 * mask, norm_map_gt, 10);

if(~exist('norm_map', 'var'))
    norm_map = imread(sprintf('%s/normal.jpg', data.dir));
end
show_surfNorm(255 * mask, norm_map, 10);

%% compute angle difference
nmask = sum(sum(mask));
norm_gt = zeros(nmask, 3);
norm = zeros(nmask, 3);
for i = 1 : 3
    norm_tmp = norm_map_gt(:, :, i);
    norm_gt(:, i) = norm_tmp(mask == 1);
    
    norm_tmp = norm_map(:, :, i);
    norm(:, i) = norm_tmp(mask == 1);
end

dot_norm = dot(norm_gt, norm, 2);
angle = (180 .* acos(dot_norm)) ./ pi;
angle = real(angle);
mean_ang = mean(angle);
var_ang = var(angle);
std_ang = std(angle);
max_ang = max(angle);

fprintf('mean angle: %.08f\n', mean_ang);
fprintf('var angle: %.08f\n', var_ang);
fprintf('std angle: %.08f\n', std_ang);
fprintf('max angle: %.08f\n', max_ang);

fid = fopen([dir, '/result.txt'], 'wt');
fprintf(fid, 'mean angle: %.08f\nvar angle: %.08f\nstd angle: %.08f\nmax angle: %.08f\n', mean_ang, var_ang, std_ang, max_ang);
