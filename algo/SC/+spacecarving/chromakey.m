function I = chromakey( im, type )

if (nargin < 2)
    type = 'green';
end

I = rgb2gray(im);
[h, s, v]=rgb2hsv(im);
switch type
    case 'green'
        msk = (h > 0.2 & h < 0.4); %0.22, 0.45
    case 'white'
        msk = (s < 0.05 & v > 0.95);
end
I(msk)=0;

% imshow(I);
