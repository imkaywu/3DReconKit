% run algorithm and compute the accuracy and completeness
addpath ('io');

is_tex = 1;
is_alb = 0;
is_spec = 1;
is_rough = 1;
is_concav = 1;

obj_name = 'sphere';
alg_type = 'ps';
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
idir = sprintf('%s/tex_spec/%s', rdir, alg_type);
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
addpath C:/Users/Daniela/Documents/3D_Recon/kwStructuredLight
objDir = sprintf('%s/%02d%02d/', idir, i, j);
for i = 2 : 3 : 8
    for j = 1 : 10
        % change objName
        slProcess_syn;
        eval_ang;
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
        main_ps;
        eval_angle;
    end
end

%% Run VH
case 'vh'
addpath C:/Users/Daniela/Documents/3D_Recon/Visual Hull Matlab;
for i = 2 : 3 : 8
    for j = 1 : 10
        dir = sprintf('%s/%02d%02d/mvs_vh', idir, i, j); % used in VisualHullMain_syn
        file_base = 'cup'; % name of the gt
        VisualHullMain_syn; % write this sub-routine
        evaluate;
    end
end

end % end of switch statement