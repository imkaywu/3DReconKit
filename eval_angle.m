mask = imread(sprintf('%s/gt/mask.bmp', data.rdir));
mask(mask > 0) = 1;
norm_map_rgb_gt = imread(sprintf('%s/gt/normal.jpg', data.rdir));
norm_map_gt = decode(norm_map_rgb_gt, mask);
show_surfNorm(255 * mask, norm_map_gt, 10);

if(~exist('norm_map', 'var'))
    norm_map_rgb = imread(sprintf('%s/normal.jpg', data.dir));
    norm_map = decode(norm_map_rgb, mask);
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

prct = 0.9;
dot_norm = dot(norm_gt, norm, 2);
angle = (180 .* acos(dot_norm)) ./ pi;
angle = real(angle);
angle_sort = sort(angle);
acc_ang = angle_sort(round(prct * numel(angle)));
mean_ang = mean(angle);
var_ang = var(angle);
std_ang = std(angle);
max_ang = max(angle);

fprintf('accuracy: %.08f\n', acc_ang);
fprintf('mean angle: %.08f\n', mean_ang);
fprintf('var angle: %.08f\n', var_ang);
fprintf('std angle: %.08f\n', std_ang);
fprintf('max angle: %.08f\n', max_ang);

fid = fopen([data.dir, '/result.txt'], 'wt');
fprintf(fid, 'accuracy: %.08f\nmean angle: %.08f\nvar angle: %.08f\nstd angle: %.08f\nmax angle: %.08f\n', acc_ang, mean_ang, var_ang, std_ang, max_ang);
