function params = readArgs(default_params, vargs, paramsNames)
 
    params = default_params;
    for param = 1:2:numel(vargs)
        idx = find(contains(paramsNames,vargs{param}));
        if ~isempty(idx)
            params(idx) = vargs(param + 1);
        end
    end