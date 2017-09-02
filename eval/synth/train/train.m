% training
clear, clc, close all;
addpath('../include');
addpath('../io');

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl', 'sc', 'ps_baseline'};
props = {'tex', 'alb', 'spec', 'rough', 'concav'};
alg_prop = logical([0, 1, 1, 1, 0; 1, 1, 1, 0, 0; 0, 1, 1, 1, 0]);
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the 3DRecon_Algo_Eval toolbox
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir); % root directory of the boolbox
rdir = sprintf('%s/%s', pdir, obj_name); % root directory of the dataset
ref_dir = sprintf('%s/3DRecon_Algo_Eval/algo/PS/ref_obj', pdir);
% gt_dir = sprintf('%s/groundtruth', pdir);
run_alg = 0;
run_eval = 1;
run_eval_ps = 0;

for aa = 3 % 1 : numel(algs)

adir = sprintf('%s/%s/train/%s', pdir, obj_name, algs{aa});

switch algs{aa}
%% Run MVS
case 'mvs'
addpath(genpath('../../algo/MVS'));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/%02d%02d%02d00', adir, ind_1, ind_2, ind_3);
        copyfile(sprintf('%s/algo/MVS/PMVS/copy2mvs', tdir), idir);
        foption = sprintf('%s_%s', obj_name, algs{aa});
        movefile([idir, '/option'], [idir, '/', foption]);
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
            cd(sprintf('%s/algo/MVS/PMVS/bin_x64', tdir)); system(cmd); cd(sprintf('%s/eval/train', tdir));
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
        rmdir(sprintf('%s/txt/', idir), 's');
        delete(sprintf('%s/%s', idir, foption));
        delete(sprintf('%s/vis.dat', idir));
        end
    end
end

%% Run SL
case 'sl'
addpath(genpath('..\..\algo\SL'));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/00%02d%02d%02d', adir, ind_1, ind_2, ind_3);
        objDir = idir; % used in slProcess
        objName = obj_name;
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
%             ratio = ((ind_2 - 2) / 10 + 1) * ((ind_3 - 2) / 10 + 1);
            slProcess;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
            close all; fig = figure(1);
            plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
            saveas(fig, sprintf('%s/sphere/result/sl_train/sl_00%02d%02d%02d.png', pdir, ind_1, ind_2, ind_3));
            close(fig);
        end
        end
    end
end

%% Run PS
case 'ps'
addpath(genpath('../../algo/PS'));
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

%% Run baseline PS
case 'ps_baseline'
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

%% Run VH
case 'vh'
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn;
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end

%% Run Space carving
case 'sc'
idir = sprintf('%s/train/sc', rdir);
cdir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'algo/CamData');
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
if (run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
end

end % end of switch statement

end % end of algs