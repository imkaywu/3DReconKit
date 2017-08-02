% Re-organize from vector to image 

function N_est_img = normal_vec2img(N_est, height, width, m)

p = length(m);

n_x = zeros(height*width, 1);
n_y = zeros(height*width, 1);
n_z = zeros(height*width, 1);
for i = 1 : p
    n_x(m(i)) = N_est(i, 1);
    n_y(m(i)) = N_est(i, 2);
    n_z(m(i)) = N_est(i, 3);
end

n_x = reshape(n_x, height, width);
n_y = reshape(n_y, height, width);
n_z = reshape(n_z, height, width);

N = zeros(height, width, 3);
N(:, :, 1) = n_x;
N(:, :, 2) = n_y;
N(:, :, 3) = n_z;
N(isnan(N)) = 0;

N_est_img = N;



