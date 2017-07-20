% training
clear, clc, close all;
addpath(genpath('../../'));

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl', 'sc'};
props = {'tex', 'alb', 'spec', 'rough', 'concav'};
alg_prop = logical([0, 1, 1, 1, 0; 1, 1, 1, 0, 0; 0, 1, 1, 1, 0]);
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the data
ref_dir = sprintf('%s/ref_obj', pdir);
gt_dir = sprintf('%s/groundtruth', pdir);
run_alg = 0;
run_eval = 1;
run_eval_ps = 0;

for aa = 4 : numel(algs)

% ind = find(alg_prop(aa, :));
% eff_props = sprintf('%s_%s_%s', props{ind(1)}, props{ind(2)}, props{ind(3)});
rdir = sprintf('%s/%s/train/%s', pdir, obj_name, algs{aa});

switch algs{aa}
%% Run MVS
case 'mvs'
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/%02d%02d%02d00', rdir, ind_1, ind_2, ind_3);
        copyfile('../../algo/MVS/PMVS/copy2mvs', idir);
        foption = sprintf('%s_%s', obj_name, algs{aa});
        movefile([idir, '/option'], [idir, '/', foption]);
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
            cd('../../algo/MVS/PMVS/bin_x64'); system(cmd); cd('../../../../eval/train');
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
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/00%02d%02d%02d', rdir, ind_1, ind_2, ind_3);
        objDir = idir; % used in slProcess_syn
        objName = obj_name;
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
            slProcess;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
        end
    end
end

%% Run PS
case 'ps'
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/00%02d%02d%02d', rdir, ind_1, ind_2, ind_3);
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
idir = rdir;
cdir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'CamData');
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
if (run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
end

end % end of switch statement

end % end of algs