function g = integrate_horn2(gx,gy,mask,niter,verbose,filename,init)
%function g = integrate_horn(gx,gy,mask,niter,verbose,filename,init)
% integrate_horn.m recovers the function g from its
% partial derivatives gx and gy. mask is a binary
% image which tells which pixels are involved in 
% integration. niter is the number of iterations.
% typically 100,000 or 200,000, although the trend
% can be seen even after 1000 iterations. 
% verbose gives the option of displaying or 
% not displaying intermediate  value of g. 
% g is displayed every 1000 iterations if
% verbose is 1.
% In the given example, I have included gx, gy
% and the mask. The usage is: 
%integrate_horn(gx,gy,mask,5000,1). 
% Also, note that integrate_horn integrates in 
% a piecewise manner. In the example, we
% are showing a sphere in front of a back-
% ground, The sphere is segmented out as
% one object and the background is another
% object. mask ensures that we integrate
% only the region belonging to the sphere. 
% To integrate the background,we will have
% to run integrate_horn.m all over again with a 
% different mask. Lastly, x is the dimension
% from left to right  and y is from top 
% to bottom.

interval = 10000;

if nargin < 6;
    save_flag = 0;
else
    save_flag = 1;
end

[N1,N2]=size(gx);
if nargin < 7;
    g= ones(N1,N2);
else
    fprintf('reading data');
  g = struct2array(load(init,'g'));
end

gx = gx.*mask; 
gy = gy.*mask; 

tic;
A = [0 1 0;
     0 0 0
     0 0 0]; % y-1
   
B = [0 0 0;
     1 0 0;
     0 0 0]; % x-1

C = [0 0 0 
     0 0 1
     0 0 0]; % x+1

D = [0 0 0;
     0 0 0;
     0 1 0]; % y+1
   
d_mask = A+B+C+D;

den = conv2(mask,d_mask,'same').*mask;
den(den==0)=1;
rden=1.0 ./den;
m_a = conv2(mask,A,'same');
m_b = conv2(mask,B,'same');
m_c = conv2(mask,C,'same');
m_d = conv2(mask,D,'same');

term_right =  m_c.*gx +m_d.*gy;
t_a = -conv2(gx,B,'same');
t_b = -conv2(gy,A,'same');
term_right = term_right+t_a+t_b;


fprintf('\n');
mask2=rden.*mask;
term_right_tmp=mask2.*term_right;
for k=1:niter
    g = mask2.*conv2(g,d_mask,'same') +term_right_tmp;

    if(verbose)
        if mod(k,1000) == 0;
            handle=figure(1);
            imagesc(g);
            axis image;
            axis off
            axis equal
            colormap jet;
            drawnow;
            fprintf('%d\n',k);
        end
    end

    if save_flag & mod(k, interval ) == 0;
        fprintf('saving\n');
        save(filename,'g');
    end;
    
end;

if save_flag;
    save(filename,'g');
end