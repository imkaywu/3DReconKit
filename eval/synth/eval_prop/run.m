% study the main effect of each property or interaction effect of each pair of properties 
clear, clc, close all;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
set_path;

obj_name = 'sphere';
algos = {'ps', 'mvs', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
run_algo = 0;
run_eval = 0;
use_syn_real = 'SYNTH'; % choose between REAL and SYNTH

for aa = 1 : numel(algos)

adir = sprintf('%s/eval_prop/%s', rdir, algos{aa});

for ii = 1 : numel(props) - 1
    
for jj = ii + 1 : numel(props)

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algos{aa}

%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        foption = sprintf('%s_%s', obj_name, algos{aa});
        start_pmvs;
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_algo || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algos{aa}), 'file')
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
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_algo || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
            slRecon;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/src/EPS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        data.obj_name = obj_name;
        data.rdir = rdir;
        data.idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        data.mdir = sprintf('%s/eval_algo/gt', rdir);
        data.ref_dir1 = sprintf('%s/ref_obj/0000', data.rdir);
        data.ref_dir2 = sprintf('%s/ref_obj/0001', data.rdir);
        wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
        if(run_algo || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
            main_ps_svbrdf;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
            eval_angle;
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

end % end of jj

end % end of ii

end % end of algos

end % end of switch statement

unset_path;
rmpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));