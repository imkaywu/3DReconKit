% delete the camera calib to the image dir
rmdir(sprintf('%s/txt', idir), 's');

% generate the option file
delete(sprintf('%s/%s', idir, foption));
