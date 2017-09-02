% pairwise property dependency checking
clear, clc, close all;
addpath(genpath('../../'));

obj_name = 'sphere';
algs = {'ps', 'mvs', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
pdir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data'; % parent directory of the 3DRecon_Algo_Eval toolbox
rdir = sprintf('%s/%s', pdir, obj_name); % root directory of the dataset
ref_dir = sprintf('%s/3DRecon_Algo_Eval/algo/PS/ref_obj', pdir);
% gt_dir = sprintf('%s/groundtruth', pdir);
run_alg = 1;
run_eval = 0;
run_eval_ps = 1;

for aa = 1

adir = sprintf('%s/%s/pairwise/%s', pdir, obj_name, algs{aa});

for ii = 1 : numel(props) - 1
    
for jj = ii + 1 : numel(props)

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algs{aa}

%% Run MVS
case 'mvs'
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        copyfile('../../algo/MVS/PMVS/copy2mvs', idir);
        foption = sprintf('%s_%s', obj_name, algs{aa});
        movefile(sprintf('%s/option', idir), sprintf('%s/%s', idir, foption));
        cmd = sprintf('pmvs2 %s/ %s', idir, foption);
        wait_for_existence(sprintf('%s/visualize/0040.jpg', idir), 'file', 10, 3600);
        if run_alg || ~exist(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}), 'file')
            cd('../../algo/MVS/PMVS/bin_x64'); system(cmd); cd('../../../../eval/pairwise');
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
        end
        rmdir(sprintf('%s/txt/', idir), 's');
        delete(sprintf('%s/%s', idir, foption));
        delete(sprintf('%s/vis.dat', idir));
    end
end

%% Run SL
case 'sl'
% dir_sl = 'C:/Users/Admin/Documents/3D_Recon/kwStructuredLight';
% addpath (genpath(dir_sl));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        objDir = idir;
        objName = obj_name;
        wait_for_existence(sprintf('%s/0041.jpg', idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/%s_sl.ply', idir, obj_name), 'file'))
            slProcess;
        end
        if(run_eval || ~exist(sprintf('%s/result.txt', idir), 'file'))
            eval_acc_cmplt;
%             fig = figure(1);
%             plot3(verts(1, :)+0.01, verts(2, :)+0.01, verts(3, :)+0.01, 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); view(0, 90); axis equal;
%             saveas(fig, sprintf('%s/result/sl_%s_%s_%02d%02d.png', rdir, props{ii}, props{jj}, ind_1, ind_2));
%             close(fig);
        end
    end
end

%% Run PS
case 'ps'
% dir_ps = 'C:/Users/Admin/Documents/3D_Recon/Photometric Stereo';
% addpath(genpath(dir_ps));
for ind_1 = 2 : 3 : 8
    for ind_2 = 2 : 3 : 8
        idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind_1, ind_2);
        data.idir = idir;
        data.rdir = rdir;
        data.ref_dir = ref_dir;
        data.obj_name = obj_name;
        wait_for_existence(sprintf('%s/0024.jpg', data.idir), 'file', 10, 3600);
        if(run_alg || ~exist(sprintf('%s/normal.png', data.idir), 'file'))
            main_ps;
        end
        if(run_eval_ps || ~exist(sprintf('%s/result.txt', data.idir), 'file'))
            eval_angle;
        end
    end
end

%% Run VH
case 'vh'
% addpath C:\Users\Admin\Documents\3D_Recon\VisualHull;
% dir = sprintf('%s/vh', rdir);
file_base = obj_name;
if(update || ~exist(sprintf('%s/%s_vh.ply', dir, obj_name), 'file'))
    VisualHullMain_syn;
end
if(update || ~exist(sprintf('%s/result.txt', dir), 'file'))
    eval_acc_cmplt;
end

end % end of jj

end % end of ii

end % end of algs

end % end of switch statement
