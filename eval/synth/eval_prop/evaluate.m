% analyze the dependency between any two properties
clear, clc, close all;
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
set_path;

obj_name = 'sphere';
algos = {'ps', 'mvs', 'sl'};
props = {'tex', 'alb', 'spec', 'rough'};
prop_name = {'texture', 'albedo', 'specularity', 'roughness'};
ind = 2 : 3 : 8;
acc_map = zeros(3, 3);
cmplt_map = zeros(3, 3);
ang_mean_map = zeros(3, 3);
ang_std_map = zeros(3, 3);

for aa = 1 : numel(algos)

adir = sprintf('%s/eval_prop/%s', rdir, algos{aa});

for ii = 1 : numel(props) - 1
    
for jj = ii + 1 : numel(props)

prop_pair = sprintf('%s_%s', props{ii}, props{jj});

switch algos{aa}

case {'mvs', 'sl', 'vh'}
    
    for i = 1 : numel(ind)
        for j = 1 : numel(ind)
            idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind(i), ind(j));
            fid = fopen(sprintf('%s/result.txt', idir));
            fscanf(fid, '%s', 1); acc_map(4-j, i) = fscanf(fid, '%f', 1);
            fscanf(fid, '%s', 1); cmplt_map(4-j, i) = fscanf(fid, '%f', 1);
        end
    end
case 'ps'
    for i = 1 : numel(ind)
        for j = 1 : numel(ind)
            idir = sprintf('%s/%s/%02d%02d', adir, prop_pair, ind(i), ind(j));
            data.idir = idir;
            data.mdir = sprintf('%s/eval_algo/gt', rdir);
            eval_angle;
            ang_mean_map(4-j, i) = mean(angle_prtl);
            ang_std_map(4-j, i) = std(angle_prtl);
            clear norm_map;
        end
    end
end

clf;
switch algos{aa}

case {'mvs', 'sl', 'vh'}
    mincolor = min([acc_map(:); cmplt_map(:)]);
    maxcolor = max([acc_map(:); cmplt_map(:)]);
    subplot(1, 2, 1);
    heatmap(acc_map, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
	xlabel(prop_name{ii});
    ylabel(prop_name{jj});
    title('accuracy');
    snapnow
    subplot(1, 2, 2);
    heatmap(cmplt_map, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
	xlabel(prop_name{ii});
    ylabel(prop_name{jj});
    title('completeness');
    hp = get(subplot(1, 2, 2), 'Position');
    drawColorbar([], [], 'Colormap', 'parula', 'Colorbar', {hp}, 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
    set(gcf, 'PaperPositionMode', 'auto', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 13, 6]);
    if(~exist(sprintf('%s/result', rdir), 'dir'))
        mkdir(sprintf('%s/result', rdir));
    end
    print(sprintf('%s/result/%s_%s', rdir, algos{aa}, prop_pair), '-depsc2', '-r0');
case 'ps'
    mincolor = min([ang_mean_map(:); ang_std_map(:)]);
    maxcolor = max([ang_mean_map(:); ang_std_map(:)]);
    subplot(1, 2, 1);
    heatmap(ang_mean_map, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
    xlabel(prop_name{ii});
    ylabel(prop_name{jj});
    title('mean of angular error');
    snapnow
    subplot(1, 2, 2);
    heatmap(ang_std_map, (2:3:8)/10, (8:-3:2)/10, [], 'Colormap', 'parula', 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
    xlabel(prop_name{ii});
    ylabel(prop_name{jj});
    title('std of angular error');
    hp = get(subplot(1, 2, 2), 'Position');
    drawColorbar([], [], 'Colormap', 'parula', 'Colorbar', {hp}, 'MinColorValue', mincolor, 'MaxColorValue', maxcolor, 'TickFontSize', 30);
    set(gcf, 'PaperPositionMode', 'auto', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 13, 6]);
    if(~exist(sprintf('%s/result', rdir), 'dir'))
        mkdir(sprintf('%s/result', rdir));
    end
    print(sprintf('%s/result/%s_%s', rdir, algos{aa}, prop_pair), '-depsc2', '-r0');
end

end % end of jj

end % enf of ii

end % enf of algos

unset_path;
rmpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));