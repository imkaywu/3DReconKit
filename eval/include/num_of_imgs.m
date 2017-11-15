function nimgs = num_of_imgs(dire)
    files = dir(dire);
    nimgs = 0;
    for i = 1 : numel(files)
        [~, ~, ext] = fileparts(files(i).name);
        if (strcmpi(ext, '.jpg') ||...
            strcmpi(ext, '.jpeg') ||...
            strcmpi(ext, '.png'))
            nimgs = nimgs + 1;
        end
    end
end