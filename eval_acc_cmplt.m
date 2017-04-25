%% compute accuracy
[verts_gt, norms_gt, faces_gt] = ply_read_vnf(sprintf('%s/models/%s_gt.ply', gt_dir, obj_name));
[verts, ~, ~] = ply_read_vnc(sprintf('%s/models/%s_%s_screened.ply', dir, obj_name, alg_type));
nverts = size(verts, 2);

% groundtruth: sphere center and radius
c = [0, 0, 0]';
rad = 1.5;

prct = 0.9;
dist = abs(sqrt(sum((verts-repmat(c, 1, nverts)).^2, 1)) - rad)';
sorted_dist = sort(dist);
accuracy = sorted_dist(round(prct * nverts));
fprintf('accuracy(%.1f): %.8f\n', prct, accuracy);

%% compute completeness
% sample the sphere
samp_sphere = rad * gen_norms(40000, [0, 0, 1]', 180); % 0.5 between angle
samp_sphere(3, :) = samp_sphere(3, :) + c(3);

% find the closes vertex in the reconstructed model
d_thre = 0.015; % reasonable?
csamp = 0;
nsamp = size(samp_sphere, 2);
for i = 1 : nsamp
    p = samp_sphere(:, i);
    d = sqrt(min(sum((repmat(p, 1, nverts) - verts).^2, 1)));
    if d <= d_thre
        csamp = csamp + 1;
    end
end
completeness = csamp / nsamp;
fprintf('completeness(%.4f): %.08f\n', d_thre, completeness);

fid = fopen([dir, '/result.txt'], 'wt');
fprintf(fid, 'accuracy: %.08f\ncompleteness: %.08f\n', accuracy, completeness);
