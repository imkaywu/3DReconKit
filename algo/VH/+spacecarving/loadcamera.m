function cameras = loadcamera(idir, cdir, idx)
%LOADCAMERADATA: Load the dino data
%
%   CAMERAS = LOADCAMERADATA() loads the dinosaur data and returns a
%   structure array containing the camera definitions. Each camera contains
%   the image, internal calibration and external calibration.
%
%   CAMERAS = LOADCAMERADATA(IDX) loads only the specified file indices.
%
%   Example:
%   >> cameras = loadcameradata(1:3);
%   >> showcamera(cameras)
%
%   See also: SHOWCAMERA

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.0 $    $Date: 2006/06/30 00:00:00 $

if nargin<3
    ntxt = numel(dir(cdir)) - 2;
    idx = 1 : ntxt;
end

cameras = struct( ...
    'Image', {}, ...
    'P', {}, ...
    'K', {}, ...
    'R', {}, ...
    'T', {}, ...
    'Silhouette', {} );

%% First, import the camera Pmatrices
rawP.P = cell(1, numel(idx));
for ii=idx(:)'
    fname = sprintf('%s/%04d.txt', cdir, ii - 1);
    if(~exist(fname, 'file'))
        fname = sprintf('%s/%08d.txt', cdir, ii - 1);
    end
    fid = fopen(fname);
    fgets(fid);
    tmp = fscanf(fid, '%f');
    rawP.P{ii} = [tmp(1), tmp(2), tmp(3), tmp(4);
                 tmp(5), tmp(6), tmp(7), tmp(8);
                 tmp(9), tmp(10), tmp(11), tmp(12)];
    fclose(fid);
end


%% Now loop through loading the images
tmwMultiWaitbar('Loading images',0);
for ii=idx(:)'
    % We try both JPG and PPM extensions, trying JPEG first since it is
    % the faster to load
    filename = sprintf('%s/%04d.jpg', idir, ii - 1);
    if (~exist(filename, 'file'))
        filename = sprintf('%s/%08d.jpg', idir, ii - 1);
    end
    
    [K,R,t] = spacecarving.decomposeP(rawP.P{ii});
    cameras(ii).rawP = rawP.P{ii};
    cameras(ii).P = rawP.P{ii};
    cameras(ii).K = K/K(3,3);
    cameras(ii).R = R;
    cameras(ii).T = -R'*t;
    cameras(ii).Image = imread( filename );
    cameras(ii).Silhouette = [];
    tmwMultiWaitbar('Loading images',ii/max(idx));
end
tmwMultiWaitbar('Loading images','close');

