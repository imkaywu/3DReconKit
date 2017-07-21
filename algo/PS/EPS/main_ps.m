% test if example based photometric stereo
close all;
clc;
%% data for binocular stereo
% data.dir = '../Data/Fixed-view PS/';
% addpath(data.dir);
% data.num_view = 2;
% data.num_img = 27;
% data.name_img_ref = cell(data.num_img, 1);
% data.name_img_target = cell(data.num_img, 1);
% n_map_target = cell(data.num_view, 1);
% 
% if(exist('ps_data.mat', 'file'))
%     load('ps_data.mat');
% else
%     for k = 1 : data.num_view
%         for i = 1 : data.num_img
%             if i <= 10
%                 data.name_img_ref{i} = [data.dir, '/', 'img_', num2str(k - 1), '_0', num2str(i - 1), '.BMP'];
%                 data.name_img_target{i} = [data.dir, '/', 'img_', num2str(k - 1), '_0', num2str(i - 1), '.BMP'];
%             else
%                 data.name_img_ref{i} = [data.dir, '/', 'img_', num2str(k - 1), '_', num2str(i - 1), '.BMP'];
%                 data.name_img_target{i} = [data.dir, '/', 'img_', num2str(k - 1), '_', num2str(i - 1), '.BMP'];
%             end
%         end
% 
%         data.name_mask_ref = [data.dir, '/mask_ref_', num2str(k - 1), '.BMP'];
%         data.name_mask_target = [data.dir, '/mask_target_', num2str(k - 1), '.BMP'];
% 
%         % normal estimation
%         exmp_based_ps;
%         n_map_target{k} = n_map_target;
%     end
%     save('ps_data.mat', 'n_map_target');
%     clear;
% end

%% data for single-view PS
% addpath('io');
% addpath('include');
% addpath('src');
% 
% data.dir = 'C:/Users/Admin/Documents/Data/WACV/ps/cup/'; % **
% data.update = 0;
% 
% fid = fopen([data.dir, 'files.txt'], 'r');
% num = textscan(fid, '%d', 10);
% 
% data.num_view = 1;
% data.num_img = num{1}(1);
% data.num_ref = num{1}(2);
% data.name_img_ref = cell(data.num_img, data.num_ref);
% data.name_img_tar = cell(data.num_img, 1);
% n_map_tar = cell(data.num_view, 1);
% 
% str = textscan(fid, '%s', (data.num_ref + 1) * data.num_img);
% 
% for i = 1 : (data.num_ref + 1) * data.num_img
%     if i <= data.num_img
%         data.name_img_ref{i, 1} = [data.dir, str{1}{i}];
%     elseif i <= data.num_ref * data.num_img
%         data.name_img_ref{i - data.num_img, 2} = [data.dir, str{1}{i}];
%     else
%         data.name_img_tar{i - data.num_ref * data.num_img} = [data.dir, str{1}{i}];
%     end
% end
% num = textscan(fid, '%d', 1);
% str = textscan(fid, '%s', data.num_ref + 1);
% data.name_mask_ref{1} = [data.dir, str{1}{1}];
% data.name_mask_ref{2} = [data.dir, str{1}{2}];
% data.name_mask_tar = [data.dir, str{1}{3}];
% fclose(fid);
% 
% % normal estimation
% exmp_based_ps_varying_brdf;
% % exmp_based_ps;
% % n_map_tar{data.num_view} = n_map_tar;
% 
% % surface estimation
% esti_surf;

%% synthetic dataset
data.update = 0;
num = 24;
data.num_view = 1;
data.num_img = num;
data.num_ref = 2;
data.name_img_ref = cell(data.num_img, data.num_ref);
data.name_img_tar = cell(data.num_img, 1);
n_map_tar = cell(data.num_view, 1);

% get reference object name
for i = 1 : data.num_ref
    for j = 1 : data.num_img
        data.name_img_ref{j, i} = sprintf('%s/%04d/%04d.jpg', data.ref_dir, i-1, j-1);
    end
end

% get target object name
for i = 1 : data.num_img
    data.name_img_tar{i} = sprintf('%s/%04d.jpg', data.idir, i-1);
end

% get mask
data.name_mask_tar = sprintf('%s/gt/mask.bmp', data.rdir);
data.name_mask_ref{1} = sprintf('%s/mask/0000.bmp', data.ref_dir);
data.name_mask_ref{2} = sprintf('%s/mask/0001.bmp', data.ref_dir);

% normal estimation
exmp_based_ps_varying_brdf;
% exmp_based_ps;
% n_map_tar{data.num_view} = n_map_tar;

% surface estimation
esti_surf;
