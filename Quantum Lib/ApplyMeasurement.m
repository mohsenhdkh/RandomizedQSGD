% inputs: 
%        M: a 1 x m array of positive semi-definite d x d matrices that
%           sum to the identity, 
%        rho: d x d density operator

function Z = ApplyMeasurement(M, rho)
m = length(M);
% computing the probabilities
p = zeros(1,m);
for i=1:m
    p(i) = trace(M{i}*rho);
end

% output

Z = randPMF(p,1:m,1);
end
