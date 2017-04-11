% run algorithm and compute the accuracy and completeness

is_tex = 1;
is_alb = 0;
is_spec = 1;
is_rough = 1;
is_concav = 1;

obj_name = 'plane_sphere';
idir = '../plane_sphere/tex_spec';

%% Run MVS
for i = 2 : 3 : 8
    for j = 1 : 10
        dir = sprintf('%s/%02d%02d/mvs_vh', idir, i, j);
        copyfile('../copy2mvs', dir);
        cmd = sprintf('pmvs2 %s/ option', dir);
        eval(cmd);
        evaluate;
        rmdir(sprintf('%s/txt/', dir), 's');
        delete(sprintf('%s/option', dir));
        delete(sprintf('%s/vis.dat', dir));
    end
end

%% Run SL
addpath C:/Users/Daniela/Documents/3D_Recon/kwStructuredLight
objDir = sprintf('%s/%02d%02d/mvs_vh', idir, i, j);
for i = 2 : 3 : 8
    for j = 1 : 10
        % change objName
        slProcess_syn;
        evaluate;
    end
end

%% Run PS
addpath 

%% Run VH
addpath C:/Users/Daniela/Documents/3D_Recon/Visual Hull Matlab;
for i = 2 : 3 : 8
    for j = 1 : 10
        dir = sprintf('%s/%02d%02d/mvs_vh', idir, i, j); % used in VisualHullMain_syn
        file_base = 'cup'; % name of the gt
        VisualHullMain_syn; % write this sub-routine
        evaluate;
    end
end