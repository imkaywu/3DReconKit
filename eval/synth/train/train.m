% training
clear, clc, close all;
addpath('../../include');
addpath('../../io');

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl', 'vh', 'ps_baseline'};
props = {'tex', 'alb', 'spec', 'rough', 'concav'};
alg_prop = logical([0, 1, 1, 1, 0; 1, 1, 1, 0, 0; 0, 1, 1, 1, 0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the directory if necessary
% pdir: parent directory of the 3DRecon_Algo_Eval toolbox
% tdir: root directory of the 3DRecon_Algo_Eval toolbox
% rdir: root directory of the dataset
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data';
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir);
% rdir = sprintf('%s/%s', pdir, obj_name);
rdir = sprintf('%s/data/synth/sphere', tdir); % for test purpose
ref_dir = sprintf('%s/data/synth/ref_obj', tdir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_alg = 1;
run_eval = 0;
run_eval_ps = 0;
use_syn_real = 'SYNTH';

for aa = 5 : numel(algs)

adir = sprintf('%s/%s/train/%s', pdir, obj_name, algs{aa});

switch algs{aa}
%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/%02d%02d%02d00', adir, ind_1, ind_2, ind_3);
        foption = sprintf('%s_%s', obj_name, algs{aa});
        start_pmvs;
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
            cur_dir = fileparts(mfilename('fullpath'));
            cd(fullfile(tdir, 'algo/MVS/PMVS/bin_x64'));
            system(cmd);
            cd(cur_dir);
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
        end_pmvs;
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/00%02d%02d%02d', adir, ind_1, ind_2, ind_3);
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
            slProcess_synth;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
%             close all; fig = figure(1);
%             plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
%             saveas(fig, sprintf('%s/sphere/result/sl_train/sl_00%02d%02d%02d.png', pdir, ind_1, ind_2, ind_3));
%             close(fig);
        end
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/EPS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/00%02d%02d%02d', adir, ind_1, ind_2, ind_3);
        data.idir = idir;
        data.rdir = rdir;
        data.ref_dir = ref_dir;
        data.obj_name = obj_name;
        wait_for_existence(sprintf('%s/0024.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/normal.png', idir), 'file'))
            main_ps;
        end
        if(run_eval_ps || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_angle;
        end
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

%% Run baseline PS
case 'ps_baseline'
addpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));
idir = adir;
data.idir = idir;
data.rdir = rdir;
wait_for_existence(sprintf('%s/0024.jpg', idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/normal.png', idir), 'file'))
    demoPSBox_baseline;
end
if(run_eval_ps || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_angle;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));

%% Run Space carving
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = sprintf('%s/train/sc', rdir);
cdir = sprintf('%s/groundtruth/calib_results/txt', tdir);
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
if (run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of algs