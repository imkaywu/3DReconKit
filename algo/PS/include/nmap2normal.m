function normal = nmap2normal(mask, nmap)
mask_ind = find(mask > 0);
mask_reso = numel(mask);
normal = zeros(numel(mask_ind), 3);
normal(:, 1) = nmap(mask_ind + 0 * mask_reso);
normal(:, 2) = nmap(mask_ind + 1 * mask_reso);
normal(:, 3) = nmap(mask_ind + 2 * mask_reso);