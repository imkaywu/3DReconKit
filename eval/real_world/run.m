% pairwise property dependency checking
clear, clc, close all;
addpath(fileparts(fileparts(mfilename('fullpath'))));
use_syn_real = 'REAL'; % choose between REAL and SYNTH
set_path;

obj_names = {'bottle', 'box', 'cat0', 'cat1', 'cup', 'dino', 'house', 'pot', 'statue', 'vase'};
algos = {'ps', 'mvs', 'sl', 'vh'};
run_algo = 1;

for oo = 5
    
obj_name = obj_names{oo};

for aa = 3 : numel(algos)
    
adir = sprintf('%s/%s/%s', rdir, obj_names{oo}, algos{aa}); % root directory of images for algorithm

switch algos{aa}

%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
idir = adir;
nimgs = num_of_imgs(sprintf('%s/visualize', idir));
foption = sprintf('%s_%s', obj_name, algos{aa});
start_pmvs;
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
if run_algo || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algos{aa}), 'file')
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
if(run_algo || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
    slRecon;
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(fullfile(tdir, 'algo/PS/src/EPS'));
data.idir = adir;
data.mdir = adir;
data.ref_dir1 = sprintf('%s/ref_obj/0000', adir);
data.ref_dir2 = sprintf('%s/ref_obj/0001', adir);
if(run_algo || ~exist(sprintf('%s/normal.png', data.dir), 'file'))
    main_ps_svbrdf;
end
rmpath(fullfile(tdir, 'algo/PS/src/EPS'));

%% Run VH
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = adir;
cdir = sprintf('%s/txt', calib_dir);
if(run_algo || ~exist(sprintf('%s/models/%s_vh.ply', idir, obj_name), 'file'))
    space_carving_real;
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of algos

end % end of obj_names
