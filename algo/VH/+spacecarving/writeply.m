function writeply(fname, verts, normal, color, faces)

num_pts = size(verts, 1);
num_faces = size(faces, 1);

header = 'ply\n';
header = [header, 'format ascii 1.0\n'];
header = [header, 'element vertex ', num2str(num_pts), '\n'];
header = [header, 'property float x\n'];
header = [header, 'property float y\n'];
header = [header, 'property float z\n'];
header = [header, 'property float nx\n'];
header = [header, 'property float ny\n'];
header = [header, 'property float nz\n'];
header = [header, 'property uchar red\n'];
header = [header, 'property uchar green\n'];
header = [header, 'property uchar blue\n'];
header = [header, 'element face ', num2str(num_faces), '\n'];
header = [header, 'property list uchar uint vertex_indices\n'];
header = [header, 'end_header\n'];

fid = fopen(fname, 'w');
fprintf(fid, header);
data = [verts, normal, color]';
fprintf(fid, '%.4f %.4f %.4f %.4f %.4f %.4f %d %d %d\n', data);
data = uint32([3 * ones(num_faces, 1), faces - 1]');
fprintf(fid, '%d %d %d %d\n', data);
fclose(fid);