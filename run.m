% run algorithm and compute the accuracy and completeness

is_tex = 1;
is_alb = 0;
is_spec = 1;
is_rough = 1;
is_concav = 1;

idir = '../plane_sphere/tex_spec';

%% Run MVS
for i = 2 : 3 : 8
    for j = 1 : 10
        dir = sprintf('%s/%02d%02d', idir, i, j);
        copyfile('../copy2mvs', dir);
        cmd = sprintf('pmvs2 %s/ option', dir);
        eval(cmd);
        evaluate;
        rmdir(sprintf('%s/txt/', dir));
        delete(sprintf('%s/option', dir));
        delete(sprintf('%s/vis.dat', dir));
    end
end

%% Run SL

%% Run PS

%% Run VH