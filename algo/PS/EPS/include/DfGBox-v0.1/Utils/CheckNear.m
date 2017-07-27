function success = CheckNear(v1, v2, tol)

% CheckNear(v1, v2, tol)
% success = CheckNear(v1, v2, tol)
%
% Check whether matrix 'v1' and 'v2' are close to each other under tolerance
% 'tol' under the following absolute/relative sense:
%   ||v1 - v2|| <= tol, **or**
%   ||v1 - v2|| / max(||v1||, ||v2||) <= tol,
% where ||.|| is the l2 norm.
%
% Return true if the check succeeded. If no output is assumed, the function will
% produce an error message.
%
%   Author: Ying Xiong.
%   Created: Jul 04, 2013.

errAbs = norm(v1-v2);
errRel = norm(v1-v2)/(max(norm(v1), norm(v2)));
success = (errAbs <= tol) || (errRel <= tol);
if (nargout==0 && ~success)
  fprintf('v1 = \n');
  disp(v1);
  fprintf('v2 = \n');
  disp(v2);
  fprintf('v1 - v2 = \n');
  disp(v1 - v2);
  fprintf('||v1-v2|| = %f\n', errAbs);
  fprintf('||v1-v2|| / max(||v1||, ||v2||) = %f\n', errRel);
  fprintf('Tolerance = %f\n', tol);
  error('CheckNear failed.');
end
