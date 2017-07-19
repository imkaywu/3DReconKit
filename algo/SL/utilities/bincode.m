function [P,offset] = bincode(width,height)

% % Define height and width of screen.
% width  = 1024;
% height = 768;

% Generate binary codes for vertical and horizontal stripe patterns.
% See: http://en.wikipedia.org/wiki/Gray_code
P = cell(2,1);
offset = zeros(2,1);
for j = 1:2
   
   % Allocate storage for binary code stripe pattern.
   if j == 1
      N = ceil(log2(width));
%       offset(j) = floor((2^N-width)/2);
   else
      N = ceil(log2(height));
%       offset(j) = floor((2^N-height)/2);
   end
   P{j} = zeros(height,width,N,'uint8');
   
   % Generate N-bit Gray code sequence.
   B = zeros(2^N,N,'uint8');
   B_char = dec2bin(0:2^N-1);
   for i = 1:N
      B(:,i) = str2num(B_char(:,i));
   end
   
   % Store binary code stripe pattern.
   if j ==1 
      for i = 1:N
         P{j}(:,:,i) = repmat(B((1:width)+offset(j),i)',height,1);
      end
   else
      for i = 1:N
         P{j}(:,:,i) = repmat(B((1:height)+offset(j),i),1,width);
      end
   end
   
end

% % Decode Gray code stripe patterns.
% C = gray2dec(P{1})-offset(1);
% R = gray2dec(P{2})-offset(2);