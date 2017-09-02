% run example based photometric stereo
close all;
clc;

%% real-world objects
if strcmp(use_syn_real, 'REAL')
    fid = fopen(sprintf('%s/files.txt', idir), 'r');
    line = sscanf(fgets(fid), '%d%d', [2, 1]);
    data.num_view = 1;
    data.num_img = line(1);
    data.num_ref = line(2);
    data.name_img_ref = cell(data.num_img, data.num_ref);
    data.name_img_tar = cell(data.num_img, 1);
    
    for i = 1 : data.num_ref
        for j = 1 : data.num_img
            data.name_img_ref{j, i} = sprintf('%s/%s', idir, fgetl(fid));
        end
    end
    
    for i = 1 : data.num_img
        data.name_img_tar{i} = sprintf('%s/%s', idir, fgetl(fid));
    end
    line = fgets(fid);
    data.name_mask_ref{1} = sprintf('%s/%s', idir, fgetl(fid));
    data.name_mask_ref{2} = sprintf('%s/%s', idir, fgetl(fid));
    data.name_mask_tar = sprintf('%s/%s', idir, fgetl(fid));
    
%% synthetic objects
else
data.update = 0;
num = 25;
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

end

% normal estimation
exmp_based_ps_varying_brdf;

% surface estimation
esti_surf;
