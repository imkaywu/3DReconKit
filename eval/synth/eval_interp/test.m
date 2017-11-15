% run algorithm and compute the accuracy and completeness
% for the test objects
clear, clc, close all;
% addpath(genpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'algo')));
addpath('../../include');
addpath('../../io');

obj_names = {'vase2'};
algs = {'ps', 'mvs', 'sl', 'vh'}; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the directory if necessary
% pdir: parent directory of the 3DRecon_Algo_Eval toolbox
% tdir: root directory of the 3DRecon_Algo_Eval toolbox
% rdir: root directory of the dataset
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data';
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir);
ref_dir = sprintf('%s/data/synth/ref_obj', tdir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_alg = 1;
use_syn_real = 'SYNTH';

for oo = 1 : numel(obj_names)

for aa = 1 : numel(algs)

rdir = sprintf('%s/synth/%s', pdir, obj_names{oo}); % root directory of the object
idir = sprintf('%s/%s', rdir, algs{aa}); % root directory of images for algorithm

switch algs{aa}
%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
obj_name = obj_names{oo};
foption = sprintf('%s_%s', obj_name, algs{aa});
start_pmvs;
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
if run_alg || ~exist([idir, '/models/', obj_names{oo}, '_', algs{aa}, '.ply'], 'file')
    cur_dir = fileparts(mfilename('fullpath'));
    cd(fullfile(tdir, 'algo/MVS/PMVS/bin_x64'));
    system(cmd);
    cd(cur_dir);
end
end_pmvs;
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
obj_name = obj_names{oo};
wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_names{oo}), 'file'))
    slProcess_synth;
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/EPS')));
data.idir = idir;
data.rdir = rdir;
data.ref_dir = ref_dir;
data.obj_name = obj_names{oo};
wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    main_ps;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

%% Run baseline PS
case 'ps_baseline'
addpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));
data.rdir = rdir;
data.idir = adir;
if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    demoPSBox_baseline;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/PSBox')));

%% Run SC
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
obj_name = obj_names{oo};
cdir = sprintf('%s/groundtruth/calib_results/txt', tdir);
wait_for_existence(sprintf('%s/0040.jpg', idir), 'file', 10, 3600);
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of alg

end % end of obj 
