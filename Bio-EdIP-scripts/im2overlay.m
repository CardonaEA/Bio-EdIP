function F = im2overlay(f,mask,mode)

if nargin == 2
    mode = 'p';
elseif nargin < 2 || nargin > 3
    error('myApp:argChk', 'Wrong number of input arguments')
end

if strcmp(mode,'p')
    idx = find(imdilate(bwperim(mask,8),[0 1 0;1 1 1;0 1 0]));
elseif strcmp(mode,'f')
    idx = find(mask);
end

f8 = uint8(255*mat2gray(f));
R = f8;
G = f8;
B = f8;
R(idx) = 255;
G(idx) = 0;
B(idx) = 0;
F = cat(3,R,G,B);

% if nargout == 0
%      figure, imshow(F)
% elseif nargout > 1
%      error('myApp:argChk', 'Wrong number of output arguments')
% end

