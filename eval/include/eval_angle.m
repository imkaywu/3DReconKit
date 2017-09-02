% addpath(genpath('C:\Users\Admin\Documents\3D_Recon\Photometric Stereo'));
mask = imread(sprintf('%s/gt/mask.bmp', data.rdir));
mask(mask > 0) = 1;
norm_map_rgb_gt = imread(sprintf('%s/gt/ps.png', data.rdir));
norm_map_gt = decode(norm_map_rgb_gt, mask);
% show_surfNorm(255 * mask, norm_map_gt, 10);

if(~exist('norm_map', 'var'))
    if(exist(sprintf('%s/normal.png', data.idir), 'file'))
        norm_map_rgb = imread(sprintf('%s/normal.png', data.idir));
    else
        norm_map_rgb = imread(sprintf('%s/normal.jpg', data.idir));
    end
    norm_map = decode(norm_map_rgb, mask);
end
% show_surfNorm(255 * mask, norm_map, 10);

%% compute angle difference
nmask = sum(sum(mask));
norm_gt = zeros(nmask, 3);
norm = zeros(nmask, 3);
for c = 1 : 3
    norm_tmp = norm_map_gt(:, :, c);
    norm_gt(:, c) = norm_tmp(mask == 1);
    
    norm_tmp = norm_map(:, :, c);
    norm(:, c) = norm_tmp(mask == 1);
end
clear norm_map
prtlprct = 0.99; % get rid of the top 1% angle error
accprct = 0.95;
dot_norm = dot(norm_gt, norm, 2);
angle = (180 .* acos(dot_norm)) ./ pi;
angle = real(angle);
angle_sort = sort(angle);
angle_prtl = angle_sort(1 : round(prtlprct * numel(angle)));
acc_ang = angle_sort(round(accprct * numel(angle_prtl)));
mean_ang = mean(angle_prtl);
median_ang = median(angle_prtl);
var_ang = var(angle_prtl);
std_ang = std(angle_prtl);
min_ang = min(angle_prtl);
max_ang = max(angle_prtl);

fprintf('mean angle: %.08f\n', mean_ang);
fprintf('median angle: %.08f\n', median_ang);
fprintf('var angle: %.08f\n', var_ang);
fprintf('std angle: %.08f\n', std_ang);
fprintf('max angle: %.08f\n', max_ang);
fprintf('min angle: %.08f\n', min_ang);
fprintf('accuracy: %.08f\n', acc_ang);

update_txt = 0;
if(update_txt || ~exist([data.idir, '/result.txt'], 'file'))
    fid = fopen([data.idir, '/result.txt'], 'wt');
    fprintf(fid, 'mean angle: %.08f\nmedian angle: %.08f\nvar angle: %.08f\nstd angle: %.08f\nmax angle: %.08f\nmin angle: %.08f\naccuracy: %.08f\n', mean_ang, median_ang, var_ang, std_ang, max_ang, min_ang, acc_ang);
    fclose(fid);
end
