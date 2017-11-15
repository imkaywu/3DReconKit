% genOption
fid = fopen(sprintf('%s/%s', idir, foption), 'w');
fprintf(fid, 'level %d\n', 1);
fprintf(fid, 'csize %d\n', 2);
fprintf(fid, 'threshold %0.1f\n', 0.7);
fprintf(fid, 'wsize %d\n', 3);
fprintf(fid, 'minImageNum %d\n', 3);
fprintf(fid, 'CPU %d\n', 8);
fprintf(fid, 'setEdge %d\n', 0);
fprintf(fid, 'useBound %d\n', 0);
fprintf(fid, 'useVisData %d\n', 0);
fprintf(fid, 'sequence %d\n', -1);
fprintf(fid, 'maxAngle %d\n', 10);
fprintf(fid, 'quad %0.1f\n', 2.0);
fprintf(fid, 'timages %d %d %d\n', -1, 0, nimgs);
fprintf(fid, 'oimages %d\n', 0);
fclose(fid);