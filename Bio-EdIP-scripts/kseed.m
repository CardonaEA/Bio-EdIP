function B = kseed(A,k)

ids = find(A);
rng('default');

if numel(ids) >= k
    pos = randsample(ids,k);
    B = zeros(size(A));
    B(pos) = 1;
else
    B = zeros(size(A));
end