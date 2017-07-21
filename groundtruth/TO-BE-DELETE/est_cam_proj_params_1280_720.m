%% notation:
%  R_a2b, T_a2b: P_b = R_a2b * P_a + T_a2b

% estimate camera and projector params
clear; clc; close all;
sensor_width_px = 1280;
sensor_height_px = 720;
aspect_ratio = sensor_width_px/sensor_height_px;
sensor_width_mm = 32;
sensor_height_mm = sensor_width_mm / aspect_ratio;
px_per_mm = sensor_width_px / sensor_width_mm;

focal_length_mm = 35;
focal_length_px = focal_length_mm * px_per_mm;

K = [focal_length_px, 0, sensor_width_px / 2;
      0, focal_length_px, sensor_height_px / 2;
      0, 0, 1];
% K = [1119.35024, 0, 511.21480;
%       0, 1127.05466, 383.59045;
%       0, 0, 1];

addpath C:\Users\Admin\Documents\3D_Recon\TOOLBOX_calib

%% camera extrinsics
om_cam = [0.0, 10.0, 0.0];
R_cam2world = rodrigues(om_cam / 180.0 * pi);
T_cam2world = [1.1, 0.0, 6.0]';
R_world2cam = R_cam2world';
T_world2cam = -R_cam2world' * T_cam2world;
R_cam2cv = [1, 0, 0; 0, -1, 0; 0, 0, -1];
R_world2cv = R_cam2cv * R_world2cam;
T_world2cv = R_cam2cv * T_world2cam;

%%%%%% start: need to change
load Calib_Results_left x_1 X_1
fc_cam{1} = [K(1, 1), K(2, 2)]';
cc_cam{1} = [K(1, 3), K(2, 3)]';
kc_cam{1} = zeros(5, 1);
alpha_c_cam{1} = 0;
Rc_1_cam{1} = R_world2cv;
Tc_1_cam{1} = T_world2cv;
x_1_cam{1} = x_1;
X_1_cam{1} = X_1;
nx_cam{1} = sensor_width_px;
ny_cam{1} = sensor_height_px;
n_sq_x_1_cam{1} = 6;
n_sq_y_1_cam{1} = 6;
dX_cam{1} = 30;
dY_cam{1} = 30;

load backup ProjectedGrid_2dpoints_projectorFrame
load 3DPoints X_1
%%%%%% end

%% projector extrinsics
om_proj = [0.0, 0.0, 0.0];
T_proj2world = [0.0, 0.0, 10.0]';
R_proj2world = rodrigues(om_proj * pi / 180.0);
R_world2proj = R_proj2world';
T_world2proj = -R_proj2world' * T_proj2world;
R_proj2pv = [1, 0, 0; 0, -1, 0; 0, 0, -1];
R_world2pv = R_proj2pv * R_world2proj;
T_world2pv = R_proj2pv * T_world2proj;
R_cam2proj = R_world2pv * R_world2cv';
T_cam2proj = T_world2pv - R_cam2proj * T_world2cv;

%%%%%% start: need to change
fc_proj = [1024, 1024]'; % from manual calibration
cc_proj = [sensor_width_px, sensor_height_px]' / 2.0;
kc_proj = zeros(5, 1);
alpha_c_proj = 0;
% Rc_1_proj = rodrigues([0.0, 10.0, 0.0]'*pi/180.0)'*rodrigues([0.0, 0.0, 0.0]'*pi/180.0);
% Tc_1_proj = rodrigues([0.0, 10.0, 0.0]'*pi/180.0)' * ([0.0, 0.0, 30.0]'-[7.0, 0.0, 25.0]');
Rc_1_proj = R_cam2proj;
Tc_1_proj = T_cam2proj;
x_1_proj = ProjectedGrid_2dpoints_projectorFrame;
X_1_proj = X_1;
nx_proj = 1024;
ny_proj = 768;
n_sq_x_1_proj = 6;
n_sq_y_1_proj = 6;
dX_proj = 30;
dY_proj = 30;
%%%%%% end

%% 
addpath('C:\Users\Admin\Documents\3D_Recon\kwStructuredLight\utilities')
% procamCalibDisplay; % currently broken

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part V: Save calibration results.

% Determine mapping from projector pixels to optical rays.
% Note: Ideally, the projected images should be pre-warped to
%       ensure that projected planes are actually planar.
c = 1:nx_proj;
r = 1:ny_proj;
[C,R] = meshgrid(c,r);
np  = pixel2ray([C(:) R(:)]',fc_proj,cc_proj,kc_proj,alpha_c_proj);
np = Rc_1_proj'*(np - Tc_1_proj*ones(1,size(np,2)));
Np = zeros([ny_proj nx_proj 3]);
Np(:,:,1) = reshape(np(1,:),ny_proj,nx_proj);
Np(:,:,2) = reshape(np(2,:),ny_proj,nx_proj);
Np(:,:,3) = reshape(np(3,:),ny_proj,nx_proj);
P = -Rc_1_proj'*Tc_1_proj;

% Estimate plane equations describing every projector column.
% Note: Resulting coefficient vector is in camera coordinates.
wPlaneCol = zeros(nx_proj,4);
for i = 1:nx_proj
   wPlaneCol(i,:) = ...
      fitPlane([P(1); Np(:,i,1)],[P(2); Np(:,i,2)],[P(3); Np(:,i,3)]);
   %figure(4); hold on;
   %plot3(Np(:,i,1),Np(:,i,3),-Np(:,i,2),'r-');
   %drawnow;
end

% Estimate plane equations describing every projector row.
% Note: Resulting coefficient vector is in camera coordinates.
wPlaneRow = zeros(ny_proj,4);
for i = 1:ny_proj
   wPlaneRow(i,:) = ...
      fitPlane([P(1) Np(i,:,1)],[P(2) Np(i,:,2)],[P(3) Np(i,:,3)]);
   %figure(4); hold on;
   %plot3(Np(i,:,1),Np(i,:,3),-Np(i,:,2),'g-');
   %drawnow;
end

% Pre-compute optical rays for each camera pixel.
for i = 1:length(fc_cam)
   c = 1:nx_cam{i};
   r = 1:ny_cam{i};
   [C,R] = meshgrid(c,r);
   Nc{i} = Rc_1_cam{1}*Rc_1_cam{i}'*pixel2ray([C(:) R(:)]'-1,fc_cam{i},cc_cam{i},kc_cam{i},alpha_c_cam{i});
   Oc{i} = Rc_1_cam{1}*Rc_1_cam{i}'*(-Tc_1_cam{i}) + Tc_1_cam{1};
end

% Save the projector/camera calibration results as calib_cam_proj.mat.
if ~exist('../calib_results','dir')
    mkdir '../calib_results'
end
save_command = ...
   ['save ../calib_results/calib_cam_proj ',...
    'fc_cam cc_cam kc_cam alpha_c_cam Rc_1_cam Tc_1_cam ',...
    'x_1_cam X_1_cam nx_cam ny_cam n_sq_x_1_cam n_sq_y_1_cam ',...
    'dX_cam dY_cam ',...
    'fc_proj cc_proj kc_proj alpha_c_proj Rc_1_proj Tc_1_proj ',...
    'x_1_proj X_1_proj nx_proj ny_proj n_sq_x_1_proj n_sq_y_1_proj '...
    'dX_proj dY_proj '...
    'Oc Nc wPlaneCol wPlaneRow'];
eval(save_command);