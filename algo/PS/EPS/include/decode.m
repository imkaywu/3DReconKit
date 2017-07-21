% decode from rgb image to norm map
% 0.5 * N + 0.5 = RGB

function norm_map = decode(norm_map_rgb, mask)
    ind_mask = find(mask > 0);
    normals = zeros(numel(ind_mask), 3);
    for i = 1 : 3
        tmp = double(norm_map_rgb(:, :, i)) / 255.0;
        normals(:, i) = tmp(ind_mask);
    end
    
    normals = 2.0 * (normals - 0.5);
    normals(:, 2) = -normals(:, 2);
    normals = normals ./ repmat(sqrt(sum(normals.^2, 2)), 1, 3);
    
    norm_map = zeros(size(norm_map_rgb));
    for i = 1 : 3
        norm_map(ind_mask + (i - 1) * numel(mask)) = normals(:, i);
    end
end
% function norm_map = decode(norm_map_rgb, mask)
%     norm_map = double(norm_map_rgb) / 255.0;
%     norm_map = 2.0 * (norm_map - 0.5);
%     norm_map(:, :, 2) = -norm_map(:, :, 2);
%     
%     mask_0_ind = find(mask == 0);
%     for i = 1 : 3
%         norm_map(mask_0_ind + (i - 1) * numel(mask)) = 0;
%     end
% end