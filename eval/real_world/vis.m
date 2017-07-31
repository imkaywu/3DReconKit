% pairwise property dependency checking
clear, clc, close all;
addpath(genpath('../../algo/'));
addpath('../include');
addpath('../io');

obj_names = {'box', 'cat0', 'cat1', 'cup', 'dino', 'house', 'pot', 'statue', 'vase'};
algs = {'ps', 'mvs', 'sl', 'sc'};
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the 3DRecon_Algo_Eval toolbox
rdir = sprintf('%s/3DRecon_Data', pdir); % root directory of the dataset

for oo = 1 : numel(obj_names)
    
obj_name = obj_names{oo};

for aa = 2

% read camera calibration data
% cdir = sprintf('%s/%s/%s/txt', rdir, algs{aa}, obj_name);
cdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/3DRecon_Algo_Eval/algo/CamData';
nimg = numel(dir(cdir)) - 2;
P = zeros(3, 4, nimg);
for cc = 1 : nimg
    fname = sprintf('%s/%04d.txt', cdir, cc - 1);
    if(~exist(fname, 'file'))
        fname = sprintf('%s/%08d.txt', cdir, cc - 1);
    end
    fid = fopen(fname);
    fgets(fid);
    tmp = fscanf(fid, '%f');
    P(:, :, cc) = [tmp(1), tmp(2), tmp(3), tmp(4);
                   tmp(5), tmp(6), tmp(7), tmp(8);
                   tmp(9), tmp(10), tmp(11), tmp(12)];
    fclose(fid);
end

switch algs{aa}

%% Run MVS
case 'mvs'
fname = sprintf('%s/mvs/%s/models/%s_mvs.ply', rdir, obj_name, obj_name);
[pt, color, ~] = ply_read_vnc(fname);
volume = diff([min(pt(1, :)) max(pt(1, :))]) *...
        diff([min(pt(2, :)) max(pt(2, :))]) *...
        diff([min(pt(3, :)) max(pt(3, :))]);
N = 6000000;
voxels.Resolution = power( volume/N, 1/3 );
voxels.XData = pt(1, :)';
voxels.YData = pt(2, :)';
voxels.ZData = pt(3, :)';
voxels.Value = ones(size(pt, 2), 1);
draw_scene;

%% Run SL
case 'sl'
fname = sprintf('%s/sl/data/%s/v1_screened.ply', rdir, obj_name);
[pt, color] = ply_read_vc(fname);
volum = diff([min(pt(1, :)) max(pt(1, :))]) *...
        diff([min(pt(2, :)) max(pt(2, :))]) *...
        diff([min(pt(3, :)) max(pt(3, :))]);
N = 6000000;
voxels.Resolution = power( volume/N, 1/3 );
voxels.XData = pt(1, :);
voxels.YData = pt(2, :);
voxels.ZData = pt(3, :);
voxels.Value = ones(size(pt, 2), 1);

%% Run PS
case 'ps'
idir = sprintf('%s/ps/%s', rdir, obj_name);
% need to update
data.idir = idir;
data.rdir = rdir;
data.ref_dir = ref_dir;
data.obj_name = obj_name;
if(run_alg || ~exist(sprintf('%s/normal.png', data.dir), 'file'))
    main_ps;
end


%% Run VH
case 'vh'
file_base = obj_name;
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn;
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end

%% Run SC
case 'sc'
fname = sprintf('%s/sc/%s/models/%s_sc.ply', rdir, obj_name, obj_name);
[pt, color, ~] = ply_read_vnc(fname);
volum = diff([min(pt(1, :)) max(pt(1, :))]) *...
        diff([min(pt(2, :)) max(pt(2, :))]) *...
        diff([min(pt(3, :)) max(pt(3, :))]);
N = 6000000;
voxels.Resolution = power( volume/N, 1/3 );
voxels.XData = pt(1, :);
voxels.YData = pt(2, :);
voxels.ZData = pt(3, :);
voxels.Value = ones(size(pt, 2), 1);

end % end of switch statement

end % end of algs

end % end of obj_names
