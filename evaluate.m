addpath ../io
%% compute accuracy
[verts_gt, norms_gt, faces_gt] = read_ply_vnf('../models/cube_mvs_gt.ply');
[verts, ~, ~] = read_ply_vnf('../models/option-0000.ply');
nverts = size(verts, 2);

% groundtruth: plane z-axis, sphere center and radius
plane_z = min(verts_gt(3, :));
c = [0, 0]';
rad = 2.0;

dist2plane = abs(verts(3, :))';
dist2sphere = abs(sqrt(sum(verts.^2, 1)) - rad)';
dist = min(dist2plane, dist2sphere);
sorted_dist = sort(dist);
accuracy = sorted_dist(round(0.9 * nverts));
fprintf('accuracy: %.4f\n', accuracy);

%% compute completeness
% sample the sphere and plane
samp_sphere = gen_norms(40000, [0, 0, 1]', 180); % 0.5 between angle
[X, Y] = meshgrid(-3 : 0.1 : 3); % 0.1
samp_plane = [X(:), Y(:), numel(X)];
d2sphere = sum(samp_plane.^2, 2);
samp_plane = samp_plane(d2sphere >= rad^2);
samp = [samp_sphere; samp_plane];

% find the closes vertex in the reconstructed model
d_thre = 0.5;
csamp = 0;
nsamp = size(samp, 1);
for i = 1 : nsamp
    p = samp(i, :);
    d = sqrt(min(sum((repmat(p, nverts, 1) - verts').^2, 2)));
    if d <= d_thre
        csamp = csamp + 1;
    end
end
completeness = csamp / nsamp;
fprintf('completeness: %.04f\n', completeness);
