% copy the camera calib to the image dir
copyfile(sprintf('%s/calib/results/txt', tdir), sprintf('%s/txt', idir));

% generate the option file
genOption;

% create the model dir
if (~exist(sprintf('%s/models', idir), 'dir'))
    mkdir(sprintf('%s/models', idir));
end