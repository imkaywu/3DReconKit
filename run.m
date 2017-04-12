% run algorithm and compute the accuracy and completeness

is_tex = 1;
is_alb = 0;
is_spec = 1;
is_rough = 1;
is_concav = 1;

obj_name = 'plane_sphere';
alg_type = 'mvs';
idir = ['../plane_sphere/tex_spec/', alg_type];
gt_dir = '../groundtruth';

switch alg_type
%% Run MVS
case 'mvs'
for ind_tex = 2 : 3 : 8
    for ind_spec = 2 : 3 : 8
        dir = sprintf('%s/%02d%02d', idir, ind_tex, ind_spec);
        copyfile('../copy2mvs', dir);
        foption = [obj_name, '_', alg_type];
        movefile([dir, '/option'], [dir, '/', foption]);
        cmd = sprintf('pmvs2 %s/ %s', dir, foption);
        if ~exist([dir, '/models/', obj_name, '_', alg_type, '.ply'], 'file')
            system(cmd);
        end
        evaluate;
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
        evaluate;
    end
end

%% Run PS
case 'ps'
addpath 

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