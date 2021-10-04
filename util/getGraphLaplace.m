function L = getGraphLaplace(simMatrix)

    d_i = sum(simMatrix,2);
    d_i(d_i>0) = 1 ./ sqrt(d_i(d_i>0));
    D = diag(d_i);

    L = speye(size(simMatrix)) - D * simMatrix * D;
    L = (L' + L)/2;
    
end