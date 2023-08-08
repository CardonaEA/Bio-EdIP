function [g,SI,TI] = Regiongrow_Mat(f,S,T)

% f = double(f);

% If S is a scalar: 1x1
if isscalar(S)
    SI = (f == S);
    TI = abs(f - S) <= T;
elseif size(S,2) == 2
    % If S is an even size position vector
    S = fliplr(S) + 1;
    SI = false(size(f));
    TI = SI;
    for k = 1:size(S,1)
        x = S(k,1);
        y = S(k,2);
        SI(x,y) = true;
        Ti = abs(f - f(x,y)) <= T;
        TI = TI | Ti;
    end
else
    % If S is a seed matrix
    [x,y] = find(S);
    S = [x y];
    SI = false(size(f));
    TI = SI;
    for k = 1:size(S,1)
        x = S(k,1);
        y = S(k,2);
        SI(x,y) = true;
        Ti = abs(f - f(x,y)) <= T;
        TI = TI | Ti;
    end
end

g = imreconstruct(SI,TI);

% SI = dip_image(SI,'bin');
% TI = dip_image(TI,'bin');

% function marker_nxt = morph_reconst(marker,mask)
% 
% done = 0;
% k = 0;
% 
% while done == 0
%     k = k + 1;
%     marker_dil = dilation(marker,3);
%     marker_nxt = marker_dil & mask;
%     marker_sum = sum(marker(:));
%     marker_nxt_sum = sum(marker_nxt(:));
%     done = (marker_nxt_sum <= marker_sum);
%     marker = marker_nxt;
% end
