%% config directory
% config directory and stuff
addpath(genpath('../'));
% parent directory of the 3DRecon_Algo_Eval toolbox
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data';
% root directory of the 3DRecon_Algo_Eval toolbox
tdir = sprintf('%s/3DRecon_Algo_Eval', pdir);
% root directory of the reference objects
ref_dir = sprintf('%s/ref_obj', pdir);
% root directory of groundtruth data
gt_dir = sprintf('%s/groundtruth', tdir);

%% run algorithms

%% do evaluation