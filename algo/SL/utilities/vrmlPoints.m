function vrmlPoints(filename,vertices,colors,normals)

% VRMLPOINTS exports a VRML point clound.
%    VRMLPOINTS(F,V,C,N) exports the 3D point cloud to a VRML file
%    for use with j3DPGP. Also handles per-vertex colors and normals
%    if they are provided.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Write VRML file.
fid = fopen(filename,'w');
fprintf(fid,'%s\r\n','#VRML V2.0 utf8');
fprintf(fid,'%s\r\n','Shape {');
fprintf(fid,'%s\r\n',' geometry IndexedFaceSet {');
fprintf(fid,'%s\r\n','  coord Coordinate {');
fprintf(fid,'%s\r\n','   point [');
fprintf(fid,'   %0.7f %0.7f %0.7f\r\n',vertices');
fprintf(fid,'%s\r\n','   ]');
fprintf(fid,'%s\r\n','  }');
if exist('normals','var') && ~isempty(normals)
   fprintf(fid,'%s\r\n','  normalPerVertex TRUE');
   fprintf(fid,'%s\r\n','  normal Normal {');
   fprintf(fid,'%s\r\n','   vector [');
   fprintf(fid,'   %0.7f %0.7f %0.7f\r\n',-normals');
   fprintf(fid,'%s\r\n','   ]');
   fprintf(fid,'%s\r\n','  }');
end
if exist('colors','var') && ~isempty(colors')
   fprintf(fid,'%s\r\n','  colorPerVertex TRUE');
   fprintf(fid,'%s\r\n','  color Color {');
   fprintf(fid,'%s\r\n','   color [');
   fprintf(fid,'   %0.7f %0.7f %0.7f\r\n',colors');
   fprintf(fid,'%s\r\n','   ]');
   fprintf(fid,'%s\r\n','  }');
end
fprintf(fid,'%s\r\n',' }');
fprintf(fid,'%s\r\n','}');
fclose(fid);