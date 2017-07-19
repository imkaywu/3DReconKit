function w = fitPlane(X,Y,Z)

% FITPLANE least-squared plane fitting.
%    W = FITPLANE(X,Y,Z) finds the best-fit plane P, in the least-squares
%    sense, between the points (X,Y,Z). The resulting plane P is described
%    by the coefficient vector W, where W(1)*X + W(2)*Y +W(3)*Z = W(3), for
%    (X,Y,Z) on the plane P.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Construct the linear least-squares matrix U.
meanX = mean(X(:));
meanY = mean(Y(:));
meanZ = mean(Z(:));
U = [X(:)-meanX ,Y(:)-meanY,Z(:)-meanZ];

% Determine the minimum eigenvector of U'*U.
[V,D] = eig(U'*U);
[minVal,minInd] = min(diag(D));
a = V(1,minInd);
b = V(2,minInd);
c = V(3,minInd);

% Calculate the corresponding value of d.
d = a*meanX+b*meanY+c*meanZ;

% return the parameter vector.
w = [a b c d];