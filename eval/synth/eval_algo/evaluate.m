clear, clc, close all;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
set_path;

obj_name = 'sphere';
prop_name = {'texture', 'albedo', 'specularity', 'roughness'};
ind = 2 : 3 : 8;

cmplt_prct = 0.4; % 0.6 used in test analysis
acc_map_mvs = zeros(3, 3);
cmplt_map_mvs = zeros(3, 3);
acc_map_sl = zeros(3, 3);
cmplt_map_sl = zeros(3, 3);
ang_map_ave = zeros(3, 3);
ang_map_var = zeros(3, 3);

% sc
idir = sprintf('%s/eval_algo/sc', rdir);
fid = fopen(sprintf('%s/result.txt', idir));
fscanf(fid, '%s', 1); acc_map_bl = fscanf(fid, '%f', 1);
fscanf(fid, '%s', 1); cmplt_map_bl = fscanf(fid, '%f', 1);

% ps_baseline
idir = sprintf('%s/eval_algo/ps_baseline', rdir);
data.rdir = rdir;
data.idir = idir;
eval_angle;
ang_map_ave_bl = median(angle_prtl);
ang_map_var_bl = quantile(angle_prtl, 0.75) - quantile(angle_prtl, 0.25);
clear norm_map;

for ii = 1 : numel(ind)

for jj = 1 : numel(ind)

for kk = 1 : numel(ind)
    
    % mvs
    idir = sprintf('%s/eval_algo/mvs/%02d%02d%02d00', rdir, ind(ii), ind(jj), ind(kk));
    fid = fopen(sprintf('%s/result.txt', idir));
    fscanf(fid, '%s', 1); acc_map_mvs(4-jj, kk) = fscanf(fid, '%f', 1);
    fscanf(fid, '%s', 1); cmplt_map_mvs(4-jj, kk) = fscanf(fid, '%f', 1);
    
    % sl
    idir = sprintf('%s/eval_algo/sl/00%02d%02d%02d', rdir, ind(ii), ind(jj), ind(kk));
    fid = fopen(sprintf('%s/result.txt', idir));
    fscanf(fid, '%s', 1); acc_map_sl(4-jj, kk) = fscanf(fid, '%f', 1);
    fscanf(fid, '%s', 1); cmplt_map_sl(4-jj, kk) = fscanf(fid, '%f', 1);
    
    % ps
    idir = sprintf('%s/eval_algo/ps/00%02d%02d%02d', rdir, ind(ii), ind(jj), ind(kk));
    data.rdir = rdir;
    data.idir = idir;
    eval_angle;
    ang_map_ave(4-jj, kk) = median(angle_prtl);
    ang_map_var(4-jj, kk) = quantile(angle_prtl, 0.75) - quantile(angle_prtl, 0.25);
    clear norm_map

end % end of ii

end % end of jj

acc_map_mvs = -(acc_map_mvs - acc_map_bl);
cmplt_map_mvs = cmplt_map_mvs - cmplt_prct*cmplt_map_bl;
ang_map_ave = -(ang_map_ave - ang_map_ave_bl);
ang_map_var = -(ang_map_var - ang_map_var_bl);
acc_map_sl = -(acc_map_sl - acc_map_bl);
cmplt_map_sl = cmplt_map_sl - cmplt_prct*cmplt_map_bl;

%% plot mvs
figure;
mincolor = min([acc_map_mvs(:); cmplt_map_mvs(:)]);
maxcolor = max([acc_map_mvs(:); cmplt_map_mvs(:)]);
subplot(1, 2, 1);
heatmap(acc_map_mvs, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{3});
ylabel(prop_name{2});
title(sprintf('accuracy\n%s: %0.2f', prop_name{1}, ind(ii)/10));
snapnow
subplot(1, 2, 2);
heatmap(cmplt_map_mvs, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{3});
ylabel(prop_name{2});
title(sprintf('completeness\n%s: %0.2f', prop_name{1}, ind(ii)/10));
hp = get(subplot(1, 2, 2), 'Position');
drawColorbar([], [], 'Colormap', 'parula', 'Colorbar', {hp}, 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
set(gcf, 'PaperPositionMode', 'auto', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 13, 6]);
if(~exist(sprintf('%s/result', rdir), 'dir'))
    mkdir(sprintf('%s/result', rdir));
end
print(sprintf('%s/result/mvs_%s_%02d', rdir, prop_name{1}, ind(ii)), '-depsc2', '-r0');

%% plot ps
figure;
mincolor = min([ang_map_ave(:); ang_map_var(:)]);
maxcolor = max([ang_map_ave(:); ang_map_var(:)]);
subplot(1, 2, 1);
heatmap(ang_map_ave, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{4});
ylabel(prop_name{3});
title(sprintf('mean of angular error\n%s: %0.2f', prop_name{2}, ind(ii)/10));
subplot(1, 2, 2);
heatmap(ang_map_var, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{4});
ylabel(prop_name{3});
title(sprintf('std of angular error\n%s: %0.2f', prop_name{2}, ind(ii)/10));
hp = get(subplot(1, 2, 2), 'Position');
drawColorbar([], [], 'Colormap', 'parula', 'Colorbar', {hp}, 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
set(gcf, 'PaperPositionMode', 'auto', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 13, 6]);
if(~exist(sprintf('%s/result', rdir), 'dir'))
    mkdir(sprintf('%s/result', rdir));
end
print(sprintf('%s/result/ps_%s_%02d', rdir, prop_name{2}, ind(ii)), '-depsc2', '-r0');

%% plot sl
figure;
mincolor = min([acc_map_sl(:); cmplt_map_sl(:)]);
maxcolor = max([acc_map_sl(:); cmplt_map_sl(:)]);
subplot(1, 2, 1);
heatmap(acc_map_sl, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{4});
ylabel(prop_name{3});
title(sprintf('accuracy\n%s: %0.2f', prop_name{2}, ind(ii)/10));
snapnow
subplot(1, 2, 2);
heatmap(cmplt_map_sl, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
xlabel(prop_name{4});
ylabel(prop_name{3});
title(sprintf('completeness\n%s: %0.2f', prop_name{2}, ind(ii)/10));
hp = get(subplot(1, 2, 2), 'Position');
drawColorbar([], [], 'Colormap', 'parula', 'Colorbar', {hp}, 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
set(gcf, 'PaperPositionMode', 'auto', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 13, 6]);
if(~exist(sprintf('%s/result', rdir), 'dir'))
    mkdir(sprintf('%s/result', rdir));
end
print(sprintf('%s/result/sl_%s_%02d', rdir, prop_name{2}, ind(ii)), '-depsc2', '-r0');

end % end of kk

unset_path;
rmpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));