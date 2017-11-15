% Example based photometric stereo with multiple reference objects

%% prepare data
mask_tar = imread(data.name_mask_tar);
mask_tar(mask_tar > 0) = 1;
mask_ref{1} = imread(data.name_mask_ref{1});
mask_ref{2} = imread(data.name_mask_ref{2});
mask_ref{1}(mask_ref{1} > 0) = 1;
mask_ref{2}(mask_ref{2} > 0) = 1;

% for the online dataset
% range_radius = [160, 180]; % the range of radius is a user-defined parameter [150, 180] for cat
% center = cell(2, 1); radius = zeros(2, 1);
% [center{1}, radius(1), ~] = imfindcircles(mask_ref{1}, range_radius);
% [center{2}, radius(2), ~] = imfindcircles(mask_ref{2}, range_radius);

% for my own dataset
% fid = fopen([data.dir, 'data/mask.txt'], 'r');
% % diffuse reference
% str = textscan(fid, '%s', 1);
% num = textscan(fid, '%d %d', 2); 
% center{1} = double([num{1}(2), num{2}(2)]);
% num = textscan(fid, '%f', 1);
% radius(1) = num{1};
% % specular reference
% str = textscan(fid, '%s', 1);
% num = textscan(fid, '%d %d', 2); 
% center{2} = double([num{1}(2), num{2}(2)]);
% num = textscan(fid, '%f', 1);
% radius(2) = num{1};
% fclose(fid);

% for the synthetic dataset
clear center radius;
[center{1}, radius(1)] = imfindcircles(mask_ref{1}, [175, 185], 'Sensitivity', 0.99); % 'EdgeThreshold', 0.1: doesn't have much of an effect
[center{2}, radius(2)] = imfindcircles(mask_ref{2}, [175, 185], 'Sensitivity', 0.99);
center{1} = floor(center{1});
center{2} = floor(center{2});
radius = floor(radius);

img_tar = zeros(size(mask_tar, 1), size(mask_tar, 2), 3 * data.num_img, 'uint8');
img_ref{1} = zeros(size(mask_ref{1}, 1), size(mask_ref{1}, 2), 3 * data.num_img, 'uint8');
img_ref{2} = zeros(size(mask_ref{2}, 1), size(mask_ref{2}, 2), 3 * data.num_img, 'uint8');

for v = 1 : data.num_view % probably need to modify
% n_map_tar{v} = zeros([size(mask_tar), 3]);
    
ind_img = randperm(data.num_img);
for i = 1 : data.num_img % reshuffle the image
    % target object
    img_tar(:, :, 3 * (i - 1) + 1 : 3 * i) = imread(data.name_img_tar{ind_img(i)});
    
    % specular object
    img_ref{1}(:, :, 3 * (i - 1) + 1 : 3 * i) = imread(data.name_img_ref{ind_img(i), 1});
    
    % diffuse object
    img_ref{2}(:, :, 3 * (i - 1) + 1 : 3 * i) = imread(data.name_img_ref{ind_img(i), 2});
end

% rearrange the image data so that the data is grouped by channel
r_ind = (1 : 3 : 3 * data.num_img);
g_ind = (1 : 3 : 3 * data.num_img) + 1;
b_ind = (1 : 3 : 3 * data.num_img) + 2;
ind = [r_ind, g_ind, b_ind];
img_tar = img_tar(:, :, ind);
img_ref{1} = img_ref{1}(:, :, ind);
img_ref{2} = img_ref{2}(:, :, ind);
clear ind;

% reshape the data to a (3 * num_img X num_pixel) matrix
OV_tar = reshape(img_tar, [], size(img_tar, 3))';
OV_ref{1} = reshape(img_ref{1}, [], size(img_ref{1}, 3))';
OV_ref{2} = reshape(img_ref{2}, [], size(img_ref{2}, 3))';

OV_tar_ind = find(mask_tar(:) > 0);
OV_tar = OV_tar(:, OV_tar_ind);

OV_ref_ind{1} = find(mask_ref{1}(:) > 0);
OV_ref{1} = OV_ref{1}(:, OV_ref_ind{1});
OV_ref_ind{2} = find(mask_ref{2}(:) > 0);
OV_ref{2} = OV_ref{2}(:, OV_ref_ind{2});

OV_tar = double(OV_tar);
OV_ref{1} = double(OV_ref{1});
OV_ref{2} = double(OV_ref{2});

% % normalized each channel separately
% for i = 1 : 3
%     OV_tar_chan = OV_tar(1 + (i - 1) * data.num_img : i * data.num_img, :);
%     OV_tar(1 + (i - 1) * data.num_img : i * data.num_img, :) = OV_tar_chan ./ repmat(sqrt(sum(OV_tar_chan.^2)), data.num_img, 1);
%     OV_ref_chan = OV_ref{1}(1 + (i - 1) * data.num_img : i * data.num_img, :);
%     OV_ref{1}(1 + (i - 1) * data.num_img : i * data.num_img, :) = OV_ref_chan ./ repmat(sqrt(sum(OV_ref_chan.^2)), data.num_img, 1);
%     OV_ref_chan = OV_ref{2}(1 + (i - 1) * data.num_img : i * data.num_img, :);
%     OV_ref{2}(1 + (i - 1) * data.num_img : i * data.num_img, :) = OV_ref_chan ./ repmat(sqrt(sum(OV_ref_chan.^2)), data.num_img, 1);
% end

% normalize the whole ov vector
OV_tar = OV_tar ./ repmat(sqrt(sum(OV_tar.^2)), 3 * data.num_img, 1); % (3 x nimg) x npix
OV_ref{1} = OV_ref{1} ./ repmat(sqrt(sum(OV_ref{1}.^2)), 3 * data.num_img, 1); % (3 x nimg) x npix
OV_ref{2} = OV_ref{2} ./ repmat(sqrt(sum(OV_ref{2}.^2)), 3 * data.num_img, 1); % (3 x nimg) x npix

%% generate normal samples
num_samp = [150, 500, 3e3, 2e4, 4e4]; % add numel(OV_ref_ind)
num_cen = 3;
btw_ang = [180, 20, 10, 5, 3] * pi / 180; % add 0.5
view_dir = [0, 0, 1]';
normal_samp = cell(numel(num_samp), 1);
for i = 1 : numel(num_samp)
    normal_samp{i} = gen_normals(num_samp(i), view_dir, 180);
end

use_mex = 1;
if use_mex
    size_tar = size(mask_tar)';
    size_ref(:, 1) = size(mask_ref{1})';
    size_ref(:, 2) = size(mask_ref{2})';
    centers = [center{1}', center{2}'];
%     radius = radius - 1.0; % why???
    normals = normal_esti_coarse2fine_ps(OV_tar', OV_ref{1}', OV_ref{2}', uint32(OV_tar_ind), uint32(OV_ref_ind{1}), uint32(OV_ref_ind{2}), uint32(size_tar), uint32(size_ref), centers, radius');
else
write2file = 0;
if write2file
% write data to text files
if(~exist([data.dir, 'data/'], 'dir'))
    mkdir([data.dir, 'data/']);
end
if(~exist([data.dir, 'data/ov_tar.txt'], 'file') || data.update)
    text_write([data.dir, 'data/ov_tar.txt'], OV_tar);
    text_write([data.dir, 'data/ov_ref_1.txt'], OV_ref{1});
    text_write([data.dir, 'data/ov_ref_2.txt'], OV_ref{2});
    text_write([data.dir, 'data/ov_tar_ind.txt'], uint32(OV_tar_ind'));
    text_write([data.dir, 'data/ov_ref_ind_1.txt'], uint32(OV_ref_ind{1}'));
    text_write([data.dir, 'data/ov_ref_ind_2.txt'], uint32(OV_ref_ind{2}'));
end
end
% the code below is only for debugging purpose
for i = 600 : numel(OV_tar_ind)
    tic;
    ov_tar = OV_tar(:, i);
    c = [0, 0, 1]'; % don't need to reinitialize c to [0, 0, 1]', we start from the last best position.
    e_min = Inf;
    
    for j = 1 : numel(num_samp)
        
        normals = cell(size(c, 2), 1);
        num_vici_norm = zeros(size(c, 2), 1);
        
        for cc = 1 : size(c, 2)
            cos_ang = normal_samp{j}' * c(:, cc);
            normals{cc} = normal_samp{j}(:, cos_ang >= cos(btw_ang(j)));
            num_vici_norm(cc) = size(normals{cc}, 2);
        end
        
        for cc = 1 : size(c, 2)
%             figure(1);
%             plot3(normals{cc}(1, 1 : num_vici_norm(cc))', normals{cc}(2, 1 : num_vici_norm(cc))', normals{cc}(3, 1 : num_vici_norm(cc)), 'r.'); hold on; axis equal;
%             plot3(normals{cc}(1, num_vici_norm(cc) + 1 : end)', normals{cc}(2, num_vici_norm(cc) + 1 : end)', normals{cc}(3, num_vici_norm(cc) + 1 : end), 'b.');
%             plot3(0, 0, 0, 'k+');
%             close all;
            
            ee = zeros(num_vici_norm(cc), 1);
            err = zeros(3, 1); % one residual error for each colour channel
            
            for k = 1 : num_vici_norm(cc)
                normal = normals{cc}(1 : 2, k); normal(1) = -normal(1);
                u{1} = center{1}' + normal * radius(1); %[x, y]
                ind(1) = sub2ind(size(mask_ref{1}), floor(u{1}(2)+0.5), floor(u{1}(1)+0.5)); % round to the closest lower integer
                x = floor(u{1}(1)+0.5);
                y = floor(u{1}(2)+0.5);
                d2c = sqrt((x-center{1}(1))^2 + (y - center{1}(2))^2);
                if d2c > radius(1)
                    fprintf('Outside of mask: %.04f', d2c);
                    continue;
                end
                fprintf('Inside of mask: %.04f', d2c);
                u{2} = center{2}' + normal * radius(2);
                ind(2) = sub2ind(size(mask_ref{2}), floor(u{2}(2)+0.5), floor(u{2}(1)+0.5));
                x = floor(u{2}(1)+0.5);
                y = floor(u{2}(2)+0.5);
                d2c = sqrt((x-center{2}(1))^2 + (y - center{2}(2))^2);
                if d2c > radius(2)
                    fprintf('Outside of mask: %.04f', d2c);
                    continue;
                end
                fprintf('Inside of mask: %.04f', d2c);
                % debug start
%                 figure;
%                 subplot(1, 2, 1);
%                 imshow(img_ref{1}(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on;
%                 plot(u{1}(1), u{1}(2), 'r.');
%                 subplot(1, 2, 2);
%                 imshow(img_ref{2}(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on;
%                 plot(u{2}(1), u{2}(2), 'r.');
%                 close all;
                % debug end
                ov_ref = [OV_ref{1}(:, OV_ref_ind{1} == ind(1)), OV_ref{2}(:, OV_ref_ind{2} == ind(2))];
                % non-negative non-linear least squares
                for l = 1 : 3
                    % s1: matlab version
                    [~, err(l)] = lsqnonneg(ov_ref((l-1)*data.num_img + 1 : l * data.num_img, :), ov_tar((l-1)*data.num_img + 1: l * data.num_img));
                    % s2: not as good as matlab's version
%                     opt=solopt;
%                     opt.truex=0;
%                     opt.verbose=0;
%                     x0 = [0.5, 0.5]';
%                     out = bbnnls(ov_ref((l-1)*data.num_img + 1 : l * data.num_img, :), ov_tar((l-1)*data.num_img + 1: l * data.num_img), x0, opt);
%                     err(l) = norm(ov_tar((l-1)*data.num_img + 1: l * data.num_img) - ov_ref((l-1)*data.num_img + 1 : l * data.num_img, :) * out.x);
                    % s3: pseduo-inverse
%                     ov_ref_chan = ov_ref((l-1)*data.num_img + 1 : l * data.num_img, :);
%                     ov_tar_chan = ov_tar((l-1)*data.num_img + 1: l * data.num_img);
%                     ov_ref_chan_inv = (ov_ref_chan' * ov_ref_chan) \ ov_ref_chan';
%                     w = ov_ref_chan_inv * ov_tar_chan;
%                     resi = ov_tar_chan - ov_ref_chan * w;
%                     err(l) = sum(resi.^2);
                end
                ee(k) = sum(err);
            end
            [ee_sort, ind_sort] = sort(ee, 'ascend');
            if(j == 1)
                c = normals{1}(:, ind_sort(1 : num_cen)); % only 1 center
                ee_min = ee_sort(1 : num_cen);
                % show all potential correspondence
%                 figure(2);
%                 [y, x] = ind2sub(size(mask_tar), OV_tar_ind(i));
%                 imshow(img_tar(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on; plot(x, y, 'r+');
%                 figure(3);
%                 imshow(img_ref{2}(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on; 
%                 for ccc = 1 : size(c, 2)
%                     up = center{2}' + [-c(1, ccc); c(2, ccc)] * radius(2);
%                     plot(up(1), up(2), 'r+');
%                 end
            else
                if(ee_sort(1) < ee_min(cc))
                    c(:, cc) = normals{cc}(:, ind_sort(1));
                    ee_min(cc) = ee_sort(1);
                end
            end
        end
    end
    [~, ee_min_ind] = min(ee_min);
    c = c(:, ee_min_ind);
    
    [y, x] = ind2sub(size(mask_tar), OV_tar_ind(i));
    n_map_tar{v}(y, x, :) = reshape([-c(1), c(2), c(3)], [1, 1, 3]);
    up = center{2}' + [-c(1); c(2)] * radius(2);
    
    figure(2);
    imshow(img_tar(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on; plot(x, y, 'r+');
    figure(3);
    imshow(img_ref{2}(:, :, [1, 1 + data.num_img, 1 + 2 * data.num_img])); hold on; plot(up(1), up(2), 'r+');
    toc;
%     close all;
    % use gradient descent to further refine the result
end % end of for-loop: numel(OV_tar_ind)
end % end of if-statement: use_mex
end % end of for-loop: num_view
