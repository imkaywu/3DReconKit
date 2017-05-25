% analyze the dependency between any two properties
clear, clc, close all;
addpath(genpath('../include'));

obj_name = 'sphere';
algs = {'mvs', 'ps', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
ref_dir = '../../ref_obj';
gt_dir = '../../groundtruth';
ind = 2 : 3 : 8;

acc_mat = zeros(3, 3);
cmplt_mat = zeros(3, 3);
angle_mat = [];

for aa = 1

idir = sprintf('%s/%s', rdir, algs{aa});

for ii = 1
    
for jj = 3

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algs{aa}

case {'mvs', 'sl', 'vh'}
    
    for i = 1 : numel(ind)
        for j = 1 : numel(ind)
            dir = sprintf('%s/%s/%02d%02d', idir, prop_pair, ind(i), ind(j));
            fid = fopen(sprintf('%s/result.txt', dir));
            fscanf(fid, '%s', 1); acc_mat(i, j) = fscanf(fid, '%f', 1);
            fscanf(fid, '%s', 1); cmplt_mat(i, j) = fscanf(fid, '%f', 1);
        end
    end
case 'ps'
    angle_mat = [];
    for i = 1 : numel(ind)
        for j = 1 : numel(ind)
            dir = sprintf('%s/%s/%02d%02d', idir, prop_pair, ind(i), ind(j));
            data.rdir = rdir;
            data.dir = dir;
            eval_angle;
            angle_mat = [angle_mat, angle];
            clear norm_map
        end
    end
end

color = [241, 90, 90;
         240, 196, 25;
         78, 186, 111];
fig = figure;

switch algs{aa}

case {'mvs', 'sl', 'vh'}
    %{
    % for animation
    for i = 1 : numel(ind)
        subplot(2,1,1);
        eval(['p' num2str(i)]) = semilogy(ind(1)/10, acc_mat(1, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        xlim([0, 1]); ylim([0.01, 1]);
        xlabel(props{ii});
        ylabel('accuracy');
        legend(sprintf('%s: %.02f', props{jj}, ind(1)/10),...
               sprintf('%s: %.02f', props{jj}, ind(2)/10),...
               sprintf('%s: %.02f', props{jj}, ind(3)/10));
        subplot(2,1,2);
        eval(['p' num2str(i)]) = semilogy(ind(1)/10, cmplt_mat(1, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        xlim([0, 1]); ylim([0.01, 1]);
        xlabel(props{ii});
        ylabel('completeness');
        legend(sprintf('%s: %.02f', props{jj}, ind(1)/10),...
               sprintf('%s: %.02f', props{jj}, ind(2)/10),...
               sprintf('%s: %.02f', props{jj}, ind(3)/10));
    end
    for i = 1 : numel(ind)
        subplot(2,1,1);
        eval(['p' num2str(i)]) = semilogy(ind(2)/10, acc_mat(2, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        subplot(2,1,2);
        eval(['p' num2str(i)]) = semilogy(ind(2)/10, cmplt_mat(2, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
    end
    for i = 1 : numel(ind)
        subplot(2,1,1);
        eval(['p' num2str(i)]) = semilogy([ind(1), ind(2)]/10, acc_mat(1:2, i), '-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        subplot(2,1,2);
        eval(['p' num2str(i)]) = semilogy([ind(1), ind(2)]/10, cmplt_mat(1:2, i), '-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
    end
    for i = 1 : numel(ind)
        subplot(2,1,1);
        eval(['p' num2str(i)]) = semilogy(ind(3)/10, acc_mat(3, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        subplot(2,1,2);
        eval(['p' num2str(i)]) = semilogy(ind(3)/10, cmplt_mat(3, i), 'o'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
    end
    for i = 1 : numel(ind)
        subplot(2,1,1);
        eval(['p' num2str(i)]) = semilogy([ind(2), ind(3)]/10, acc_mat(2:3, i), '-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
        subplot(2,1,2);
        eval(['p' num2str(i)]) = semilogy([ind(2), ind(3)]/10, cmplt_mat(2:3, i), '-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 2, 'Color', color(i, :)/255);
    end
    %}
    % accuracy
    for i = 1 : numel(ind)
        eval(['p' num2str(i)]) = semilogy(ind ./ 10, acc_mat(:, i), 'ro-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 1, 'Color', color(i, :)/255);
    end
    % completeness
    for i = 1 : numel(ind)
        eval(['p' num2str(i)]) = semilogy(ind ./ 10, cmplt_mat(:, i), 'ro--'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 1, 'Color', color(i, :)/255);
    end
    legend(sprintf('accuracy, %s: %.02f', props{jj}, ind(1)/10),...
           sprintf('accuracy, %s: %.02f', props{jj}, ind(2)/10),...
           sprintf('accuracy, %s: %.02f', props{jj}, ind(3)/10),...
           sprintf('completeness %s: %.02f', props{jj}, ind(1)/10),...
           sprintf('completeness %s: %.02f', props{jj}, ind(2)/10),...
           sprintf('completeness %s: %.02f', props{jj}, ind(3)/10),...
           'Location', 'west');
    xlabel(props{ii});
    ylabel('accuracy/completeness');
    xlim([0, 1]);
    title(sprintf('%s: %s and %s', algs{aa}, props{ii}, props{jj}));
    if(~exist(sprintf('%s/result', rdir), 'dir'))
        mkdir(sprintf('%s/result', rdir));
    end
    saveas(fig, sprintf('%s/result/%s_%s.eps', rdir, algs{aa}, prop_pair), 'epsc2');

case 'ps'
    % angle difference
    if(~exist(sprintf('%s/result', rdir), 'dir'))
        mkdir(sprintf('%s/result', rdir));
    end
    angle_plot = zeros(size(angle_mat, 2) / 3, size(angle_mat, 1), 3);
    angle_plot(:, :, 1) = angle_mat(:, 1 : 3)';
    angle_plot(:, :, 2) = angle_mat(:, 4 : 6)';
    angle_plot(:, :, 3) = angle_mat(:, 7 : 9)';
    aboxplot(angle_plot, 'labels', [0.2 0.5, 0.8]);
    xlabel(props{ii});
    ylabel('angle difference');
    title(sprintf('%s: %s and %s', algs{aa}, props{ii}, props{jj}));
    legend(sprintf('%s: %.02f', props{jj}, ind(1)/10), ...
           sprintf('%s: %.02f', props{jj}, ind(2)/10), ...
           sprintf('%s: %.02f', props{jj}, ind(3)/10), ...
           'Location', 'best');
    saveas(fig, sprintf('%s/result/%s_%s.eps', rdir, algs{aa}, prop_pair), 'epsc2');
end

end % end of jj

end % enf of ii

end % enf of algs
