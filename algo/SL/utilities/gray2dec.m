function D = gray2dec(G)

% Extract height, width, and length of Gray code.
height = size(G,1);
width  = size(G,2);
N      = size(G,3);

% Convert per-pixel Gray code to binary.
% See: http://en.wikipedia.org/wiki/Gray_code
B = zeros(height,width,N,'uint8');
B(:,:,1) = G(:,:,1);
for i = 2:N
   B(:,:,i) = xor(B(:,:,i-1),G(:,:,i));
end

% Convert per-pixel binary code to decimal.
D = zeros(height,width);
for i = N:-1:1
   D = D + 2^(N-i)*double(B(:,:,i));
end
D = D + 1;