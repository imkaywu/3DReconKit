function I = chromakey( im, type )

if (nargin < 2)
    type = 'green';
end

I = rgb2gray(im);
[h, s, v]=rgb2hsv(im);
switch type
    case 'green'
        msk = (h > 0.22 & h < 0.45); %0.22, 0.45
    case 'white'
        msk = (s < 0.05 & v > 0.99);
end
I(msk)=0;
se=strel('ball',3,3);
I_dilate=imdilate(I,se);
I_erode=imerode(I_dilate,se);
I=I_erode;
I(I > 0)=255;
% imshow(I);
