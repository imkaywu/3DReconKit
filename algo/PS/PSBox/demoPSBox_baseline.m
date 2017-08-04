%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

rng(0);

%% Setup parameters.
% Change the 'topDir' to your local data directory.
topDir = fullfile(fileparts(mfilename('fullpath')), 'data');
gt_dir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/3DRecon_Algo_Eval/groundtruth/calib_results';
% The format of output (decoded) RAW images.
rawOutSuffix = 'jpg';
% The image channel used to perform photometric stereo.
imgChannel = 1;
% The intensity threshold for shadow, in [0, 1].
shadowThresh = 0.1;

%% Load data and prepare to do photometric stereo.

fprintf('Loading data...\n');
% Load lighting directions.
L = textread(fullfile(gt_dir, 'light_directions.txt'));
% Load images.
loadOpts = struct('ImageChannel', imgChannel, ...
                  'NormalizePercentile', 99);
I = PSLoadProcessedImages(idir, rawOutSuffix, loadOpts); % do a flipud
nImgs = size(I, 3);
% Create a shadow mask.
shadow_mask = (I > shadowThresh);
se = strel('disk', 5);
for i = 1:nImgs
  % Erode the shadow map to handle de-mosaiking artifact near shadow boundary.
  shadow_mask(:,:,i) = imerode(shadow_mask(:,:,i), se);
end
% mask of object
mask = imread(sprintf('%s/gt/mask.bmp', rdir));

%% Estimate the normal vectors.
% Without using light strength estimation.
fprintf(['Estimating normal vectors and albedo (without light strength ' ...
         'estimation) ...\n']);
[rho, n] = PhotometricStereo(I, shadow_mask, L);
% Evaluate normal estimate by intensity error.
evalOpts = struct('Display', 1);
Ierr = EvalNEstimateByIError(rho, n, I, shadow_mask, L, evalOpts);
%{
%% Estimate lighting strength.
fprintf('Estimating lighting strength...\n');
lsOpts = struct('nSamples', 1000);
lambda = PSEstimateLightStrength(I, shadow_mask, L, lsOpts);
L2 = repmat(lambda', [3 1]) .* L;

[rho, n] = PhotometricStereo(I, shadow_mask, L2);
Ierr = EvalNEstimateByIError(rho, n, I, shadow_mask, L2, evalOpts);

%% Refine the lighting matrix.
fprintf('Refine lighting direction and strength...\n');
rlOpts = struct('nSamples', 1000);
L = PSRefineLight(L, I, shadow_mask, rlOpts);
dlmwrite(fullfile(topDir, 'refined_light.txt'), L, 'precision', '%20.16f');

[rho, n] = PhotometricStereo(I, shadow_mask, L);
Ierr = EvalNEstimateByIError(rho, n, I, shadow_mask, L, evalOpts);
%}

%% Visualize the normal map.
figure; imshow(n); axis xy;

%% Estimate depth map from the normal vectors.
fprintf('Estimating depth map from normal vectors...\n');
p = -n(:,:,1) ./ n(:,:,3);
q = -n(:,:,2) ./ n(:,:,3);
p(isnan(p)) = 0;
q(isnan(q)) = 0;
Z = DepthFromGradient(p, q);
% Visualize depth map.
figure;
Z(isnan(n(:,:,1)) | isnan(n(:,:,2)) | isnan(n(:,:,3))) = NaN;
surf(Z, 'EdgeColor', 'None', 'FaceColor', [0.5 0.5 0.5]);
axis equal; camlight;
view(-75, 30);

%% write to color image
% flip the normal map upside down and flip the sign of n_y
n = n(end : -1 : 1, :, :);
n(:, :, 2) = -n(:, :, 2);
n_rgb = encode(n, mask);
imwrite(n_rgb, sprintf('%s/normal.png', idir));