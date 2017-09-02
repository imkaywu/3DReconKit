% generate the following data
% wPlaneCol, wPlaneRow, Nc, Oc

load('calib_cam_proj.mat');
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