function h = fscatter3(X,Y,Z,C,cmap)

% FSCATTER3 effcient 3d scatter plot.
%    H = FSCATTER3(X,Y,Z,C.MAP) is a faster version of SCATTER3
%    which can be used to render colored point clouds. The 3d points
%    are defined by the N element column vectors X, Y, and Z, and
%    the per-vertex colors by the Nx3 matrix C. This function
%    was derived from FSCATTER3 by Felix Morsdorf, which is 
%    available on Matlab Central:
%
%       http://www.mathworks.com/matlabcentral/fileexchange/
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Parse input and assign default values (if required).
if ~exist('cmap','var') || isempty(cmap)
   numclass = 256;
   cmap = hsv(256);
elseif exist('cmap','var') && ~isempty(cmap)
   numclass = size(cmap,1);
   if numclass == 1
      cmap = hsv(256);
      numclass = 256;
   end
end
% Construct colormap.
mins = min(C); maxs = max(C);
col = cmap;

% Determine index into colormap.
ii = round(interp1([floor(mins) ceil(maxs)],[1 numclass],C));
hold on; colormap(cmap);

% Plot each color class in a loop.
k = 0; h = [];
for j = 1:numclass
   jj = find(ii == j);
   if ~isempty(jj)
      k = k + 1;
      h(k) = plot3(X(jj),Y(jj),Z(jj),'.','color',col(j,:), ...
         'markersize',7);
   end
end