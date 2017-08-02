function N = L2_PMS(data, m)

light_dir = (data.s)';
f = size(light_dir, 2);

[height, width, color] = size(data.mask);
p = length(m);

I = zeros(p, f);
for i = 1 : f
    img = data.imgs{i};
%     img = mean(img, 3);
    img = rgb2gray(img);
    img = img(m);
    I(:, i) = img;
end

L = light_dir;

S_hat = I * pinv(L);
S = zeros(size(S_hat));

signX = 1;
signY = 1; 
signZ = 1;

for i = 1 : p;
    len = sqrt(S_hat(i, 1)*S_hat(i, 1)+S_hat(i, 2)*S_hat(i, 2)+S_hat(i, 3)*S_hat(i, 3));
    S(i, 1) = signX .* (S_hat(i, 1) / len);
    S(i, 2) = signY .* (S_hat(i, 2) / len); 
    S(i, 3) = signZ .* (S_hat(i, 3) / len);
end

n_x = zeros(height*width, 1);
n_y = zeros(height*width, 1);
n_z = zeros(height*width, 1);
for i = 1 : p
    n_x(m(i)) = S(i, 1);
    n_y(m(i)) = S(i, 2);
    n_z(m(i)) = S(i, 3);
end

n_x = reshape(n_x, height, width);
n_y = reshape(n_y, height, width);
n_z = reshape(n_z, height, width);

N = zeros(height, width, 3);
N(:, :, 1) = n_x;
N(:, :, 2) = n_y; 
N(:, :, 3) = n_z;
N(isnan(N)) = 0;
