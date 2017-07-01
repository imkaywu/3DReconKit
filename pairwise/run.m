% pairwise property dependency checking
clear, clc, close all;
addpath('../');
addpath('../io');
addpath(genpath('../include'));

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
rdir = sprintf('C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/%s', obj_name);
ref_dir = '../../ref_obj';
gt_dir = '../../groundtruth';
run_alg = 0;
run_eval = 0;
run_eval_ps = 0;

for aa = 1 : numel(algs)

idir = sprintf('%s/%s', rdir, algs{aa});

for ii = 1 : numel(props)
    
for jj = ii + 1 : numel(props)

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algs{aa}

%% Run MVS
case 'mvs'
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        dir = sprintf('%s/%s/%02d%02d', idir, prop_pair, ind_1, ind_2);
        copyfile('../../copy2mvs', dir);
        foption = sprintf('%s_%s', obj_name, algs{aa});
        movefile(sprintf('%s/option', dir), sprintf('%s/%s', dir, foption));
        cmd = sprintf('pmvs2 %s/ %s', dir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', dir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', dir, obj_name, algs{aa}), 'file')
            cd ../include, system(cmd), cd ../pairwise;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', dir), 'file'))
            eval_acc_cmplt;
        end
        rmdir(sprintf('%s/txt/', dir), 's');
        delete(sprintf('%s/%s', dir, foption));
        delete(sprintf('%s/vis.dat', dir));
    end
end

%% Run SL
case 'sl'
dir_sl = 'C:/Users/Admin/Documents/3D_Recon/kwStructuredLight';
addpath (genpath(dir_sl));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        objDir = sprintf('%s/%s/%02d%02d', idir, prop_pair, ind_1, ind_2);
        objName = obj_name;
        wait_for_existence(sprintf('%s/0041.jpg', objDir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', objDir, objName), 'file'))
            slProcess_syn;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', objDir), 'file'))
            eval_acc_cmplt;
        end
    end
end

%% Run PS
case 'ps'
dir_ps = 'C:/Users/Admin/Documents/3D_Recon/Photometric Stereo';
addpath(genpath(dir_ps));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        data.dir = sprintf('%s/%s/%02d%02d', idir, prop_pair, ind_1, ind_2);
        data.rdir = rdir;
        data.ref_dir = ref_dir;
        data.obj_name = obj_name;
        wait_for_existence(sprintf('%s/0024.jpg', data.dir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/normal.png', data.dir), 'file'))
            main_ps;
        end
        if(run_eval_ps || ~exist(sprintf('%s/result.txt', data.dir), 'file'))
            eval_angle;
        end
    end
end

%% Run VH
case 'vh'
addpath C:\Users\Admin\Documents\3D_Recon\VisualHull;
dir = sprintf('%s/vh', rdir);
file_base = obj_name;
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn;
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end

end % enf of jj

end % enf of ii

end % end of algs

end % end of switch statement