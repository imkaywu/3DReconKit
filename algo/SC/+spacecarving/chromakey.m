function I = chromakey( im )

I = im;
[h, ~, ~]=rgb2hsv(I);
msk = (h>0.22 & h<0.45);
I(find(msk(:))+numel(msk)*0)=0;
I(find(msk(:))+numel(msk)*1)=0;
I(find(msk(:))+numel(msk)*2)=0;
% imshow(I);
