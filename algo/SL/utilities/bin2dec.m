function D = gray2dec(B)

% Extract height, width, and length of Gray code.
height = size(B,1);
width  = size(B,2);
N      = size(B,3);

% Convert per-pixel binary code to decimal.
D = zeros(height,width);
for i = N:-1:1
   D = D + 2^(N-i)*double(B(:,:,i));
end
D = D + 1;