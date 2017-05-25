% analyze the dependency between any two properties
clear, clc, close all;
addpath(genpath('../include/'));

obj_name = 'sphere';
algs = {'mvs', 'ps', 'sl'};
props = {'tex', 'alb', 'spec', 'rough', 'concav'};
ind_eff_props = logical([1, 1, 1, 0, 0; 0, 1, 1, 1, 0; 1, 0, 1, 1, 0]);
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
ref_dir = '../../ref_obj';
gt_dir = '../../groundtruth';
ind = 2 : 3 : 8;

mvs_acc_mat = zeros(3, 3, 3);
mvs_cmplt_mat = zeros(3, 3, 3);
sl_acc_mat = zeros(3, 3, 3);
sl_cmplt_mat = zeros(3, 3, 3);
angle_cell = cell(3, 3, 3);

for ii = 1 : numel(ind)

for jj = 1 : numel(ind)

for kk = 1 : numel(ind)
    
    % mvs
    dir = sprintf('%s/train/mvs/%02d%02d%02d00', rdir, ind(ii), ind(jj), ind(kk));
    fid = fopen(sprintf('%s/result.txt', dir));
    fscanf(fid, '%s', 1); mvs_acc_mat(ii, jj, kk) = fscanf(fid, '%f', 1);
    fscanf(fid, '%s', 1); mvs_cmplt_mat(ii, jj, kk) = fscanf(fid, '%f', 1);
    
    % sl
    dir = sprintf('%s/train/sl/%02d%02d%02d00', rdir, ind(ii), ind(jj), ind(kk));
    fid = fopen(sprintf('%s/result.txt', dir));
    fscanf(fid, '%s', 1); sl_acc_mat(ii, jj, kk) = fscanf(fid, '%f', 1);
    fscanf(fid, '%s', 1); sl_cmplt_mat(ii, jj, kk) = fscanf(fid, '%f', 1);
    
    % ps
    dir = sprintf('%s/train/ps/00%02d%02d%02d', rdir, ind(ii), ind(jj), ind(kk));
    data.rdir = rdir;
    data.dir = dir;
    eval_angle;
    angle_cell{ii, jj, kk} = angle;
    clear norm_map

end % end of ii

end % end of jj

end % end of kk

n_colors = 9;
color = distinguishable_colors(n_colors);
legend_str = cell(2 * n_colors, 1);

%% plot mvs
% start for animation
for i = 1 : 3
    for j = 1 : 3
%         figure;
        for k = 1 : 3
            idx = 3 * (i - 1) + j;
            p1 = semilogy(ind(k) ./ 10, mvs_acc_mat(k, i, j), 'o'); hold on;
            set(p1, 'LineWidth', 2, 'Color', color(idx, :));
            p2 = semilogy(ind(k) ./ 10, mvs_cmplt_mat(k, i, j), '+'); hold on;
            set(p2, 'LineWidth', 2, 'Color', color(idx, :));
            xlim([0,1]);
            ylim([0.01, 1]);
            xlabel('tex');
            ylabel('accuracy/completeness');
            if(k==1)
            legend([p1, p2],...
                   sprintf('accuracy: alb(%0.2f), spec(%0.2f)', ind(i)/10, ind(j)/10),...
                   sprintf('completeness: alb(%0.2f), spec(%0.2f)', ind(i)/10, ind(j)/10),...
                   'Location', 'NorthWest');
            end
            if k>1
                eval(['p' num2str(2 * idx - 1)]) = semilogy(ind(k-1:k) ./ 10, mvs_acc_mat(k-1:k, i, j), '-'); hold on;
                set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 2, 'Color', color(idx, :));
                eval(['p' num2str(2 * idx)]) = semilogy(ind(k-1:k) ./ 10, mvs_cmplt_mat(k-1:k, i, j), '--'); hold on;
                set(eval(['p' num2str(2 * idx)]), 'LineWidth', 2, 'Color', color(idx, :));
            end
        end
%         close all;
    end
end
% end for animation
fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, mvs_acc_mat(:, i, j), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, mvs_cmplt_mat(:, i, j), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{1});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('mvs: %s and %s', props{2}, props{3}));
columnlegend(6,legend_str,'Northwest');
saveas(fig, sprintf('%s/result/mvs_train_00.eps', rdir), 'epsc2');
close(fig);

fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, mvs_acc_mat(i, :, j), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, mvs_cmplt_mat(i, :, j), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{2});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('mvs: %s and %s', props{1}, props{3}));
columnlegend(6,legend_str,'Northwest');
saveas(fig, sprintf('%s/result/mvs_train_01.eps', rdir), 'epsc2');
close(fig);

fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, reshape(mvs_acc_mat(i, j, :), 3, 1), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, reshape(mvs_cmplt_mat(i, j, :), 3, 1), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{3});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('mvs: %s and %s', props{1}, props{2}));
columnlegend(6,legend_str,'Northwest');
saveas(fig, sprintf('%s/result/mvs_train_02.eps', rdir), 'epsc2');
close(fig);

%% plot sl
fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, sl_acc_mat(:, i, j), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, sl_cmplt_mat(:, i, j), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{1});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('sl: %s and %s', props{2}, props{3}));
columnlegend(6,legend_str,'South');
saveas(fig, sprintf('%s/result/sl_train_00.eps', rdir), 'epsc2');
close(fig);

fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, sl_acc_mat(i, :, j), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, sl_cmplt_mat(i, :, j), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{2});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('sl: %s and %s', props{1}, props{3}));
columnlegend(6,legend_str,'South');
saveas(fig, sprintf('%s/result/sl_train_01.eps', rdir), 'epsc2');
close(fig);

fig = figure;
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        eval(['p' num2str(2 * idx - 1)]) = semilogy(ind ./ 10, reshape(sl_acc_mat(i, j, :), 3, 1), 'ro-'); hold on;
        set(eval(['p' num2str(2 * idx - 1)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx - 1} = sprintf('%02d%02d', ind(i), ind(j));
        eval(['p' num2str(2 * idx)]) = semilogy(ind ./ 10, reshape(sl_cmplt_mat(i, j, :), 3, 1), 'ro--'); hold on;
        set(eval(['p' num2str(2 * idx)]), 'LineWidth', 1.5, 'Color', color(idx, :));
        legend_str{2 * idx} = sprintf('%02d%02d', ind(i), ind(j));
    end
end
xlabel(props{3});
ylabel('accuracy/completeness');
xlim([0, 1]);
title(sprintf('sl: %s and %s', props{1}, props{2}));
columnlegend(6,legend_str,'South');
saveas(fig, sprintf('%s/result/sl_train_02.eps', rdir), 'epsc2');
close(fig);

%% plot ps
fig = figure;
x = []; y = []; z = [];
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        x = [x, angle_cell{1, i, j}];
        y = [y, angle_cell{2, i, j}];
        z = [z, angle_cell{3, i, j}];
        legend_str{idx} = sprintf('%.02f, %.02f', ind(i)/10, ind(j)/10);
    end
end
angle_plot = zeros(size(x, 2), size(x, 1), 3);
angle_plot(:, :, 1) = x';
angle_plot(:, :, 2) = y';
angle_plot(:, :, 3) = z';
aboxplot(angle_plot, 'labels', [0.2 0.5, 0.8]);
xlabel(props{2});
ylabel('angle difference');
title(sprintf('ps: %s and %s', props{3}, props{4}));
columnlegend(3,legend_str,'North');
saveas(fig, sprintf('%s/result/ps_train_00.eps', rdir), 'epsc2');
close(fig);

fig = figure;
x = []; y = []; z = [];
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        x = [x, angle_cell{i, 1, j}];
        y = [y, angle_cell{i, 2, j}];
        z = [z, angle_cell{i, 3, j}];
        legend_str{idx} = sprintf('%.02f, %.02f', ind(i)/10, ind(j)/10);
    end
end
angle_plot = zeros(size(x, 2), size(x, 1), 3);
angle_plot(:, :, 1) = x';
angle_plot(:, :, 2) = y';
angle_plot(:, :, 3) = z';
aboxplot(angle_plot, 'labels', [0.2 0.5, 0.8]);
xlabel(props{3});
ylabel('angle difference');
title(sprintf('ps: %s and %s', props{2}, props{4}));
columnlegend(3,legend_str,'North');
saveas(fig, sprintf('%s/result/ps_train_01.eps', rdir), 'epsc2');
close(fig);

fig = figure;
x = []; y = []; z = [];
for i = 1 : 3
    for j = 1 : 3
        idx = 3 * (i - 1) + j;
        x = [x, angle_cell{i, j, 1}];
        y = [y, angle_cell{i, j, 2}];
        z = [z, angle_cell{i, j, 3}];
        legend_str{idx} = sprintf('%.02f, %.02f', ind(i)/10, ind(j)/10);
    end
end
angle_plot = zeros(size(x, 2), size(x, 1), 3);
angle_plot(:, :, 1) = x';
angle_plot(:, :, 2) = y';
angle_plot(:, :, 3) = z';
aboxplot(angle_plot, 'labels', [0.2 0.5, 0.8]);
xlabel(props{4});
ylabel('angle difference');
title(sprintf('ps: %s and %s', props{2}, props{3}));
columnlegend(3,legend_str,'North');
saveas(fig, sprintf('%s/result/ps_train_02.eps', rdir), 'epsc2');
close(fig);



% legend(sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.2),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.2),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.5),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.5),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.8),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.2, props{3}, 0.8),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.2),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.2),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.5),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.5),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.8),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.5, props{3}, 0.8),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.2),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.2),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.5),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.5),...
%        sprintf('accuracy: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.8),...
%        sprintf('completeness: %s (%.02f) %s (%.02f)', props{2}, 0.8, props{3}, 0.8),...
%        'Location', 'west');