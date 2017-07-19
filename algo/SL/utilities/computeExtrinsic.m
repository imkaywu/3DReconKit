function [Tc_ext,Rc_ext,H_ext] = ...
   computeExtrinsic(fc,cc,kc,alpha_c,image_name,format_image,nX,nY,dX,dY)

% COMPUTEEXTRINSIC Determines extrinsic calibration parameters.
%    COMPUTEEXTRINSIC will find the extrinsic calibration, given
%    a set of user-selection features and the camera's intrinsic
%    calibration. Note that this function is a modified version
%    of EXTRINSIC_COMPUTATION from the Camera Calibration Toolbox.
%
%    Inputs:
%             fc: camera focal length
%             cc: principal point coordinates
%             kc: distortion coefficients
%        alpha_c: skew coefficient
%     image_name: image filename for feature extraction (without extension)
%   format_image: image format (extension)
%         nX = 1: number of rectangles along x-axis
%         nY = 1: number of rectangles along y-axis
%             dX: length along x-axis (mm) (between checkerboard rectangles)
%             dY: length along y-axis (mm) (between checkerboard rectangles)
%      
%    Outputs:
%       Tc_ext: 3D translation vector for the calibration grid
%       Rc_ext: 3D rotation matrix for the calibration grid
%        H_ext: homography between points on grid and points on image plane
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009


% Load the calibration image (assuming format is supported).
ima_name = [image_name '.' format_image];
if format_image(1) == 'p',
   if format_image(2) == 'p',
      frame = double(loadppm(ima_name));
   else
      frame = double(loadpgm(ima_name));
   end
else
   if format_image(1) == 'r',
      frame = readras(ima_name);
   else
      frame = double(imread(ima_name));
   end
end
if size(frame,3) > 1,
   I = frame(:,:,2);
end
frame = uint8(frame);

% Prompt user.
disp('     (click on the four extreme corners of the rectangular pattern, ');
disp('      starting on the bottom-left and proceeding counter-clockwise.)');

% Extract grid corners.
% Note: Assumes a fixed window size (modify as needed).
wintx = 9; winty = 9;
[x_ext,X_ext,ind_orig,ind_x,ind_y] = ...
   extractGrid(I,frame,wintx,winty,fc,cc,kc,nX,nY,dX,dY);

% Computation of the extrinsic parameters attached to the grid.
[omc_ext,Tc_ext,Rc_ext,H_ext] = ...
   compute_extrinsic(x_ext,X_ext,fc,cc,kc,alpha_c);

% Calculate extrinsic coordinate system.
Basis = X_ext(:,[ind_orig ind_x ind_orig ind_y ind_orig ]);
VX = Basis(:,2)-Basis(:,1);
VY = Basis(:,4)-Basis(:,1);
nX = norm(VX);
nY = norm(VY);
VZ = min(nX,nY)*cross(VX/nX,VY/nY);
Basis = [Basis VZ];
[x_basis] = project_points2(Basis,omc_ext,Tc_ext,fc,cc,kc,alpha_c);
dxpos = (x_basis(:,2)+x_basis(:,1))/2;
dypos = (x_basis(:,4)+x_basis(:,3))/2;
dzpos = (x_basis(:,6)+x_basis(:,5))/2;

% Display  extrinsic coordinate system.
figure(1); set(gcf,'Name','Extrinsic Coordinate System'); clf;
imagesc(frame,[0 255]); axis image; title('Extrinsic Coordinate System');
hold on
   plot(x_ext(1,:)+1,x_ext(2,:)+1,'r+');
   h = text(x_ext(1,ind_orig)-25,x_ext(2,ind_orig)-25,'O');
   set(h,'Color','g','FontSize',14);
   h2 = text(dxpos(1)+1,dxpos(2)-30,'X');
   set(h2,'Color','g','FontSize',14);
   h3 = text(dypos(1)-30,dypos(2)+1,'Y');
   set(h3,'Color','g','FontSize',14);
   h4 = text(dzpos(1)-10,dzpos(2)-20,'Z');
   set(h4,'Color','g','FontSize',14);
   plot(x_basis(1,:)+1,x_basis(2,:)+1,'g-','linewidth',2);
hold off
