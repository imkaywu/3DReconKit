%% This function aims to generate the candidate normals based on the 
% pre-specified number of number of samples. 
% We use uniform sampling on the sphere which each candiate nomral with
% the same angular spacing between the nearest neighbors. 

% Input: 
% numSamples: 150 for 10 degree sampling
%             500 for 5 degree sampling
%             3e3 for 3 degree sampling 
%             2e4 for 1 degree sampling 
%             4e4 for 1 degree sampling, 0.5

% viewDiection: the viewDiection for the scene

% sAng: the range of the elevation angles  
%       should be 180 for the sphere 
%       

% Output:
% Only the visable surface normals under viewD will return
% for example, 75 surfacenormals will retrun for 10 degree sampling

function normals = gen_norms(numSamples, viewDirection, sAng)
idx = 1;
fac = pi*sAng/180;

for i = numSamples: -1: 0
    phi = acos((-1+2*i/numSamples));
    theta = sqrt(numSamples*pi)*phi;
    if phi <= fac
        temp = [cos(theta)*sin(phi); sin(theta)*sin(phi); cos(phi)];
        if (temp'*viewDirection) >= 0
            normals(:, idx) = temp;
            idx = idx + 1;
        end
    else
        break;
    end
end