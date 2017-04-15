addpath([gt_dir, '/io']);
%% compute accuracy
switch alg_type
    case 'mvs'
        [verts_gt, norms_gt, faces_gt] = read_ply_vnf(sprintf('%s/models/%s_gt.ply', gt_dir, obj_name));
        [verts, ~, ~] = read_ply_vnf(sprintf('%s/models/%s_%s.ply', dir, obj_name, alg_type));
end
nverts = size(verts, 2);

% groundtruth: plane z-axis, sphere center and radius
plane_z = min(verts_gt(3, :));
x = [-2, 2];
y = [-2, 2];
c = [0, 0]';
rad = 1.5;

dist2plane = abs(verts(3, :))';
dist2sphere = abs(sqrt(sum(verts.^2, 1)) - rad)';
dist = min(dist2plane, dist2sphere);
sorted_dist = sort(dist);
accuracy = sorted_dist(round(0.9 * nverts));
fprintf('accuracy: %.8f\n', accuracy);

%% compute completeness
% sample the sphere and plane
samp_sphere = rad * gen_norms(40000, [0, 0, 1]', 180)'; % 0.5 between angle
[X, Y] = meshgrid(x(1) : 0.1 : x(2)); % 0.1
samp_plane = [X(:), Y(:), zeros(numel(X), 1)];
d2sphere = sum(samp_plane.^2, 2);
samp_plane = samp_plane(d2sphere >= rad^2, :);
samp = [samp_sphere; samp_plane];

% find the closes vertex in the reconstructed model
d_thre = 0.01; % reasonable?
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

% csamp = 0;
% for i = 1 : size(samp_plane, 1)
%     p = samp_plane(i, :);
%     d = min(abs(p(3) - verts(3, :)'));
%     if d <= d_thre
%         csamp = csamp + 1;
%     end
% end
% completeness(2) = csamp / size(samp_plane, 1);
fprintf('completeness: %.08f\n', completeness);

fid = fopen([dir, '/result.txt'], 'wt');
fprintf(fid, 'accuracy: %.08f\ncompleteness: %.08f\n', accuracy, completeness);
