% training
clear, clc, close all;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
use_syn_real = 'SYNTH'; % choose between REAL and SYNTH
set_path;

obj_name = 'sphere';
algos = {'ps', 'mvs', 'sl', 'vh'};
run_alg = 0;
run_eval = 0;

for aa = 1 : numel(algos)

adir = sprintf('%s/eval_algo/%s', rdir, algos{aa});

switch algos{aa}
%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        idir = sprintf('%s/%02d%02d%02d00', adir, ind_1, ind_2, ind_3);
        nimgs = num_of_imgs(sprintf('%s/visualize', idir));
        foption = sprintf('%s_%s', obj_name, algos{aa});
        start_pmvs;
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algos{aa}), 'file')
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
clear nimgs;
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
            slRecon;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/src/EPS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        for ind_3 = 2 : 3 : 8
        data.obj_name = obj_name;
        data.idir = sprintf('%s/00%02d%02d%02d', adir, ind_1, ind_2, ind_3);
        data.mdir = sprintf('%s/eval_algo/gt', rdir);
        data.ref_dir1 = sprintf('%s/ref_obj/0000', rdir);
        data.ref_dir2 = sprintf('%s/ref_obj/0001', rdir);
        wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
            main_ps_svbrdf;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
            eval_angle;
        end
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/PS/src/EPS')));

%% Run Space carving
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = sprintf('%s/eval_algo/sc', rdir);
cdir = sprintf('%s/calib/results/txt', tdir);
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
if (run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
    eval_acc_cmplt;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of algos

unset_path;
rmpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
