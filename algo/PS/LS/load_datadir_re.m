function data = load_datadir_re(datadir, bitDepth, resize, gamma)
% Loads photometric stereo data from given directory.
%
%  data = load_datadir(datadir, [options])
%
% Inputs / outputs,
%  datadir : Path to the data directory
%  data    : A struct with the following fields,
%   s         : nimages x 3 light source directions
%   L         : nimages x 3 light source intensities
%   filenames : cell array of image filenames
%   imgs      : cell array of images (only if load_imgs == true)
%   mask      : Mask image (only if load_mask == true)
%
% Options (specified as name value pairs),
%  load_imgs     : Specifies whether to load images or not (default = true).
%  load_mask     : Specifies whether to load mask or not (default = true).
%  white_balance : A 3x3 matrix by which to scale the light source intensities;
%                  e.g., L = L*white_balance. Can also be a 3-vector, in which
%                  case it will be interpreted as a diagonal matrix.
%                  Default = [1,1,1].
%
% Note: The data directory must contain the files light_directions.txt,
%  light_intensities.txt, and filenames.txt.
%
% ============
% Neil Alldrin
%
% Add the "bitdepth" and "resize" parameter
% Boxin Shi (20100122)

%% Parse options
load_imgs = true;
load_mask = true;
white_balance = [1,1,1];
% if mod(numel(varargin),2)~=0
% 	error('Invalid name/value options');
% end
% for i=1:2:numel(varargin)
% 	if exist(varargin{i},'var')
% 		eval(sprintf('%s = varargin{i+1};', varargin{i}));
% 	else
% 		error('Invalid option name');
% 	end
% end
% 
if isvector(white_balance)
	white_balance = diag(white_balance);
end

%% Build data struct
if isstruct(datadir)
	data = datadir;
	% (Possibly) augment existing data struct to contain E and/or mask.
elseif ischar(datadir)
	data.s = read_floats__(fullfile(datadir,'light_directions.txt'),'%f %f %f\n');
	
	data.L = read_floats__(fullfile(datadir,'light_intensities.txt'),'%f %f %f\n');
	data.L = data.L * white_balance;
	
	data.filenames = read_strings__(fullfile(datadir,'filenames.txt'),'%s\n');
	data.filenames = cellfun(@(x)(fullfile(datadir,x)), data.filenames,'UniformOutput', false);
else
	error('datadir is neither a struct nor a string!');
end

if ~isfield(data,'mask') && load_mask
	data.mask = imread(fullfile(datadir,'mask.png'));
    data.mask = imresize(data.mask, resize, 'nearest');
end

if ~isfield(data,'imgs') && load_imgs
	data_ = data;
	data.imgs = cell(size(data.filenames));
	for i = 1:numel(data.imgs)
		data.imgs{i} = imread_datadir_re(data_, i, bitDepth, resize, gamma);
	end
end

end % main function

%% Helper
function out = read_floats__(fn,spec)

fid = fopen(fn,'rt');
out = fscanf(fid,spec,inf);
fclose(fid);
out = reshape(out,[3 length(out(:))/3])';

end

%% Helper
function out = read_strings__(fn,spec)

fid = fopen(fn,'rt');
out = textscan(fid,spec);
fclose(fid);
out = out{1};

end
