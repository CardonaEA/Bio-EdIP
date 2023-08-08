function s = edge_sobel(f)

f = double(f);
h = fspecial('sobel');
Gy = imfilter (f,h,'replicate');
Gx = imfilter (f,h','replicate');
G = (((Gx.^2)+(Gy.^2)).^(1/2));

pmin = min(G(:));
pmax = max(G(:));

a1 = (255/(pmax - pmin));
a2 = (G - pmin);
a = a1.*a2;
s = uint8(a);
