f = K(1, 1);
w = 2 * K(1, 3);
h = 2 * K(2, 3);

V=[...
0 0 0 f -w/2  w/2 w/2 -w/2
0 0 f 0 -h/2 -h/2 h/2  h/2
0 f 0 0  f    f    f   f];

V = R'*(V-repmat(t, 1, size(V, 2)));

hold on;
lineWidth = 1;
plot3(V(1,[1 4]),V(2,[1 4]),V(3,[1 4]),'-r','LineWidth',lineWidth); % plot x-axis
plot3(V(1,[1 3]),V(2,[1 3]),V(3,[1 3]),'-g','LineWidth',lineWidth); % plot y-axis
plot3(V(1,[1 2]),V(2,[1 2]),V(3,[1 2]),'-b','LineWidth',lineWidth); % plot z-axis

plot3(V(1,[1 5]),V(2,[1 5]),V(3,[1 5]),'-k','LineWidth',lineWidth); % center to up-left corner
plot3(V(1,[1 6]),V(2,[1 6]),V(3,[1 6]),'-k','LineWidth',lineWidth); % center to up-right corner
plot3(V(1,[1 7]),V(2,[1 7]),V(3,[1 7]),'-k','LineWidth',lineWidth); % center to lower-right corner
plot3(V(1,[1 8]),V(2,[1 8]),V(3,[1 8]),'-k','LineWidth',lineWidth); % center to lower-left corner

plot3(V(1,[5 6 7 8 5]),V(2,[5 6 7 8 5]),V(3,[5 6 7 8 5]),'-k','LineWidth',lineWidth); % image plane
hold off;


% alpha_c = K(1, 2);
% fc(1) = K(1, 1);
% fc(2) = K(2, 2);
% cc(1) = K(1, 3);
% cc(2) = K(2, 3);
% % for test purpose
% nx = 640;
% ny = 480;
% dX = 100;
% dY = 100;
% 
% IP = 5*dX*[1 -alpha_c 0;0 1 0;0 0 1]*[1/fc(1) 0 0;0 1/fc(2) 0;0 0 1]*[1 0 -cc(1);0 1 -cc(2);0 0 1]*[0 nx-1 nx-1 0 0 ; 0 0 ny-1 ny-1 0;1 1 1 1 1];
% BASE = 5*dX*([0 1 0 0 0 0;0 0 0 1 0 0;0 0 0 0 0 1]);
% IP = reshape([IP;BASE(:,1)*ones(1,5);IP],3,15);
% 
% BASE = R' * (BASE - t * ones(1, 6));
% IP = R' * (IP - t * ones(1, 15));
% 
% plot3(BASE(1,:),BASE(3,:),-BASE(2,:),'b-','linewidth',2');
% hold on;
% plot3(IP(1,:),IP(3,:),-IP(2,:),'r-','linewidth',2); % plot image plane
% % text(BASE(1,2),BASE(3,2),-BASE(2,2),'X','HorizontalAlignment','center','FontWeight','bold');
% % text(BASE(1,6),BASE(3,6),-BASE(2,6),'Z','HorizontalAlignment','center','FontWeight','bold');
% % text(BASE(1,4),BASE(3,4),-BASE(2,4),'Y','HorizontalAlignment','center','FontWeight','bold');
% % text(BASE(1,1),BASE(3,1),-BASE(2,1),'Left Camera','HorizontalAlignment','center','FontWeight','bold');
% hold off;