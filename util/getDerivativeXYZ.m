function [D, D1, D2, D3] = getDerivativeXYZ(n,m,z) 
% n = dim(x), m = dim(y), z = dim(z)

D1 = speye(n);
D1 = D1 + sparse(1:n,max(1,0:n-1),-1,n,n);
D1 = kron(speye(m),D1);

D2 = speye(m);
D2 = D2 + sparse(max(1,0:m-1),1:m,-1,m,m);
D2 = kron(D2',speye(n));

D3 = speye(z);
D3 = D3 + sparse(max(1,0:z-1),1:z,-1,z,z);
D3 = kron(D3',speye(n * m));

D1 = kron(speye(z),D1);
D2 = kron(speye(z),D2);

D = [D1 ; D2; D3];
end

