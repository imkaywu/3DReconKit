% pairwise property dependency checking
clear, clc, close all;
addpath(genpath('../../algo/'));

obj_names = {'box', 'cat0', 'cat1', 'cup', 'dino', 'house', 'pot', 'statue', 'vase'};
algs = {'ps', 'mvs', 'sl', 'sc'};
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the 3DRecon_Algo_Eval toolbox
rdir = sprintf('%s/3DRecon_Data', pdir); % root directory of the dataset
run_alg = 1;

for oo = 1 : numel(obj_names)
    
obj_name = obj_names{oo};

for aa = 4 : numel(algs)

switch algs{aa}

%% Run MVS
case 'mvs'
idir = sprintf('%s/mvs/%s', rdir, obj_name);
foption = sprintf('%s_%s', obj_name, algs{aa});
movefile(sprintf('%s/option-0000', idir), sprintf('%s/%s', idir, foption));
cmd = sprintf('pmvs2 %s/ %s', idir, foption);
if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
    cd('../../algo/MVS/PMVS/bin_x64'); system(cmd); cd('../../../../eval/pairwise');
end
movefile(sprintf('%s/%s', idir, foption), sprintf('%s/option-0000', idir));

%% Run SL
case 'sl'
idir = sprintf('%s/sl/%s', rdir, obj_name);
objDir = idir;
objName = obj_name;
if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
    slProcess;
end


%% Run PS
case 'ps'
idir = sprintf('%s/ps/%s', rdir, obj_name);
% need to update
data.idir = idir;
data.rdir = rdir;
data.ref_dir = ref_dir;
data.obj_name = obj_name;
if(run_alg || ~exist(sprintf('%s/normal.png', data.dir), 'file'))
    main_ps;
end


%% Run VH
case 'vh'
file_base = obj_name;
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn;
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end

%% Run SC
case 'sc'
idir = sprintf('%s/vh/%s', rdir, obj_name);
cdir = sprintf('%s/vh/%s/txt', rdir, obj_name);
if(run_alg || ~exist(sprintf('%s/%s_sc.ply', idir, obj_name), 'file'))
    space_carving_real;
end

end % end of switch statement

end % end of algs

end % end of obj_names
