function ply_write(fname, verts, faces) % Nx3 matrix

num_pts = size(verts, 1);
num_faces = size(faces, 1);
% this is the face normal, not vertex normal
% normals = zeros(num_pts, 3);
% for i = 1 : num_faces
%     pts = verts(faces(i, :), :);
%     normals(i, :) = local_find_normal(pts(1, :), pts(2, :), pts(3, :));
% end

header = 'ply\n';
header = [header, 'format ascii 1.0\n'];
header = [header, 'element vertex ', num2str(num_pts), '\n'];
header = [header, 'property float x\n'];
header = [header, 'property float y\n'];
header = [header, 'property float z\n'];
% header = [header, 'property float nx\n'];
% header = [header, 'property float ny\n'];
% header = [header, 'property float nz\n'];
header = [header, 'element face ', num2str(num_faces), '\n'];
header = [header, 'property list uchar uint vertex_indices\n'];
header = [header, 'end_header\n'];

fid = fopen(fname, 'w');
fprintf(fid, header);
data = [verts];
dlmwrite(fname, data, '-append', 'delimiter', '\t', 'precision', '%.4f');
data = uint32([3 * ones(num_faces, 1), faces - 1]);
dlmwrite(fname, data, '-append', 'delimiter', '\t', 'precision', '%d');
fclose(fid);

function n = local_find_normal(p1,p2,p3)

v1 = p2-p1;
v2 = p3-p1;
v3 = cross(v1,v2);
n = v3 ./ sqrt(sum(v3.*v3));