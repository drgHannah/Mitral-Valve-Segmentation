function data = convConj_L2(lambda, data, split)

        p_temp = reshape(data, size(data,1) / split, split);
        p_temp_norm = sqrt(sum(p_temp.^2,2));
        beta = p_temp_norm > lambda;
        
        for j = 1:split
            p_temp(beta, j) = p_temp(beta,j) * lambda ./ p_temp_norm(beta);
        end
        data = p_temp(:);
end
