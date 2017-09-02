close all;
addpath(genpath('C:\Users\Admin\Documents\3D_Recon\Data\synthetic_data\3DRecon_Algo_Eval\algo\PS\EPS'));
name = '0808';
norm_map_rgb = imread(sprintf('%s_normal.png', name));
mask = imread('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/sphere/gt/mask.bmp');
mask(mask > 0) = 1;
norm_map = decode(norm_map_rgb, mask);

% depth map
% n = norm_map;
% p = -n(:,:,1) ./ n(:,:,3);
% q = -n(:,:,2) ./ n(:,:,3);
% p(isnan(p)) = 0;
% q(isnan(q)) = 0;
% Z = DepthFromGradient(p, q);
% % Visualize depth map.
% Z(isnan(n(:,:,1)) | isnan(n(:,:,2)) | isnan(n(:,:,3))) = NaN;
% surf(Z, 'EdgeColor', 'None', 'FaceColor', [0.5 0.5 0.5]);
% axis equal; camlight;
% view(-75, 30);
% saveas(gcf, sprintf('%s_dmap.png', name));
% close;

% boxplot
addpath C:\Users\Admin\Documents\3D_Recon\Data\synthetic_data\3DRecon_Algo_Eval\eval\include\aboxplot
norm_map_gt_rgb = imread(sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/sphere/gt/ps.png'));
norm_map_gt = decode(norm_map_gt_rgb, mask);

nmask = sum(sum(mask));
norm_gt = zeros(nmask, 3);
norm = zeros(nmask, 3);
for c = 1 : 3
    norm_tmp = norm_map_gt(:, :, c);
    norm_gt(:, c) = norm_tmp(mask > 0);
    
    norm_tmp = norm_map(:, :, c);
    norm(:, c) = norm_tmp(mask > 0);
end

prtl = 0.99;
dot_norm = dot(norm_gt, norm, 2);
angle = (180 .* acos(dot_norm)) ./ pi;
angle = real(angle);
angle_sort = sort(angle);
angle_prtl = angle_sort(1 : round(prtl * numel(angle)));

rnd = 100 + 1 .* randn(size(angle_prtl));
aboxplot([angle_prtl, rnd]);
set(gca,'XTickLabel',{name})
xlim([0.5, 1.5]);
ylim([0, 10]);
ylabel('angular error', 'FontSize', 24);
set(gcf, 'units', 'points', 'position', [0, 0, 100, 300], 'PaperUnits', 'points', 'PaperPosition', [0, 0, 100, 300]);
saveas(gcf, sprintf('%s_ang_error.eps', name), 'epsc2');
close;