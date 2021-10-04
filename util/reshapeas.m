function A = reshapeas(A,B)
% 1D - 3D
A = reshape(A, size(B,1), size(B,2), size(B,3));
end