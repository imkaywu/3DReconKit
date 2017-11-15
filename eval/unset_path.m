%% set path
rmpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'include')));
rmpath(fullfile(fileparts(mfilename('fullpath')), 'io'));

%% unset global directories
clear pdir tdir rdir ref_dir gt_dir calib_dir