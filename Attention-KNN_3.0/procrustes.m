function [Aa] = procrustes(B,A)
    B = B';
    A = A';    
    d = size(A,1);
    n = size(A,2);
    muA = A*ones(n,1)/n;
    muB = B*ones(n,1)/n;
    A0 = A - muA*ones(n,1)';
    B0 = B - muB*ones(n,1)';
    [U,S,V] = svd(B0*A0');
    Q = U*V';
    %a = 1.02;
    a = trace(B0*A0'*Q') / trace(A0*A0');
    Aa = 1*(A - muA*ones(n,1)') + muB*ones(n,1)';
    Aa = floor(Aa');
    %return Aa
end

