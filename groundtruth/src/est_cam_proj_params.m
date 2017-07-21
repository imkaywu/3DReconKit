sensor_width_px = 1024;
sensor_height_px = 768;

% camera
K = [1119.305530520862, 0, 509.6966194130496;
  0, 1126.737016391, 384.7208799295867;
  0, 0, 1];
kc = [-0.001282763519386994, -0.007307776008209255, -9.899733709315959e-005, -0.0007536753216886466, 0];

om_cam = [0.0, 0.0, 0.0];
R_cam2world = rodrigues(om_cam / 180.0 * pi);
T_cam2world = [0.0, 0.0, 8.0]';
R_world2cam = R_cam2world';
T_world2cam = -R_cam2world' * T_cam2world;
R_cam2cv = [1, 0, 0; 0, -1, 0; 0, 0, -1];
R_world2cv = R_cam2cv * R_world2cam;
T_world2cv = R_cam2cv * T_world2cam;

% load Calib_Results_left x_1 X_1

fc_cam{1} = [K(1, 1), K(2, 2)]';
cc_cam{1} = [K(1, 3), K(2, 3)]';
kc_cam{1} = kc;
alpha_c_cam{1} = 0;
Rc_1_cam{1} = R_world2cv;
Tc_1_cam{1} = T_world2cv;
% x_1_cam{1} = x_1;
% X_1_cam{1} = X_1;
nx_cam{1} = sensor_width_px;
ny_cam{1} = sensor_height_px;
% n_sq_x_1_cam{1} = 6;
% n_sq_y_1_cam{1} = 6;
% dX_cam{1} = 30;
% dY_cam{1} = 30;

% projector
K = [1022.00280389744, 0, 508.0466121368319;
  0, 1028.158959007605, 384.1828542020089;
  0, 0, 1];
kc = [-0.004270614899211774, 0.0550382371962321, -0.0002822345152717554, -0.000962610233747488, 0];

om_proj = [0.0, -10.0, 0.0];
T_proj2world = [-1.7633, 0.0, 10.0]';
R_proj2world = rodrigues(om_proj * pi / 180.0);
R_world2proj = R_proj2world';
T_world2proj = -R_proj2world' * T_proj2world;
R_proj2pv = [1, 0, 0; 0, -1, 0; 0, 0, -1];
R_world2pv = R_proj2pv * R_world2proj;
T_world2pv = R_proj2pv * T_world2proj;
R_cam2proj = R_world2pv * R_world2cv';
T_cam2proj = T_world2pv - R_cam2proj * T_world2cv;

R_cam2proj = [0.9850266558415718, 0.0001582198237318707, -0.1724020366702698;
  -8.37665110638418e-005, 0.9999999000723332, 0.0004391338009619711;
  0.1724020889222091, -0.0004181169823163997, 0.9850265706636791];
T_cam2proj = [1405.960676575253;
  -1.557060441275899;
  2263.440681401346] * 0.001; % m => mm
% load backup ProjectedGrid_2dpoints_projectorFrame
% load 3DPoints X_1

fc_proj = [K(1, 1), K(2, 2)]'; % from manual calibration
cc_proj = [K(1, 3), K(2, 3)]';
kc_proj = kc;
alpha_c_proj = 0;
Rc_1_proj = R_cam2proj;
Tc_1_proj = T_cam2proj;
% x_1_proj = ProjectedGrid_2dpoints_projectorFrame;
% X_1_proj = X_1;
nx_proj = 1024;
ny_proj = 768;
% n_sq_x_1_proj = 6;
% n_sq_y_1_proj = 6;
% dX_proj = 30;
% dY_proj = 30;








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
    'nx_cam ny_cam ', ...
    'fc_proj cc_proj kc_proj alpha_c_proj Rc_1_proj Tc_1_proj ',...
    'nx_proj ny_proj ', ...
    'Oc Nc wPlaneCol wPlaneRow'];
eval(save_command);