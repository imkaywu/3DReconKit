% Perform linear least square method (L2, BASELINE) on 'DiLiGent'
% photometric stereo data
% Author: Boxin Shi 
% Contact: boxin.shi@gmail.com
% Release date: 20160315

% 'load_datadir_re' and 'imread_datadir_re' functions are modified 
% based on the original code written by Neil Alldrin 

clc;
close all;
clear all;

dataFormat = 'PNG'; 

%==========01=========%
dataNameStack{1} = 'ball';
%==========02=========%
dataNameStack{2} = 'cat';
%==========03=========%
dataNameStack{3} = 'pot1';
%==========04=========%
dataNameStack{4} = 'bear';
%==========05=========%
dataNameStack{5} = 'pot2';
%==========06=========%
dataNameStack{6} = 'buddha';
%==========07=========%
dataNameStack{7} = 'goblet';
%==========08=========%
dataNameStack{8} = 'reading';
%==========09=========%
dataNameStack{9} = 'cow';
%==========10=========%
dataNameStack{10} = 'harvest';

for testId = 1 : 10
    dataName = [dataNameStack{testId}, dataFormat];
    datadir = ['..\pmsData\', dataName];
    bitdepth = 16;
    gamma = 1;
    resize = 1;  
    data = load_datadir_re(datadir, bitdepth, resize, gamma); 

    L = data.s;
    f = size(L, 1);
    [height, width, color] = size(data.mask);
    if color == 1
        mask1 = double(data.mask./255);
    else
        mask1 = double(rgb2gray(data.mask)./255);
    end
    mask3 = repmat(mask1, [1, 1, 3]);
    m = find(mask1 == 1);
    p = length(m);

    %% Standard photometric stereo
    Normal_L2 = L2_PMS(data, m);

    %% Save results "png"
    imwrite(uint8((Normal_L2+1)*128).*uint8(mask3), strcat(dataName, '_Normal_l2.png'));

    %% Save results "mat"
    save(strcat(dataName, '_Normal_l2.mat'), 'Normal_L2');
end
