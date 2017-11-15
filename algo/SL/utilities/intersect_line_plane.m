function [p,t] = intersectLineWithPlane(q,v,w)

% INTERSECTLINES Find intersection of a line with a plane.
%    [P,T] = INTERSECTLINEWITHPLANE(Q,V,W) finds the point of intersection
%    of a line in parametric form (i.e., containing a point Q and spanned
%    by the vector V) with a plane W defined in implicit form. Note,
%    this function does not handle "pathological" cases, since they
%    do not occur in practice with the "shadow scanning" configuration.
%
% Douglas Lanman and Gabriel Taubin 
% Brown University
% 18 May 2009

% Replicate planar coefficients (if only one plane given).
if size(w,2) ~= size(q,2)
   w = repmat(w,1,size(q,2));
end

% Intersect a line(s) with a plane(s) (in 3D).
t = (w(4,:)-sum(w(1:3,:).*q))./sum(w(1:3,:).*v);
p = q + repmat(t,3,1).*v;