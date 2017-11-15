% encode from norm map to rgb image
% 0.5 * N + 0.5 = RGB

function norm_map_rgb = encode(norm_map, mask)
    ind_mask = find(mask > 0);
    normals = zeros(numel(ind_mask), 3);
    for i = 1 : 3
        tmp = norm_map(:, :, i);
        normals(:, i) = tmp(ind_mask);
    end
    normals(:, 2) = -normals(:, 2);
    
    normals_rgb = uint8(255 * (0.5 * normals + 0.5));
    norm_map_rgb = zeros(size(norm_map), 'uint8');
    for i = 1 : 3
        norm_map_rgb(ind_mask + (i - 1) * numel(mask)) = normals_rgb(:, i);
    end
end

% function norm_map_rgb = encode(norm_map, mask)
%     norm_map(:, :, 2) = -norm_map(:, :, 2);
%     norm_map_rgb = norm_map;
%     norm_map_rgb = 0.5 * norm_map_rgb + 0.5;
%     
%     mask_0_ind = find(mask == 0);
%     for i = 1 : 3
%         norm_map_rgb(mask_0_ind + (i - 1) * numel(mask)) = 0;
%     end
%     
%     norm_map_rgb = uint8(255 * norm_map_rgb);
% end