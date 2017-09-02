% pairwise property dependency checking
clear, clc, close all;

obj_names = {'box', 'cat0', 'cat1', 'cup', 'dino', 'house', 'pot', 'statue', 'vase'};
algs = {'ps', 'mvs', 'sl', 'vh'};
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the toolbox 3DRecon_Algo_Eval toolbox
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir); % root directory of the toolbox 3DRecon_Algo_Eval toolbox
rdir = sprintf('%s/3DRecon_Algo_Eval/data/real', pdir); % root directory of the dataset
run_alg = 1;
use_syn_real = 'REAL';

for oo = 4
    
obj_name = obj_names{oo};

for aa = 3 : numel(algs)

switch algs{aa}

%% Run MVS
case 'mvs'
addpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));
idir = sprintf('%s/%s/mvs', rdir, obj_name);
foption = sprintf('%s_%s', obj_name, algs{aa});
movefile(sprintf('%s/option-0000', idir), sprintf('%s/%s', idir, foption));
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
    cur_dir = fileparts(mfilename('fullpath'));
    cd(fullfile(tdir, 'algo/MVS/PMVS/bin_x64'));
    system(cmd);
    cd(cur_dir);
end
movefile(sprintf('%s/%s', idir, foption), sprintf('%s/option-0000', idir));
rmpath(genpath(fullfile(tdir, 'algo/MVS/PMVS')));

%% Run SL
case 'sl'
addpath(genpath(fullfile(tdir, 'algo/SL')));
idir = sprintf('%s/%s/sl', rdir, obj_name);
if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
    slProcess_real;
end
rmpath(genpath(fullfile(tdir, 'algo/SL')));

%% Run PS
case 'ps'
addpath(genpath(fullfile(tdir, 'algo/PS/EPS')));
idir = sprintf('%s/%s/ps', rdir, obj_name);
data.idir = idir;
data.ref_dir = idir;
data.obj_name = obj_name;
if(run_alg || ~exist(sprintf('%s/normal.png', data.dir), 'file'))
    main_ps;
end
rmpath(genpath(fullfile(tdir, 'algo/PS/EPS')));

%% Run VH
case 'vh'
addpath(genpath(fullfile(tdir, 'algo/VH')));
idir = sprintf('%s/%s/vh', rdir, obj_name);
cdir = sprintf('%s/%s/vh/txt', rdir, obj_name);
if(run_alg || ~exist(sprintf('%s/models/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_real; % this is actually a visual hull, not space carving
end
rmpath(genpath(fullfile(tdir, 'algo/VH')));

end % end of switch statement

end % end of algs

end % end of obj_names
