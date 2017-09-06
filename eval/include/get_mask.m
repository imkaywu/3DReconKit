function I = chromakey( im )

I = rgb2gray(im);
[h, ~, ~]=rgb2hsv(im);
msk = (h > 0.22 & h < 0.45); %0.22, 0.45
I(msk)=0;
se=strel('ball',3,3);
I_dilate=imdilate(I,se);
I_erode=imerode(I_dilate,se);
I=I_erode;
I(I > 0) = 255;
% imshow(I);
