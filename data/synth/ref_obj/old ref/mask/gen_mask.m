name = '0001';
mask = rgb2gray(imread([name, '.jpg']));
mask(mask < 128) = 0;
[y, x] = find(mask);
range = [175, 185];
[center, radius] = imfindcircles(mask, range, 'Sensitivity', 0.99);
%%%%%% need to decide case by case
center = floor(center);
radius = radius(radius);
%%%%%%

% solution 1:
mask = imcircle(size(mask), center, radius, 1);

% solution 2:
% r = sqrt((x - center(1)).^2 + (y - center(2)).^2);
% x_out = x(r >= radius - 0.5);
% y_out = y(r >= radius - 0.5);
% mask(sub2ind(size(mask), y_out, x_out)) = 0;

% display
imshow(mask);
imwrite(mask, [name, '.bmp']);
imwrite(mask, '0000.bmp');