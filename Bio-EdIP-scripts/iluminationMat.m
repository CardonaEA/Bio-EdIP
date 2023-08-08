function g = iluminationMat(fg,w)

fg = double(fg);
w = double(w);
a = fg-w;
pmin = min(a(:));
pmax = max(a(:));

s1 = (255/(pmax - pmin));
s2 = (a - pmin);
s = s1.*s2;
g = uint8(s);
