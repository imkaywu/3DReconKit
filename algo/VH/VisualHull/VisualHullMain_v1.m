clear; close all;
addpath('C:\Users\Daniela\Documents\3D_Recon\TOOLBOX_calib');
file_base = 'box';
dir = ['C:/Users/Admin/Documents/Data/MVS+VH/', file_base, '/'];
img_dir = [dir, 'visualize/'];
mask_dir = [dir, 'mask/'];
txt_dir = dir;
model_dir = [dir, 'models/'];

T = 20; % threshold to get object silhouette

%% 1 load camera params
fid = fopen([txt_dir 'cameras_v2.txt'], 'r');
for i=1:16
    fgets(fid);
end
num_imgs = textscan(fid, '%d', 1); num_imgs = num_imgs{1}; fgets(fid);
for i=1:num_imgs
    % blank line, name, dir
    for j=1:3
        fgets(fid);
    end
    f = textscan(fid,'%f', 1); f = f{1}; % focal length
    cc = textscan(fid, '%f', 2); cc = cc{1,1}; % 2-vec principle point
    T = textscan(fid, '%f', 3); T = T{1,1}; % 3-vec translation T
    fgets(fid); fgets(fid); % 3-vec camera position
    om = textscan(fid, '%f', 3); om = om{1,1}; % 3-vec axis angle format of R
    % 4-vec quaternion, R
    for j=1:5
        fgets(fid);
    end
    d = textscan(fid, '%f', 1); d = d{1}; % normalized radial distortion
    fgets(fid); fgets(fid);
    K = [f, 0, cc(1); 0, f, cc(2); 0, 0, 1];
    R = rodrigues(om);
    t = T;
    M(:,:,i) = K*[R t];
end
fclose(fid);

%% 2 load images and masks
for i=1:num_imgs
%     I = rgb2gray(imread(sprintf([mask_dir, '%08d.jpg'], i-1)));
%     I(I ~= 255) = 1;
%     I(I == 255) = 0;
%     masks(:,:,i) = I;
    
    masks(:,:,i) = imread(sprintf([mask_dir, '%08d.bmp'], i-1));

%     edge_mask = edge(masks(:,:,i),'canny');
%     imgs(:,:,:,i) = imread([img_dir num2str(i-1, '%08i') '.jpg']);
%     imshow(imgs(:,:,:,i)); hold on;
%     [y,x]=find(edge_mask);plot(x,y,'r');hold off;
end
% clear imgs;

%% 3 compute silhouettes
% for i=1:size(imgs,4)
%      ch1 = imgs(:,:,1,i)>T;
%      ch2 = imgs(:,:,2,i)>T;
%      ch3 = imgs(:,:,3,i)>T;
%      silhouettes(:,:,i) = (ch1+ch2+ch3)>0;
% end
silhouettes = masks;

%% 4 create voxel grid
voxel_size = [0.002 0.002 0.002];

switch file_base
    case 'dinoSR'
        % dinoSR bounding box
        xlim = [-0.07 0.02];
        ylim = [-0.02 0.07];
        zlim = [-0.07 0.02];
    case 'dinoR'
        % dinoR bounding box
        xlim = [-0.03 0.06];
        ylim = [0.022 0.11];
        zlim = [-0.02 0.06];

    case 'templeSR'
        % templeSR bounding box
        xlim = [-0.08 0.03];
        ylim = [0.0 0.18];
        zlim = [-0.02 0.06];

    case 'templeR'
        % templeR bounding box
        xlim = [-0.05 0.11];
        ylim = [-0.1 0.15];
        zlim = [-0.1 0.06];
        
    otherwise
%         xlim = [0.8 2.3];
%         ylim = [-0.15 0.25];
%         zlim = [0.1 1.4];
        pts = ply_read([dir, 'models/option-0000.ply']);
        xlim = [round(100 * (min(pts(1, :)) - voxel_size(1) * 5))/100, round(100 * (max(pts(1, :)) + voxel_size(1) * 5))/100];
        ylim = [round(100 * (min(pts(2, :)) - voxel_size(1) * 5))/100, round(100 * (max(pts(2, :)) + voxel_size(1) * 5))/100];
        zlim = [round(100 * (min(pts(3, :)) - voxel_size(1) * 5))/100, round(100 * (max(pts(3, :)) + voxel_size(1) * 5))/100];
        clear pts;
end

disp('init voxel grid');
[voxels, voxel3Dx, voxel3Dy, voxel3Dz, voxels_number] = InitializeVoxels(xlim, ylim, zlim, voxel_size);


%% 5 project voxel to silhouette
disp('create visual hull');
display_projected_voxels = 0;
[voxels_voted] = CreateVisualHull(silhouettes, voxels, M, display_projected_voxels);


% % display voxel grid
% voxels_voted1 = (reshape(voxels_voted(:,4), size(voxel3Dx)));
% maxv = max(voxels_voted(:));
% fid = figure;
% for j=1:size(voxels_voted1,3), 
%     figure(fid), imagesc((squeeze(voxels_voted1(:,:,j))), [0 maxv]), title([num2str(j), ' - press any key to continue']), axis equal, 
%     pause,
% end

%% 6 apply marching cube algorithm and display the result
error_amount = 5;
maxv = max(voxels_voted(:,4));
iso_value = maxv-round(((maxv)/100)*error_amount)-0.5;
disp(['max number of votes:' num2str(maxv)])
disp(['threshold for marching cube:' num2str(iso_value)]);

[voxel3D] = ConvertVoxelList2Voxel3D(voxels_number, voxel_size, voxels_voted);

[fv]  = isosurface(voxel3Dx, voxel3Dy, voxel3Dz, voxel3D, iso_value, voxel3Dz);
[faces, verts, colors]  = isosurface(voxel3Dx, voxel3Dy, voxel3Dz, voxel3D, iso_value, voxel3Dz);

% for coloring VH, comment below
% verts_min =  min(verts);
verts_max =  max(verts);
% verts_diff = abs(verts_max-verts_min);
% 
% verts(:,1) = verts(:,1) - verts_min(1)-verts_diff(1)/2;
% verts(:,2) = verts(:,2) - verts_min(2)-verts_diff(2)/2;

fv.vertices = verts;
verts = verts/max(verts_max);


fid = figure; 
p=patch('vertices', verts, 'faces', faces, ... 0 
    'facevertexcdata', colors, ... 
    'facecolor','flat', ... 
    'edgecolor', 'interp');

set(p,'FaceColor', [0.5 0.5 0.5], 'FaceLighting', 'flat',...
    'EdgeColor', 'none', 'SpecularStrength', 0, 'AmbientStrength', 0.4, 'DiffuseStrength', 0.6);

set(gca,'DataAspectRatio',[1 1 1], 'PlotBoxAspectRatio',[1 1 1],...
    'PlotBoxAspectRatioMode', 'manual');

axis vis3d;

light('Position',[1 1 0.5], 'Visible', 'on');
light('Position',[1 -1 0.5], 'Visible', 'on');
light('Position',[-1 1 0.5], 'Visible', 'on');
light('Position',[-1 -1 0.5], 'Visible', 'on'); 

ka = 0.1; kd = 0.4; ks = 0;
material([ka kd ks])

axis equal;
axis tight
axis off

%% 7 save VH to stl file
cdate = datestr(now, 'yyyy.mm.dd');
filename = [model_dir file_base '_VH_' cdate '.stl'];
patch2stl(filename, fv);