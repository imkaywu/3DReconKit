addpath ../io

% compute accuracy
[verts_gt, norms_gt, faces_gt] = read_ply_vnf('../models/cube_sl_gt.ply');
[verts, ~, ~] = read_ply_vnf('../models/cube_sl_screened.ply');
nverts = size(verts, 2);
verts(:, 3) = -verts(:, 3);
verts = [verts(1, :); verts(3, :); verts(2, :)];

z_gt = max(verts_gt(3, :));
euclid_dist = abs(verts(3, :) - z_gt);
sorted_euclid_dist = sort(euclid_dist);
accuracy = sorted_euclid_dist(round(0.9 * nverts));

% compute completeness

