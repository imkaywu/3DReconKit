
% Reset Matlab environment.
clear all; clc;

% Define sequences.
objNames = {'chiquita'}; %{'boat','chiquita','drummer','man_defocused','man_defocused','man','man','osman','pig','urn'}; % object name (should correspond to a data dir.)
seqTypes = {'Gray'}; %{'Gray','Gray','Gray','bin','Gray','bin','Gray','Gray','Gray','Gray'}; % structured light sequence type ('Gray' or 'bin')

% Load sequence.
for objIdx = 1:length(objNames)
   
   % Process sequences.
   objName = objNames{objIdx};
   seqType = seqTypes{objIdx};
   disp(['Processing ',objName,'_v1_',seqType,'...']);
   load(['./data/standard/',objName,'_v1_',seqType,'.mat'],'I','J','T','A','B');

   % Save frame sequence.
   for camIdx = 1:length(T{1})
      dataDir = ['./data/',objName,' (',seqType,')/v',int2str(camIdx),'/'];
      if ~exist(dataDir,'dir')
         mkdir(dataDir)
      end
      imwrite(T{1}{camIdx},[dataDir,num2str(1,'%0.02d'),'.bmp']);
      imwrite(T{2}{camIdx},[dataDir,num2str(2,'%0.02d'),'.bmp']);
      frameIdx = 3;
      for j = 1:size(I,1)
         for i = 1:size(I,2)
            imwrite(A{j,i}{camIdx},[dataDir,num2str(frameIdx,'%0.02d'),'.bmp']);
            frameIdx = frameIdx + 1;
            imwrite(B{j,i}{camIdx},[dataDir,num2str(frameIdx,'%0.02d'),'.bmp']);
            frameIdx = frameIdx + 1;
         end
      end
   end
end

% % Save structured light patterns.
% objName = 'man_defocused';
% seqType = 'bin';
% disp(['Processing ',objName,'_v1_',seqType,'...']);
% load(['./data/standard/',objName,'_v1_',seqType,'.mat'],'projValue','P','I','offset','height','width');
% allOn  = 255*ones(height,width,'uint8');
% allOff = zeros(height,width,'uint8');
% codeDir = ['./codes/',seqType,'/'];
% if ~exist(codeDir,'dir')
%    mkdir(codeDir)
% end
% imwrite(allOn,[codeDir,num2str(1,'%0.02d'),'.bmp']);
% imwrite(allOff,[codeDir,num2str(2,'%0.02d'),'.bmp']);
% frameIdx = 3;
% for j = 1:size(I,1)
%    for i = 1:size(I,2)
%       imwrite(projValue*P{j}(:,:,i),[codeDir,num2str(frameIdx,'%0.02d'),'.bmp']);
%       frameIdx = frameIdx + 1;
%       imwrite(projValue*(1-P{j}(:,:,i)),[codeDir,num2str(frameIdx,'%0.02d'),'.bmp']);
%       frameIdx = frameIdx + 1;
%    end
% end
