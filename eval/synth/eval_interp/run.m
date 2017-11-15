% run algorithm and compute the accuracy and completeness
clear, clc, close all;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
use_syn_real = 'SYNTH'; % choose between REAL and SYNTH
set_path;

obj_names = {'bust'};
algos = {'ps', 'mvs', 'sl', 'vh', 'ps_baseline'}; 
run_algo = 0;

for oo = 1 : numel(obj_names)

obj_name = obj_names{oo};

for aa = 1 : numel(algos)

adir = sprintf('%s/eval_interp/%s/%s', rdir, obj_names{oo}, algos{aa}); % root directory of images for algorithm

switch algos{aa}
%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
idir = adir;
foption = sprintf('%s_%s', obj_name, algos{aa});
nimgs = num_of_imgs(sprintf('%s/visualize', idir));
start_pmvs;
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
if run_algo || ~exist([idir, '/models/', obj_names{oo}, '_', algos{aa}, '.ply'], 'file')
    cur_dir = fileparts(mfilename('fullpath'));
    cd(fullfile(tdir, 'algo/MVS/PMVS/bin_x64'));
    system(cmd);
    cd(cur_dir);
end
clear nimgs;
end_pmvs;
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
idir = adir;
wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
if(run_algo || ~exist(sprintf('%s/%s_sl.ply', idir, obj_names{oo}), 'file'))
    slRecon;
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(fullfile(tdir, 'algo/PS/src/EPS'));
data.rdir = rdir;
data.idir = adir;
data.mdir = sprintf('%s/eval_interp/bust/gt', data.rdir);
data.ref_dir1 = sprintf('%s/ref_obj/0000', data.rdir);
data.ref_dir2 = sprintf('%s/ref_obj/0001', data.rdir);
wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
if(run_algo || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    main_ps_svbrdf;
end
rmpath(fullfile(tdir, 'algo/PS/src/EPS'));

%% Run baseline PS
case 'ps_baseline'
addpath(genpath(fullfile(tdir, 'algo/PS/src/LLS-PS')));
idir = adir;
mdir = sprintf('%s/eval_interp/gt', rdir);
if(run_algo || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
    main_lls_ps;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/src/LLS-PS')));

%% Run SC
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = adir;
cdir = sprintf('%s/txt', calib_dir);
wait_for_existence(sprintf('%s/0040.jpg', idir), 'file', 10, 3600);
if(run_algo || ~exist(sprintf('%s/%s_vh.ply', idir, obj_name), 'file'))
    space_carving_syn;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of alg

end % end of obj 
