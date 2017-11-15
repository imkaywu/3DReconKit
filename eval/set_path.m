%% set path
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'include')));
addpath(fullfile(fileparts(mfilename('fullpath')), 'io'));

%% set global directories
% parent directory of the 3DRecon_Algo_Eval toolbox
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data';

% root directory of the 3DRecon_Algo_Eval toolbox
tdir = sprintf('%s/3DReconKit', pdir);

% root directory of dataset
% rdir = sprintf('%s/%s', pdir, obj_name);
rdir = sprintf('%s/data/synth', tdir); % for test purpose

% root directory of the reference objects
ref_dir = sprintf('%s/data/ref_dir', tdir);

% root directory of groundtruth data
gt_dir = sprintf('%s/groundtruth', tdir);

% root directory of calibration data
calib_dir = sprintf('%s/calib/results', tdir);