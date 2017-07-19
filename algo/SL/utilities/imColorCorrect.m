function [J,clamp_J] = imColorCorrect(I,C)

% IMCOLORCORRECT Color correction for RGB images.
%    IMCOLORCORRECT implements linear color correction
%    for an input RGB image. The method follows that of
%    Zhang et al. (originally that of Caspi et al.). The
%    input image I is tranformed by the linear color
%    calibration matrix C to produce image J. The clamped
%    RGB values on [0,255] are also returned.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Convert input image to double precision.
if ~isfloat(I)
   I = 255*im2double(I);
end

% Apply linear transformation to input image.
x = reshape(I,size(I,1)*size(I,2),3)*(C');
J = reshape(x,size(I,1),size(I,2),3);

% Clamp values to [0,255] range.
clamp_J = uint8(J);