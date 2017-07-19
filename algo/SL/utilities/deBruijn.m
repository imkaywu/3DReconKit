function P = deBruijn(width,height,stripeSize,plotResults)

% DEBRUIJN Generates real-time shape acquisition patterns.
%    This routine uses the method described by Zhang et al. to 
%    create color structured light patterns for real-time
%    shape acquisition. The individual color channels consist 
%    of binary sequences generated from a de Bruijn sequence.
%
%    The de Bruijn sequences are obtained from: 
%       http://theory.cs.uvic.ca/gen/neck.html.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Define width and height of output pattern.
if ~exist('width','var') || ~exist('height','var')
   width  = 1024;
   height = 768;
end

% Select strip size (in final projected patterns).
if ~exist('stripeSize','var')
   stripeSize = [6 6]; % [height width]
end

% Enable/disable plotting routines.
if ~exist('plotResults','var')
   plotResults = true;
end

% Define de Bruijn sequence (for k = 5, n = 3).
S = ['0001002003004011012013014',...
     '0210220230240310320330340',...
     '4104204304411121131141221',...
     '2312413213313414214314422',...
     '2322423323424324433343444'];
dB = str2num(S')'+1;

% Define XOR patterns (i.e., allowed color transitions).
D = [0 0 1;...
     0 1 0;...
     0 1 1;...
     1 0 0;...
     1 0 1];

% Define the initial color (in output sequence).
C0 = [0 0 0];

% Create a color sequence from the de Bruijn sequence.
C = zeros(length(dB),3);
C(1,:) = C0;
for i = 1:(length(dB)-1)
   C(i+1,:) = xor(C(i,:),D(dB(i),:));
end

% Create a structured light pattern (with horizontal stripes).
CC = cat(3,C(:,1)',C(:,2)',C(:,3)');
nStripes = ceil([height width]./stripeSize);
nCopies = ceil(nStripes./length(dB));
CR{1} = repmat(CC,[1 nCopies(1) 1]);
P{1} = reshape(repmat(CR{1},[stripeSize(1) 1 1]),[stripeSize(1)*size(CR{1},2) 1 3]);
P{1} = P{1}(1:height,:,:);
P{1} = uint8(255*repmat(P{1},[1 width 1]));

% Create a structured light pattern (with vertical stripes).
CR{2} = repmat(CC,[1 nCopies(2) 1]);
P{2} = reshape(repmat(CR{2},[stripeSize(2) 1 1]),[1 stripeSize(2)*size(CR{2},2) 3]);
P{2} = P{2}(1,1:width,:);
P{2} = uint8(255*repmat(P{2},[height 1 1]));

% Display results (if enabled).
% Note: Compare to Figure 4 from Zhang et al.
if plotResults
   figure(1); subplot(2,1,1); imagesc(C'); colormap(gray); set(gca,'YTickLabel',[]);
   figure(1); subplot(2,1,2); imagesc(CC); colormap(gray); set(gca,'YTickLabel',[]);
   figure(2); subplot(1,2,1); imagesc(P{1}); axis image;
   figure(2); subplot(1,2,2); imagesc(P{2}); axis image;
end