function vrmlMesh(vrmlfile,texfile,vertices,faces,texCoord,texCoordIndex)

% Write VRML file.
fid = fopen(vrmlfile,'w');
fprintf(fid,'%s\r\n','#VRML V2.0 utf8');
fprintf(fid,'%s\r\n','Shape {');
if exist('texfile','var') && ~isempty(texfile)
   fprintf(fid,'%s\r\n',' appearance Appearance {');
   fprintf(fid,'%s\r\n','  texture ImageTexture {');
   fprintf(fid,'%s\r\n',['   url "',texfile,'"']);
   fprintf(fid,'%s\r\n','  }');
   fprintf(fid,'%s\r\n',' }');
end
fprintf(fid,'%s\r\n',' geometry IndexedFaceSet {');
fprintf(fid,'%s\r\n','  coord Coordinate {');
fprintf(fid,'%s\r\n','   point [');
fprintf(fid,'   %0.7f %0.7f %0.7f\r\n',vertices');
fprintf(fid,'%s\r\n','   ]');
fprintf(fid,'%s\r\n','  }');
if exist('faces','var') && ~isempty(faces)
   fprintf(fid,'%s\r\n','  coordIndex [');
   fprintf(fid,'   %d %d %d -1\r\n',faces');
   fprintf(fid,'%s\r\n','  ]');
end
if exist('texCoord','var') && ~isempty(texCoord)
   fprintf(fid,'%s\r\n','  texCoord  TextureCoordinate {');
   fprintf(fid,'%s\r\n','   point [');
   fprintf(fid,'   %0.7f %0.7f\r\n',texCoord');
   fprintf(fid,'%s\r\n','   ]');
   fprintf(fid,'%s\r\n','  }');
end
if exist('texCoordIndex','var') && ~isempty(texCoordIndex)
   fprintf(fid,'%s\r\n','  texCoordIndex [');
   fprintf(fid,'   %d %d %d -1\r\n',texCoordIndex');
   fprintf(fid,'%s\r\n','  ]');
end
fprintf(fid,'%s\r\n',' }');
fprintf(fid,'%s\r\n','}');
fclose(fid);