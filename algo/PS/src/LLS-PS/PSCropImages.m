function PSCropImages(topDir, rawOutSuffix)

% PSCropImages(topDir, rawOutSuffix)
%
% Crop the objects and light probes from the input image.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

% Set paths.
srcDir = fullfile(topDir, 'OriginalRenamed');
dataDir = fullfile(topDir, 'ManualData');

objDir = fullfile(topDir, 'Objects');
if (~exist(objDir, 'dir'))   mkdir(objDir);   end

probeDir = cell(2,1);
for i=1:2
  probeDir{i} = fullfile(topDir, ['LightProbe-' num2str(i)]);
  if (~exist(probeDir{i}, 'dir'))   mkdir(probeDir{i});   end
end

% Crop objects from RAW images.
imgFiles = dir(fullfile(srcDir, ['Image_*.' rawOutSuffix]));
obj_bbox = textread(fullfile(dataDir, 'obj_bbox.txt'));
for iFile = 1:length(imgFiles)
  filename = imgFiles(iFile).name;
  I = imread(fullfile(srcDir, filename));
  I = I(end:-1:1, :, :);
  J = I(obj_bbox(3):obj_bbox(4), obj_bbox(1):obj_bbox(2), :);
  imwrite(J(end:-1:1, :, :), fullfile(objDir, filename));
end

% Crop light light probes from JPG images.
imgFiles = dir(fullfile(srcDir, '*.JPG'));
probes_bbox = textread(fullfile(dataDir, 'probes_bbox.txt'));
for iFile = 1:length(imgFiles)
  filename = imgFiles(iFile).name;
  I = imread(fullfile(srcDir, filename));
  I = I(end:-1:1, :, :);
  for i = 1:2
    J = I(probes_bbox(i,3):probes_bbox(i,4), ...
          probes_bbox(i,1):probes_bbox(i,2), :);
    imwrite(J(end:-1:1, :, :), fullfile(probeDir{i}, filename));
  end
end
