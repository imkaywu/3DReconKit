% analyze the dependency between any two properties
clear, clc, close all;
addpath('aboxplot');
obj_name = 'sphere';
alg_type = 'ps'; % change
prop_comb = 'spec_rough'; % change
prop_name{1} = 'specularity'; % change
prop_name{2} = 'roughness'; % change
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
idir = sprintf('%s/%s/%s', rdir, alg_type, prop_comb);

acc_mat = zeros(3, 3);
cmplt_mat = zeros(3, 3);
angle_mat = [];
ind = 2 : 3 : 8;
for i = 1 : numel(ind)
    for j = 1 : numel(ind)
        dir = sprintf('%s/%02d%02d', idir, ind(i), ind(j));
        fid = fopen(sprintf('%s/result.txt', dir));
        switch alg_type
        case {'mvs', 'sl', 'vh'}
            fscanf(fid, '%s', 1); acc_mat(i, j) = fscanf(fid, '%f', 1);
            fscanf(fid, '%s', 1); cmplt_mat(i, j) = fscanf(fid, '%f', 1);
        case 'ps'
%             fscanf(fid, '%s', 1); angle_mat(i, j, 1) = fscanf(fid, '%f', 1); % mean
%             fscanf(fid, '%s', 1); angle_mat(i, j, 2) = fscanf(fid, '%f', 1); % median
%             fscanf(fid, '%s', 1); angle_mat(i, j, 3) = fscanf(fid, '%f', 1); % var
%             fscanf(fid, '%s', 1); angle_mat(i, j, 4) = fscanf(fid, '%f', 1); % std
%             fscanf(fid, '%s', 1); angle_mat(i, j, 5) = fscanf(fid, '%f', 1); % max
%             fscanf(fid, '%s', 1); angle_mat(i, j, 6) = fscanf(fid, '%f', 1); % min
%             fscanf(fid, '%s', 1); angle_mat(i, j, 7) = fscanf(fid, '%f', 1); % accuracy
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
switch alg_type
case {'mvs', 'sl', 'vh'}
    % accuracy
    for i = 1 : numel(ind)
        eval(['p' num2str(i)]) = semilogy(ind ./ 10, acc_mat(:, i), 'ro-'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 3, 'Color', color(i, :)/255);
    end
    % completeness
    for i = 1 : numel(ind)
        eval(['p' num2str(i)]) = semilogy(ind ./ 10, cmplt_mat(:, i), 'ro--'); hold on;
        set(eval(['p' num2str(i)]), 'LineWidth', 3, 'Color', color(i, :)/255);
    end
    legend(sprintf('accuracy, %s: %.02f', prop_name{2}, ind(1)/10),...
           sprintf('accuracy, %s: %.02f', prop_name{2}, ind(2)/10),...
           sprintf('accuracy, %s: %.02f', prop_name{2}, ind(3)/10),...
           sprintf('completeness %s: %.02f', prop_name{2}, ind(1)/10),...
           sprintf('completeness %s: %.02f', prop_name{2}, ind(2)/10),...
           sprintf('completeness %s: %.02f', prop_name{2}, ind(3)/10),...
           'Location', 'west');
    xlabel(prop_name{1});
    ylabel('accuracy/completeness');
    xlim([0, 1]);
    title(sprintf('%s: %s and %s', alg_type, prop_name{1}, prop_name{2}));
    if(~exist(sprintf('%s/images', rdir), 'dir'))
        mkdir(sprintf('%s/images', rdir));
    end
    saveas(fig, sprintf('%s/images/%s_%s.eps', rdir, alg_type, prop_comb), 'epsc2');
case 'ps'
    % angle difference
    if(~exist(sprintf('%s/images', rdir), 'dir'))
        mkdir(sprintf('%s/images', rdir));
    end
    angle_plot = zeros(size(angle_mat, 2) / 3, size(angle_mat, 1), 3);
    angle_plot(:, :, 1) = angle_mat(:, 1 : 3)';
    angle_plot(:, :, 2) = angle_mat(:, 4 : 6)';
    angle_plot(:, :, 3) = angle_mat(:, 7 : 9)';
    aboxplot(angle_plot, 'labels', [0.2 0.5, 0.8]);
    xlabel(prop_name{1});
    ylabel('angle difference');
    title(sprintf('%s: %s and %s', alg_type, prop_name{1}, prop_name{2}));
    legend(sprintf('%s: %.02f', prop_name{2}, ind(1)/10), ...
           sprintf('%s: %.02f', prop_name{2}, ind(2)/10), ...
           sprintf('%s: %.02f', prop_name{2}, ind(3)/10), ...
           'Location', 'best');
    saveas(fig, sprintf('%s/images/%s_%s.eps', rdir, alg_type, prop_comb), 'epsc2');
end
