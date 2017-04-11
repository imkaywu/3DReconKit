addpath ../io
% compute accuracy
[verts_gt, norms_gt, faces_gt] = read_ply_vnf('../models/cube_mvs_gt.ply');
[verts, ~, ~] = read_ply_vnf('../models/option-0000.ply');
nverts = size(verts, 2);

x_gt = [min(verts_gt(1, :)), max(verts_gt(1, :))]';
y_gt = [min(verts_gt(2, :)), max(verts_gt(2, :))]';
z_gt = [min(verts_gt(3, :)), max(verts_gt(3, :))]';

dist = zeros(size(verts'));
dist(:, 1) = min(abs(verts(1, :) - x_gt(1)), abs(verts(1, :) - x_gt(2)));
dist(:, 2) = min(abs(verts(2, :) - y_gt(1)), abs(verts(2, :) - y_gt(2)));
dist(:, 3) = min(abs(verts(3, :) - z_gt(1)), abs(verts(3, :) - z_gt(2)));
euclid_dist = min(dist, 2);
sorted_euclid_dist = sort(euclid_dist);
accuracy = sorted_euclid_dist(round(0.9 * nverts));

% compute completeness