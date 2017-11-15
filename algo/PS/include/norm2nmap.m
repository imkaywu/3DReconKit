function nmap = norm2nmap(mask, normal)
nmap = zeros(size(mask, 1), size(mask, 2), 3, 'double');
mask_ind = find(mask > 0);
mask_reso = numel(mask);
if (size(normal, 2) ~= 3)
    normal = normal';
end
nmap(mask_ind + 0 * mask_reso) = normal(:, 1);
nmap(mask_ind + 1 * mask_reso) = normal(:, 2);
nmap(mask_ind + 2 * mask_reso) = normal(:, 3);