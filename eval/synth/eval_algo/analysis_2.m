% plot the performance of all the techniques under the same condition for sphere
% not used
clear; clc; close all;
addpath('../include/aboxplot');
rdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/sphere';
algs = {'mvs', 'ps', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'}; 
alg_prop = logical([1, 1, 1, 0; 0, 1, 1, 1; 1, 0, 1, 1]); % order: mvs, ps, sl
ind_prop = [2, 5, 8];

acc_mat = zeros(3, 2);
cmplt_mat = zeros(3, 2);
color = [241, 90, 90;
         240, 196, 25;
         78, 186, 111;
         34, 53, 122;
         67, 43, 32;
         75, 124, 45];

for ind_1 = ind_prop
    for ind_2 = ind_prop
        for ind_3 = ind_prop
            ii = 1;
            angle_mat = [];
            for ind_4 = ind_prop
            % mvs
            dir = sprintf('%s/train/%s/%02d%02d%02d00', rdir, algs{1}, ind_1, ind_2, ind_3);
            fid = fopen(sprintf('%s/result.txt', dir));
            fscanf(fid, '%s', 1); acc_mat(ii, 1) = fscanf(fid, '%f', 1);
            fscanf(fid, '%s', 1); cmplt_mat(ii, 1) = fscanf(fid, '%f', 1);
            
            % ps
            data.rdir = rdir;
            data.dir = sprintf('%s/train/%s/00%02d%02d%02d', rdir, algs{2}, ind_2, ind_3, ind_4);
            eval_angle;
            angle_mat = [angle_mat, angle];
            clear norm_map

            % sl
            dir = sprintf('%s/train/%s/%02d%02d%02d00', rdir, algs{3}, ind_1, ind_3, ind_4);
            fid = fopen(sprintf('%s/result.txt', dir));
            fscanf(fid, '%s', 1); acc_mat(ii, 2) = fscanf(fid, '%f', 1);
            fscanf(fid, '%s', 1); cmplt_mat(ii, 2) = fscanf(fid, '%f', 1);
            ii = ii + 1;
            end
            
            figure;
            subplot(1, 2, 1);
            for ii = 1 : 2
                % accuracy
                eval(['p' num2str(2 * ii - 1)]) = semilogy(ind_prop ./ 10, acc_mat(:, ii), 'ro-'); hold on;
                set(eval(['p' num2str(2 * ii - 1)]), 'LineWidth', 3, 'Color', color(2 * ii - 1, :)/255);

                % completeness
                eval(['p' num2str(2 * ii)]) = semilogy(ind_prop ./ 10, cmplt_mat(:, ii), 'ro--'); hold on;
                set(eval(['p' num2str(2 * ii)]), 'LineWidth', 3, 'Color', color(2 * ii - 1, :)/255);
            end
            xlabel('roughness');
            ylabel('accuracy/completeness');
            xlim([0, 1]);
            legend('mvs-accuracy', 'mvs-completeness', 'sl-accuracy', 'sl-completeness', 'Location', 'best');
            
            subplot(1, 2, 2);
            xlabel('roughness');
            ylabel('angle difference');
            aboxplot(angle_mat, 'labels', [0.2, 0.5, 0.8]);
            
            suptitle(sprintf('tex,alb,spec: %02d%02d%02d', ind_1, ind_2, ind_3));
            
            fprintf('prop: %02d%02d%02d\n', ind_1, ind_2, ind_3);
            close all;
        end
    end
end
     
