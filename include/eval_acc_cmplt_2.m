%% compute accuracy
x_lim = [-1.52, 1.52];
y_lim = [-1.52, 1.52];
z_lim = [-0.02, 1.52];
switch algs{aa}
    case 'mvs'
        [verts, ~, ~] = ply_read_vnc(sprintf('%s/models/%s_%s.ply', dir, obj_name, algs{aa}));
        if strcmp(obj_name, 'sphere')
            ind_rm = find(verts(1, :) < x_lim(1) | verts(1, :) > x_lim(2)...
                        | verts(2, :) < y_lim(1) | verts(2, :) > y_lim(2)...
                        | verts(3, :) < z_lim(1) | verts(3, :) > z_lim(2));
            verts(:, ind_rm) = [];
        end
        d_thre = 0.015;
    case 'sl'
        [verts, ~] = ply_read_vc(sprintf('%s/%s_%s.ply', objDir, objName, algs{aa}));
        if strcmp(objName, 'sphere')
            ind_rm = find(verts(1, :) < x_lim(1) | verts(1, :) > x_lim(2)...
                        | verts(2, :) < y_lim(1) | verts(2, :) > y_lim(2)...
                        | verts(3, :) < z_lim(1) | verts(3, :) > z_lim(2));
            verts(:, ind_rm) = [];
        end
        dsample = 10;
        verts = verts(:, 1 : dsample : size(verts, 2));
        d_thre = 0.05;
    case 'vh'
        [verts, ~] = ply_read_vf(sprintf('%s/%s_vh.ply', dir, obj_name));
end
nverts = size(verts, 2);

% groundtruth: sphere center and radius
if strcmp(obj_name, 'sphere')
    c = [0, 0, 0]';
    rad = 1.5;
    verts_gt = rad * gen_norms(40000, [0, 0, 1]', 180); % 0.5 between angle
    verts_gt(3, :) = verts_gt(3, :) + c(3);
else
    [verts_gt, norms_gt, faces_gt] = ply_read_vnf(sprintf('%s/gt/%s_gt.ply', rdir, obj_names{oo}));
    dsample = 5;
    verts_gt = verts_gt(:, 1 : dsample : size(verts_gt, 2));
end
if strcmp(algs{aa}, 'sl')
    load C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/groundtruth/calib_results/calib_cam_proj.mat Rc_1_cam Tc_1_cam
    verts_gt = Rc_1_cam{1} * verts_gt + repmat(Tc_1_cam{1}, 1, size(verts_gt, 2));
end
subplot(1,2,1); plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on; plot3(verts_gt(1, :), verts_gt(2, :), verts_gt(3, :), 'r.'); axis equal; hold off;
%% compute accuracy and completeness
ind = [];
dist = zeros(nverts, 1);
for n = 1 : nverts
    p = verts(:, n);
    d = pdist2(p', verts_gt', 'euclidean');
    dist(n) = min(d);
    ind = [ind, find(d < d_thre)];
end

prct = 0.9;
sorted_dist = sort(dist);
accuracy = sorted_dist(round(prct * nverts));
fprintf('accuracy(%.1f): %.8f\n', prct, accuracy);

ind = unique(ind);
completeness = numel(ind) / size(verts_gt, 2);
fprintf('completeness(%.4f): %.08f\n', d_thre, completeness);

subplot(1, 2, 2);
plot3(verts(1, :), verts(2, :), verts(3, :), 'k.'); hold on;
plot3(verts_gt(1, ind), verts_gt(2, ind), verts_gt(3, ind), 'r.');
axis equal; hold off;
%% write to file
switch algs{aa}
    case 'mvs'
        fid = fopen([dir, '/result.txt'], 'wt');
    case 'sl'
        fid = fopen([objDir, '/result.txt'], 'wt');
    case 'vh'
        fid = fopen([dir, '/result.txt'], 'wt');
end
fprintf(fid, 'accuracy: %.08f\ncompleteness: %.08f\n', accuracy, completeness);
fclose(fid);