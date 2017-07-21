% test if example based photometric stereo
clear;
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
addpath('/Users/BlacKay/Documents/Projects/Multi-view PS');
addpath('/Users/BlacKay/Documents/Projects/Multi-view PS/PS');

% data.dir = '../../Data/Fixed-view PS/photodata/';
data.dir = 'C:/Users/Admin/Documents/3D Recon/Data/WACV/obj1_9_22/';

fid = fopen([data.dir, 'files.txt'], 'r');
num = textscan(fid, '%d', 10);

data.num_view = 1;
data.num_img = num{1}(1);
data.num_ref = num{1}(2);
data.name_img_ref = cell(data.num_img * data.num_ref, 1);
data.name_img_tar = cell(data.num_img, 1);
n_map_tar = cell(data.num_view, 1);

str = textscan(fid, '%s', (data.num_ref + 1) * data.num_img);
for i = 1 : (data.num_ref + 1) * data.num_img
    if i <= data.num_ref * data.num_img
        data.name_img_ref{i} = [data.dir, str{1}{i}];
    else
        data.name_img_tar{i - data.num_ref * data.num_img} = [data.dir, str{1}{i}];
    end
end
num = textscan(fid, '%d', 1);
str = textscan(fid, '%s', data.num_ref);
data.name_mask_ref = [data.dir, str{1}{1}];
data.name_mask_tar = [data.dir, str{1}{2}];

fclose(fid);

% normal estimation
exmp_based_ps_varying_brdf;
n_map_tar{data.num_view} = n_map_tar;

% surface estimation
esti_surf;

