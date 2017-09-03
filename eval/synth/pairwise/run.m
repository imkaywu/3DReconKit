% pairwise property dependency checking
clear, clc, close all;
addpath('../../include');

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the directory if necessary
% pdir: parent directory of the 3DRecon_Algo_Eval toolbox
% tdir: root directory of the 3DRecon_Algo_Eval toolbox
% rdir: root directory of the dataset
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data';
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir);
rdir = sprintf('%s/%s', pdir, obj_name);
% rdir = sprintf('%s/data/synth/sphere', tdir); % for test purpose
ref_dir = sprintf('%s/data/synth/ref_obj', tdir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_alg = 1;
run_eval = 1;
run_eval_ps = 1;
use_syn_real = 'SYNTH';

for aa = 3

adir = sprintf('%s/pairwise/%s', rdir, algs{aa});

for ii = 1 : numel(props) - 1
    
for jj = ii + 1 : numel(props)

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algs{aa}

%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
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
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
            slProcess_synth;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
%             fig = figure(1);
%             plot3(verts(1, :)+0.01, verts(2, :)+0.01, verts(3, :)+0.01, 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
%             saveas(fig, sprintf('%s/result/sl_%s_%s_%02d%02d.png', rdir, props{ii}, props{jj}, ind_1, ind_2));
%             close(fig);
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/EPS')));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        data.idir = idir;
        data.rdir = rdir;
        data.ref_dir = ref_dir;
        data.obj_name = obj_name;
        wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
            main_ps;
        end
        if(run_eval_ps || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
            eval_angle;
        end
    end
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

end % end of jj

end % end of ii

end % end of algs

end % end of switch statement
