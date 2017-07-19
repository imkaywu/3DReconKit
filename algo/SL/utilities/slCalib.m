
% SLCALIB Visualizes the camera and projector calibration.
%    SLCALIB Displays the extrinsic calibration for the camera(s)
%    and the projector, using printed/projected checkerboards.
%     
%    Please read the accompanying assignment handout for more
%    detailed descriptions of the included support code.
%
%    This visualization code is based on the "ext_calib.m"
%    function from the Camera Calibration Toolbox for Matlab.
%    Please consult that function for additional documentation
%    of parameters and plotting functions.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Load calibration data.
load('./calib/calib_results/calib_cam_proj.mat');

% Create figure window.
% Note: Plot is in the coordinate coordinate sytem of the first camera.
figure(1); clf;
set(gcf,'Name','Structured Light Calibration');
set(gcf,'Renderer','OpenGL');

% Plot camera calibration.
for camIdx = 1:length(fc_cam)
   IP = 5*dX_cam{camIdx}*[1 -alpha_c_cam{camIdx} 0; 0 1 0;0 0 1]*...
        [1/fc_cam{camIdx}(1) 0 0; 0 1/fc_cam{camIdx}(2) 0; 0 0 1]*...
        [1 0 -cc_cam{camIdx}(1); 0 1 -cc_cam{camIdx}(2); 0 0 1]*...
        [0 nx_cam{camIdx}-1 nx_cam{camIdx}-1 0 0; 0 0 ny_cam{camIdx}-1 ny_cam{camIdx}-1 0; 1 1 1 1 1];
   BASE = 5*dX_cam{camIdx}*[0 1 0 0 0 0; 0 0 0 1 0 0; 0 0 0 0 0 1];
   IP = reshape([IP; BASE(:,1)*ones(1,5); IP],3,15);
   hold on;
      BASE = Rc_1_cam{1}*Rc_1_cam{camIdx}'*(BASE - Tc_1_cam{camIdx}*ones(1,6)) + Tc_1_cam{1}*ones(1,6);
      IP   = Rc_1_cam{1}*Rc_1_cam{camIdx}'*(IP - Tc_1_cam{camIdx}*ones(1,15)) + Tc_1_cam{1}*ones(1,15);
      plot3(BASE(1,:),BASE(3,:),-BASE(2,:),'b-','linewidth',2);
      plot3(IP(1,:),IP(3,:),-IP(2,:),'r-','linewidth',2);
      u = [6*dX_cam{camIdx} 0 0; -dX_cam{camIdx} 0 5*dX_cam{camIdx}; ...
           0 6*dX_cam{camIdx} 0; -dX_cam{camIdx} -dX_cam{camIdx} -dX_cam{camIdx}]';
      u = Rc_1_cam{1}*Rc_1_cam{camIdx}'*(u - Tc_1_cam{camIdx}*ones(1,4)) + Tc_1_cam{1}*ones(1,4);
      text(u(1,1),u(3,1),-u(2,1),['X_{c',int2str(camIdx),'}']);
      text(u(1,2),u(3,2),-u(2,2),['Z_{c',int2str(camIdx),'}']);
      text(u(1,3),u(3,3),-u(2,3),['Y_{c',int2str(camIdx),'}']);
      text(u(1,4),u(3,4),-u(2,4),['O_{c',int2str(camIdx),'}']);
   hold off;
end

% Plot projector calibration results (in camera coordinate system).
IP = 5*dX_proj*[1 -alpha_c_proj 0; 0 1 0;0 0 1]*...
     [1/fc_proj(1) 0 0; 0 1/fc_proj(2) 0; 0 0 1]*...
     [1 0 -cc_proj(1); 0 1 -cc_proj(2); 0 0 1]*...
     [0 nx_proj-1 nx_proj-1 0 0; 0 0 ny_proj-1 ny_proj-1 0; 1 1 1 1 1];
BASE = 5*dX_proj*[0 1 0 0 0 0; 0 0 0 1 0 0; 0 0 0 0 0 1];
IP = reshape([IP; BASE(:,1)*ones(1,5); IP],3,15);
BASE = Rc_1_proj'*(BASE - Tc_1_proj*ones(1,6));
IP = Rc_1_proj'*(IP - Tc_1_proj*ones(1,15));
hold on;
  plot3(BASE(1,:),BASE(3,:),-BASE(2,:),'b-','linewidth',2);
  plot3(IP(1,:),IP(3,:),-IP(2,:),'g-','linewidth',2);
  u = [6*dX_proj 0 0; -dX_proj 0 5*dX_proj; ...
       0 6*dX_proj 0; -dX_proj -dX_proj -dX_proj]';
  u = Rc_1_proj'*(u - Tc_1_proj*ones(1,4));
  text(u(1,1),u(3,1),-u(2,1),'X_p');
  text(u(1,2),u(3,2),-u(2,2),'Z_p');
  text(u(1,3),u(3,3),-u(2,3),'Y_p');
  text(u(1,4),u(3,4),-u(2,4),'O_p');
hold off;

% Update plot properties.
xlabel('X_{c1}'); ylabel('Z_{c1}'); zlabel('Y_{c1}');
view(50,20); grid on; rotate3d on;
axis equal tight vis3d;
