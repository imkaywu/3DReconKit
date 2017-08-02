% Re-organize from vector to image 

function S = normal_img2vec(N_est, m)

p = length(m);

Nx = N_est(:, :, 1);
Ny = N_est(:, :, 2);
Nz = N_est(:, :, 3);

S = zeros(p, 3);
S(:, 1) = Nx(m);
S(:, 2) = Ny(m);
S(:, 3) = Nz(m);




