%% compute accuracy and completeness
d_tor = 0.02;
% read gt
if strcmp(obj_name, 'sphere')
    rad = 1.5;
    c = [0, 0, 0]';
    verts_gt = rad * gen_norms(80000, [0, 0, 1]', 180); % 0.5 between angle
    verts_gt(3, :) = verts_gt(3, :) + c(3);
    x_lim = [min(verts_gt(1, :)) - d_tor, max(verts_gt(1, :)) + d_tor];
    y_lim = [min(verts_gt(2, :)) - d_tor, max(verts_gt(2, :)) + d_tor];
    z_lim = [min(verts_gt(3, :)) - d_tor, max(verts_gt(3, :)) + d_tor];
else

switch algs{aa}
    case 'mvs'
        [verts_gt, ~, ~] = ply_read_vnf(sprintf('%s/gt/mvs.ply', rdir));
    case 'sc'
        [verts_gt, ~, ~] = ply_read_vnf(sprintf('%s/gt/mvs.ply', rdir));
    case 'sl'
        [verts_gt, ~, ~] = ply_read_vnf(sprintf('%s/gt/sl.ply', rdir));
end
ind_rm = verts_gt(3, :) < 0;
verts_gt(:, ind_rm) = [];
x_lim = [min(verts_gt(1, :)) - d_tor, max(verts_gt(1, :)) + d_tor];
y_lim = [min(verts_gt(2, :)) - d_tor, max(verts_gt(2, :)) + d_tor];
z_lim = [min(verts_gt(3, :)) - d_tor, max(verts_gt(3, :)) + d_tor];
dsample = 5;
verts_gt = verts_gt(:, 1 : dsample : size(verts_gt, 2));
end
nverts_gt = size(verts_gt, 2);

% read recon
switch algs{aa}
    case 'mvs'
        [verts, ~, ~] = ply_read_vnc(sprintf('%s/models/%s_%s.ply', idir, obj_name, algs{aa}));
        ind_rm = find(verts(1, :) < x_lim(1) | verts(1, :) > x_lim(2)...
                    | verts(2, :) < y_lim(1) | verts(2, :) > y_lim(2)...
                    | verts(3, :) < z_lim(1) | verts(3, :) > z_lim(2));
        verts(:, ind_rm) = [];
        d_thre = 0.03;
    case 'sl'
        load C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/3DRecon_Algo_Eval/groundtruth/calib_results/calib_cam_proj.mat Rc_1_cam Tc_1_cam
        [verts, ~] = ply_read_vc(sprintf('%s/%s_%s.ply', idir, objName, algs{aa})); % wtf
%         verts = Rc_1_cam{1}' * (verts - repmat(Tc_1_cam{1}, 1, size(verts, 2)));
        ind_rm = find(verts(1, :) < x_lim(1) | verts(1, :) > x_lim(2)...
                    | verts(2, :) < y_lim(1) | verts(2, :) > y_lim(2)...
                    | verts(3, :) < z_lim(1) | verts(3, :) > z_lim(2));
        verts(:, ind_rm) = [];
        dsample = 10;
        verts = verts(:, 1 : dsample : size(verts, 2));
        d_thre = 0.03;
    case 'vh'
        [verts, ~] = ply_read_vf(sprintf('%s/%s_vh.ply', idir, obj_name));
    case 'sc'
        [verts, ~, ~] = ply_read_vnc(sprintf('%s/%s_sc.ply', idir, obj_name));
        ind_rm = find(verts(1, :) < x_lim(1) | verts(1, :) > x_lim(2)...
                    | verts(2, :) < y_lim(1) | verts(2, :) > y_lim(2)...
                    | verts(3, :) < z_lim(1) | verts(3, :) > z_lim(2));
        verts(:, ind_rm) = [];
        d_thre = 0.03;
end
nverts = size(verts, 2);

subplot(1,2,1); plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); axis equal; hold off;
%% compute accuracy and completeness
dist = zeros(nverts, 1);
for n = 1 : nverts
    p = verts(:, n);
    d = pdist2(p', verts_gt', 'euclidean');
    dist(n) = min(d);
end
prct = 0.9;
sorted_dist = sort(dist);
accuracy = sorted_dist(round(prct * nverts));
fprintf('accuracy(%.1f): %.8f\n', prct, accuracy);

count = 0;
ind = [];
for n = 1 : nverts_gt
    p = verts_gt(:, n);
    d = pdist2(p', verts', 'euclidean');
    count = count + (min(d) <= d_thre);
    if (min(d) <= d_thre)
        ind = [ind, n];
    end
end
completeness = count / nverts_gt;
fprintf('completeness(%.4f): %.08f\n', d_thre, completeness);

subplot(1, 2, 2); plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on;plot3(verts_gt(1, ind), verts_gt(2, ind), verts_gt(3, ind), 'r.'); axis equal; hold off;
%% write to file
switch algs{aa}
    case 'mvs'
        fid = fopen([idir, '/result.txt'], 'wt');
    case 'sl'
        fid = fopen([idir, '/result.txt'], 'wt');
    case 'vh'
        fid = fopen([idir, '/result.txt'], 'wt');
    case 'sc'
        fid = fopen([idir, '/result.txt'], 'wt');
end
fprintf(fid, 'accuracy: %.08f\ncompleteness: %.08f\n', accuracy, completeness);
fclose(fid);