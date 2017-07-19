% not used
clear; clc; close all;
addpath('../include/aboxplot');

rdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/sphere';
algs = {'mvs', 'ps', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
alg_prop = logical([1, 1, 1, 0, 0; 0, 1, 1, 1, 0; 0, 1, 1, 1, 0]); % order: mvs, ps, sl
in_prop = [2, 2, 2, 2; 2, 2, 8, 8; 8, 2, 2, 8];
ind = [2, 5, 8];

color = [241, 90, 90;
         240, 196, 25;
         78, 186, 111;
         34, 53, 122;
         67, 43, 32;
         75, 124, 45];

mvs_acc = zeros(3, 4);
mvs_cmplt = zeros(3, 4);

sl_acc = zeros(3, 4);
sl_cmplt = zeros(3, 4);

for i = 2 : size(in_prop, 1)
    ind = in_prop(i, :);
    for j = 1 : 4
        ind_1 = repmat(ind, 3, 1);
        ind_1(:, j) = (2 : 3 : 8)';
        angle_mat = [];
        for k = 1 : 3
            for aa = 1 : 3
                eff_prop = alg_prop(aa, :);
                ind_2 = find(eff_prop);
                prop_comb = [props{ind_2(1)}, '_', props{ind_2(2)}, '_', props{ind_2(3)}];
                switch algs{aa}
                    case 'mvs'
                        dir = sprintf('%s/mvs/%s/%02d%02d%02d', rdir, prop_comb, ind_1(k, ind_2(1)), ind_1(k, ind_2(2)), ind_1(k, ind_2(3)));
                        fid = fopen(sprintf('%s/result.txt', dir));
                        fscanf(fid, '%s', 1); mvs_acc(k, j) = fscanf(fid, '%f', 1);
                        fscanf(fid, '%s', 1); mvs_cmplt(k, j) = fscanf(fid, '%f', 1);
                    case 'ps'
                        data.dir = sprintf('%s/ps/%s/%02d%02d%02d', rdir, prop_comb, ind_1(k, ind_2(1)), ind_1(k, ind_2(2)), ind_1(k, ind_2(3)));
                        data.rdir = rdir;
                        eval_angle;
                        angle_mat = [angle_mat, angle];
                        clear norm_map
                    case 'sl'
                        dir = sprintf('%s/sl/%s/%02d%02d%02d', rdir, prop_comb, ind_1(k, ind_2(1)), ind_1(k, ind_2(2)), ind_1(k, ind_2(3)));
                        fid = fopen(sprintf('%s/result.txt', dir));
                        fscanf(fid, '%s', 1); sl_acc(k, j) = fscanf(fid, '%f', 1);
                        fscanf(fid, '%s', 1); sl_cmplt(k, j) = fscanf(fid, '%f', 1);
                end
            end
        end
        fig = figure;
        subplot(1, 2, 1);
        p1 = semilogy(ind ./ 10, mvs_acc(:, j), 'ro-'); hold on;
        p2 = semilogy(ind ./ 10, mvs_cmplt(:, j), 'ro--');
        p3 = semilogy(ind ./ 10, sl_acc(:, j), 'ro-');
        p4 = semilogy(ind ./ 10, sl_cmplt(:, j), 'ro--');
        set(p1, 'LineWidth', 1, 'Color', color(1, :)/255);
        set(p2, 'LineWidth', 1, 'Color', color(1, :)/255);
        set(p3, 'LineWidth', 1, 'Color', color(2, :)/255);
        set(p4, 'LineWidth', 1, 'Color', color(2, :)/255);
        legend('mvs-accuracy', ...
               'mvs-completeness', ...
               'sl-accuracy', ...
               'sl-completeness', ...
               'Location', 'west');
        xlabel(props{j});
        ylabel('accuracy/completeness');
        xlim([0,1]);
        ind_3 = ind;
        ind_3(j) =[];
        
        subplot(1, 2, 2);
        aboxplot(angle_mat, 'label', [0.2, 0.5, 0.8]);
        xlabel(props{j});
        ylabel('angle difference');
        switch j
            case 1
                suptitle(sprintf('alb-spec-rough:%02d%02d%02d', ind_3(1), ind_3(2), ind_3(3)));
            case 2
                suptitle(sprintf('tex-spec-rough:%02d%02d%02d', ind_3(1), ind_3(2), ind_3(3)));
            case 3
                suptitle(sprintf('tex-alb-rough:%02d%02d%02d', ind_3(1), ind_3(2), ind_3(3)));
            case 4
                suptitle(sprintf('tex-alb-spec:%02d%02d%02d', ind_3(1), ind_3(2), ind_3(3)));
        end
        saveas(fig, sprintf('C:/Users/Admin/Desktop/images/%02d%02d%02d%02d_%d.eps', in_prop(i, 1), in_prop(i, 2), in_prop(i, 3), in_prop(i, 4), j), 'epsc2');
    end
end