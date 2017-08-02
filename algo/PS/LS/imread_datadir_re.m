function E = imread_datadir_re(datadir, which_image, bitDepth, resize, gamma)
% Loads specific image for a given photometric stereo dataset
%
%  E = imread_data(datadir, which_image)
%
% datadir      : Either a directory name that can be read by load_datadir, or a
%                struct created by load_datadir.
% which_images : Specifies which images in the datadir to load (optional)
% E            : Image data (H x W x ncolors)
%
% Notes,
%  Each color channel of each image in E is normalized by the associated light
%  source intensity
%
% ============
% Neil Alldrin
%
% Add the "bitdepth" and "resize" parameter
% Boxin Shi (20100122)

% if ischar(datadir)
% 	datadir = load_datadir(datadir,'load_imgs',false, 'load_mask',false);
% end

if isfield(datadir, 'imgs')
	E = datadir.imgs{which_image};
else
	% Load image(s) from disk
    E = imread(datadir.filenames{which_image});
    E = (double(E)./ (2^bitDepth-1)).^gamma; % for float input, set bitDepth = 1;
    E = imresize(E, resize, 'nearest');
	
	[H W C] = size(E);
    % Normalize the image with light intensities
	E = reshape(reshape(E,[H*W C])*diag(1./datadir.L(which_image,:)),[H W C]);
	E = max(0,E);
end
