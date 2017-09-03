% run algorithm and compute the accuracy and completeness
% for the test objects
clear, clc, close all;
% addpath(genpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'algo')));
addpath('../include');
addpath('../io');

obj_names = {'bottle', 'cup', 'king', 'knight'};
algs = {'ps', 'mvs', 'sl', 'sc', 'ps_baseline'};
props = {'tex', 'alb', 'spec', 'rough'}; 
val_prop = [2, 8, 2, 8; 2, 8, 5, 2; 8, 8, 2, 8; 8, 8, 5, 2];
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the 3DRecon_Algo_Eval toolbox
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir); % root directory of the toolbox
ref_dir = sprintf('%s/data/synth/ref_obj', tdir);
run_alg = 0;
run_eval = 1;
run_eval_ps = 0;

for oo = 1 : numel(obj_names)

for aa = 1 : numel(algs)

for pp = 1 : size(val_prop, 1)

rdir = sprintf('%s/data/synth/%s', tdir, obj_names{oo}, obj_names{oo}); % root directory of the object
adir = sprintf('%s/%s', rdir, algs{aa}); % root directory of images for algorithm

switch algs{aa}
%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
obj_name = obj_names{oo};
idir = sprintf('%s/%02d%02d%02d%02d', adir, val_prop(pp, 1), val_prop(pp, 2), val_prop(pp, 3), val_prop(pp, 4));
foption = sprintf('%s_%s', obj_name, algs{aa});
start_pmvs;
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
if run_alg || ~exist([idir, '/models/', obj_names{oo}, '_', algs{aa}, '.ply'], 'file')
    cd(sprintf('%s/algo/MVS/PMVS/bin_x64', tdir)); system(cmd); cd(sprintf('%s/eval/test', tdir));
end
if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
%     close all; fig = figure(1);
%     plot3(verts(1, :)+0.01, verts(2, :)+0.01, verts(3, :)+0.01, 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
%     saveas(fig, sprintf('%s/testing/result/%s_mvs_%02d%02d%02d%02d.png', pdir, obj_name, val_prop(pp, 1), val_prop(pp, 2), val_prop(pp, 3), val_prop(pp, 4)));
%     close(fig);
end
end_pmvs;
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
idir = sprintf('%s/%02d%02d%02d%02d', adir, val_prop(pp, 1), val_prop(pp, 2), val_prop(pp, 3), val_prop(pp, 4)); % used in slProcess_syn
obj_name = obj_names{oo};
% alg_type = algs{aa};
wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_names{oo}), 'file'))
    slProcess_synth;
end
if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
%     close all; fig = figure(1);
%     plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
%     saveas(fig, sprintf('%s/testing/result/%s_sl_%02d%02d%02d%02d.png', pdir, obj_name, val_prop(pp, 1), val_prop(pp, 2), val_prop(pp, 3), val_prop(pp, 4)));
%     close(fig);
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/EPS')));
idir = sprintf('%s/%02d%02d%02d%02d', adir, val_prop(pp, 1), val_prop(pp, 2), val_prop(pp, 3), val_prop(pp, 4));
data.idir = idir;
data.rdir = rdir;
data.ref_dir = ref_dir;
data.obj_name = obj_names{oo};
wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    main_ps;
end
if(run_eval_ps || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
    eval_angle;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

%% Run baseline PS
case 'ps_baseline'
addpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));
idir = adir;
data.rdir = rdir;
data.idir = adir;
if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    demoPSBox_baseline;
end
if(run_eval_ps || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
    eval_angle;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));

%% Run SC
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = adir;
obj_name = obj_names{oo};
cdir = sprintf('%s/groundtruth/calib_results/txt', tdir);
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
if (run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of val_prop

end % end of alg

end % end of obj 
