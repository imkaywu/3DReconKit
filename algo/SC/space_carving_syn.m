%% Carving a Dinosaur

%% Setup
% All functions for this demo are in the "spacecarving" package and the
% data in the "DinosaurData" folder.
import spacecarving.*;
close all;


%% Load the Camera and Image Data
% This reads the "Dinosaur" directory, loading the camera definitions
% (internal and external calibration) and image file for each camera. These
% calibrations have previously been determined from the
% images using an automatic process that we won't worry about here.
cameras = loadcamera(idir, cdir);

montage( cat( 4, cameras.Image ) );
set( gcf(), 'Position', [100 100 600 600] )
axis off;


%% Convert the Images into Silhouettes
% The image in each camera is converted to a binary image using the
% blue-screen background and some morphological operators to clean up the
% edges. This becomes the "mask" referred to above. Holes in this mask are
% particularly dangerous as they will cause voxels to be carved away that
% shouldn't be - we can end up drilling a hole through the object! The
% Image Processing Toolbox functions
% <http://www.mathworks.com/access/helpdesk/help/toolbox/images/bwareaopen.html |bwareaopen|>
% and <http://www.mathworks.com/access/helpdesk/help/toolbox/images/imclose.html |imclose|>
% are your friends for this job!
for c=1:numel(cameras)
    cameras(c).Silhouette = chromakey( cameras(c).Image );
end

figure('Position',[100 100 600 300]);

subplot(1,2,1)
imshow( cameras(c).Image );
title( 'Original Image' )
axis off

subplot(1,2,2)
imshow( cameras(c).Silhouette );
title( 'Silhouette' )
axis off

makeFullAxes( gcf );

%% Work out the space occupied by the scene
% Initially we have no idea where to look for the model. We will assume
% that the model lies in the space spanned by the cameras and their
% principal view directions. We then perform a very low-res space-carve
% using all the cameras to narrow down exactly where the object is. This
% isn't foolproof, but good enough for this demo.
[xlim,ylim,zlim] = findmodel( cameras );


%% Create a Voxel Array
% This creates a regular 3D grid of elements ready for carving away. The
% input arguments set the bounding box and the approximate number of voxels
% to create. Since the voxels must be cubes, the actual number generated
% may be a little more or less. We'll start with about six million voxels
% (you may need to reduce this if you don't have enough memory).
%
% For "real world" implementations of space carving you certainly wouldn't
% create a uniform 3D matrix like this. OctTrees and other refinement
% representations give much better efficiency, both in memory and
% computational time.
voxels = makevoxels( xlim, ylim, zlim, 6000000 );
starting_volume = numel( voxels.XData );

% Show the whole scene
% figure('Position',[100 100 600 400]);
% showscene( cameras, voxels );


%% Now Include All the Views
% In this case we have 36 views (roughly every 10 degrees). For a very
% detailed model and if you have an automatic capture rig you would use far
% more - the only limit being time and disk-space. When using a computer
% controlled turn-table (as is done in museums) storage is the only real
% limitation.
for ii=1:numel(cameras)
    voxels = carve( voxels, cameras(ii) );
end
figure('Position',[100 100 600 700]);
showsurface(voxels)
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 36 carvings' )

final_volume = numel( voxels.XData );
fprintf( 'Final volume is %d (%1.2f%%)\n', ...
    final_volume, 100 * final_volume / starting_volume )

%% Get real values
% We ideally want much higher resolution, but would run out of memory.
% Instead we can use a trick and assign real values to each voxel instead
% of a binary value. We do this by moving all voxels a third of a square in
% each direction then seeing if they get carved off. The ratio of carved to
% non-carved for each voxel gives its score (which is roughly equivalent to
% estimating how much of the voxel is inside).
offset_vec = 1/3 * voxels.Resolution * [-1 0 1];
[off_x, off_y, off_z] = meshgrid( offset_vec, offset_vec, offset_vec );

num_voxels = numel( voxels.Value );
num_offsets = numel( off_x );
scores = zeros( num_voxels, 1 );
for jj=1:num_offsets
    keep = true( num_voxels, 1 );
    myvoxels = voxels;
    myvoxels.XData = voxels.XData + off_x(jj);
    myvoxels.YData = voxels.YData + off_y(jj);
    myvoxels.ZData = voxels.ZData + off_z(jj);
    for ii=1:numel( cameras )
        [~,mykeep] = carve( myvoxels, cameras(ii) );
        keep(setdiff( 1:num_voxels, mykeep )) = false;
    end
    scores(keep) = scores(keep) + 1;
end
voxels.Value = scores / num_offsets;
figure('Position',[100 100 600 700]);
showsurface( voxels );
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 36 carvings with refinement' )


%% Final Result
% For online galleries and the like we would colour each voxel from the
% image with the best view (i.e. nearest normal vector), leading to a
% colour 3D model. This makes zero difference to the volume estimate (which
% was the main purpose of the demo), but does look pretty!
figure('Position',[100 100 600 700]);
ptch = showsurface( voxels );
colorsurface( ptch, cameras );
set(gca,'Position',[-0.2 0 1.4 0.95])
axis off
title( 'Result after 36 carvings with refinement and colour' )
writeply(sprintf('%s/sphere_sc.ply', idir), ptch.Vertices, ptch.VertexNormals, round(255 * ptch.FaceVertexCData), ptch.Faces);

%% Conclusion
% Hopefully this demo has given you a taste for what is possible by simple
% image masking and space-carving. If this has whetted your appetite, have
% a look at the references below. Converting each image to a binary mask
% throws away a lot of information. Instead of using these silhouettes, we
% could use the image values (either greyscale or colour) and a
% photo-consistency constraint. This is *much* harder to get right, but
% copes much better with concavities and holes in the model.
%
% Have you ever been asked about volume estimation from images? Do you
% fancy trying this at home? Perhaps you've implemented a better way to do
% this? I'd love to hear from you
% <http://blogs.mathworks.com/loren/?p=210#respond here>.
%
%
%% File Availability
% The functions created for this demo will ultimately appear on the File Exchange.
% Once they are available, we'll update this post.  As a reminder, there's a link
% above for getting the data.
%
%% References
% Some good references for this (including the original paper that used these images) are:
%
% * *Automatic 3D model construction for turn-table sequences*, _A. W. Fitzgibbon, G. Cross, and A. Zisserman,
% In 3D Structure from Multiple Images of Large-Scale Environments, Springer LNCS 1506, pages 155--170, 1998_
% * *A Theory of Shape by Space Carving*, _K. N. Kutulakos & S. M. Seitz,
% International Journal of Computer Vision 38(3), 199–218, 2000_
% * *Foundations of Image Understanding*, Chapter 16, _edited by L. S. Davis,
% Kluwer, 2001_
