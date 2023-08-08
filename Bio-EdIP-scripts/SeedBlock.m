function [S3,TSD,SD] = SeedBlock(S1,T)

% Inputs
% S1 >> Original seed binary image
% T  >> Reduction threshold

% Outputs
% SD  >> Seed density image
% TSD >> Thresholded seed density image
% S2  >> New seed binary image


fun1 = @(block_struct)...
    numel(find(block_struct.data))/400*ones(size(block_struct.data));

SD  = blockproc(S1,[20 20],fun1);
TSD = (SD >= T);


S2 = ordfilt2(S1.*TSD,1,ones(3));

fun2 = @(block_struct) kseed(block_struct.data,2);
S3 = blockproc(S2,[40 40],fun2);


