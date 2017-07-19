function [x X ind_orig ind_x ind_y] = ...
   extractGrid(I,frame,wintx,winty,fc,cc,kc,n_sq_x,n_sq_y,dX,dY)

% EXTRACTGRID estimate the user-selected corners with refinement.
%    EXTRACTGRID is a modified version of EXTRACT_GRID from the
%    Matlab Camera Calibration Toolbox.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009


% Display the reference image (i.e., with extrinsic calibration features).
figure(1); set(gcf,'Name','Defining the Extrinsic Coordinate System'); clf;
imagesc(frame); axis image;
title('Defining the Extrinsic Coordinate System');
xlabel('click on the four extreme corners of the rectangular pattern (first corner = origin)');

% Draw the user-select features.
x= []; y = []; hold on;
for count = 1:4
   [xi,yi] = ginput3(1);
   [xxi] = cornerfinder([xi;yi],I,winty,wintx);
   xi = xxi(1); yi = xxi(2);
   plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
   plot(xi + [wintx+.5 -(wintx+.5) -(wintx+.5) wintx+.5 wintx+.5], ...
        yi + [winty+.5 winty+.5 -(winty+.5) -(winty+.5)  winty+.5], ...
        '-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
   x = [x;xi]; y = [y;yi];
   plot(x,y,'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
   drawnow;
end
plot([x;x(1)],[y;y(1)],'-','color',[ 1.000 0.314 0.510 ],'linewidth',2);
drawnow; hold off;

% Refine selected corners to sub-pixel precision.
Xc = cornerfinder([x';y'],I,winty,wintx);
x = Xc(1,:)'; y = Xc(2,:)';

% Sort the corners.
x_mean = mean(x); y_mean = mean(y);
x_v = x-x_mean; y_v = y-y_mean;
theta = atan2(-y_v,x_v);
[junk,ind] = sort(theta);
[junk,ind] = sort(mod(theta-theta(1),2*pi));
ind = ind([4 3 2 1]);
x = x(ind); y = y(ind);
   
% Remove radial distortion using OULU model.
xy_corners_undist = ...
   comp_distortion_oulu([(x' - cc(1))/fc(1);(y'-cc(2))/fc(2)],kc);
xu = xy_corners_undist(1,:)';
yu = xy_corners_undist(2,:)';

% Project grid points.
XXu = projectedGrid([xu(1);yu(1)], ...
   [xu(2);yu(2)],[xu(3);yu(3)],...
   [xu(4);yu(4)],n_sq_x+1,n_sq_y+1);
r2 = sum(XXu.^2);       
XX = (ones(2,1)*(1 + kc(1) * r2 + kc(2) * (r2.^2))) .* XXu;
XX(1,:) = fc(1)*XX(1,:)+cc(1);
XX(2,:) = fc(2)*XX(2,:)+cc(2);
Np = (n_sq_x+1)*(n_sq_y+1);

% Refine reprojected corners.
grid_pts = cornerfinder(XX,I,winty,wintx);
grid_pts = grid_pts-1;
ind_orig = (n_sq_x+1)*n_sq_y + 1;
ind_x = (n_sq_x+1)*(n_sq_y + 1);
ind_y = 1;

% Concatenate points for output.
Xi = reshape(((0:n_sq_x)*dX)'*ones(1,n_sq_y+1),Np,1)';
Yi = reshape(ones(n_sq_x+1,1)*(n_sq_y:-1:0)*dY,Np,1)';
Zi = zeros(1,Np);
Xgrid = [Xi;Yi;Zi];
x = grid_pts;
X = Xgrid;
