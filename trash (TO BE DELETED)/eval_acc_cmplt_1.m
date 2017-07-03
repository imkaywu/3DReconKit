%% compute accuracy
[verts_gt, norms_gt, faces_gt] = ply_read_vnf(sprintf('%s/gt/%s.ply', rdir, obj_name{oo}));
switch algs{aa}
    case 'mvs'
        [verts, ~, ~] = ply_read_vnc(sprintf('%s/models/%s_%s.ply', dir, obj_name{oo}, algs{aa}));
    case 'sl'
        [verts, ~] = ply_read_vc(sprintf('%s/%s_%s.ply', objDir, objName, alg_type));
        dsample = 10;
        verts = verts(:, 1 : dsample : size(verts, 2));
    case 'vh'
        [verts, ~] = ply_read_vf(sprintf('%s/%s_vh.ply', dir, obj_name{oo}));
end
nverts = size(verts, 2);
nverts_gt = size(verts_gt, 2);

prct = 0.9;
dist = zeros(nverts, 1);
for i = 1 : nverts
    p = verts(:, i);
    dist(i) = sqrt(min(sum((repmat(p, 1, nverts_gt) - verts_gt).^2, 1)));
%     dist(i) = min(pdist2(p, verts_gt));
end
sorted_dist = sort(dist);
accuracy = sorted_dist(round(prct * nverts));
fprintf('accuracy(%.1f): %.8f\n', prct, accuracy);

%% compute completeness
% sample the sphere
dsample = 10;
verts_samp = verts_gt(:, 1 : dsample : nverts_gt);

% find the closes vertex in the reconstructed model
switch algs{aa}
case 'mvs'
    d_thre = 0.012; % reasonable?
case 'sl'
    d_thre = 0.05;
end
csamp = 0;
nsamp = size(verts_samp, 2);
% dist = slmetric_pw(samp_sphere, verts, 'mineucdiff');
% csamp = sum(dist <= d_thre);
for i = 1 : nsamp
    p = verts_samp(:, i);
    d = sqrt(min(sum((repmat(p, 1, nverts) - verts).^2, 1)));
    if d <= d_thre
        csamp = csamp + 1;
    end
end
completeness = csamp / nsamp;
fprintf('completeness(%.4f): %.08f\n', d_thre, completeness);

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