% run algorithm and compute the accuracy and completeness
clear, clc, close all;
addpath ('io');

is_tex = 1;
is_alb = 0;
is_spec = 1;
is_rough = 1;
is_concav = 1;

obj_name = 'sphere';
alg_type = 'vh';
prop_comb = 'tex_spec';
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
idir = sprintf('%s/%s/%s', rdir, prop_comb, alg_type);
ref_dir = '../ref_obj';
gt_dir = '../groundtruth';
update = 0;

switch alg_type
%% Run MVS
case 'mvs'
for ind_tex = 5
    for ind_spec = 5
        dir = sprintf('%s/%02d%02d', idir, ind_tex, ind_spec);
        copyfile('../copy2mvs', dir);
        foption = [obj_name, '_', alg_type];
        movefile([dir, '/option'], [dir, '/', foption]);
        cmd = sprintf('pmvs2 %s/ %s', dir, foption);
        if update || ~exist([dir, '/models/', obj_name, '_', alg_type, '.ply'], 'file')
            system(cmd);
        end
        eval_acc_cmplt;
        rmdir(sprintf('%s/txt/', dir), 's');
        delete(sprintf('%s/%s', dir, foption));
        delete(sprintf('%s/vis.dat', dir));
    end
end

%% Run SL
case 'sl'
dir_sl = 'C:/Users/Admin/Documents/3D_Recon/kwStructuredLight';
addpath (genpath(dir_sl));
for ind_tex = 2 : 3 : 8
    for ind_spec = 2 : 3 : 8
        % change objName
        objDir = sprintf('%s/%02d%02d', idir, ind_tex, ind_spec); % used in slProcess_syn
        if(update || ~exist(sprintf('%s/%s_sl.ply', objDir, obj_name), 'file'))
            slProcess_syn;
        end
        if(update || ~exist(sprintf('%s/result.txt', objDir), 'file'))
            eval_acc_cmplt;
        end
    end
end

%% Run PS
case 'ps'
dir_ps = 'C:/Users/Admin/Documents/3D_Recon/Photometric Stereo';
addpath(genpath(dir_ps));
for ind_tex = 5
    for ind_spec = 5
        data.dir = sprintf('%s/%02d%02d', idir, ind_tex, ind_spec);
        data.rdir = rdir;
        data.ref_dir = ref_dir;
        data.obj_name = obj_name;
        if(~exist(sprintf('%s/normal.jpg', data.dir), 'file'))
            main_ps;
        end
        eval_angle;
    end
end

%% Run VH
case 'vh'
addpath C:\Users\Admin\Documents\3D_Recon\VisualHull;
dir = sprintf('%s/vh', rdir); % used in VisualHullMain_syn
file_base = obj_name; % name of the gt
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn; % write this sub-routine
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end


end % end of switch statement