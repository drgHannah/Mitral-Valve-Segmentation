%% Settings RNMF %%



function ids = rnmf(name, nrVideos, varargin)

    
    % Global Parameter
    masksize =      'Adapt';
    method   = 'wholeVideo'; % movingWindow vs wholeVideo
    globalParams = readArgs({masksize,method}, varargin, {'masksize','method'});
    

    switch name
        
        case 'robustNMF'
            % Default Parameters
            defaultParams = {};
            defaultParams{1} = [0];                             % Plot
            defaultParams{2} = [2];                            	% Parameter: Rank
            defaultParams{3} = [100];                           % Number of Iterations
            defaultParams{4} = [0.1];                           % Parameter: Sparsity of S

            % Create all Combinations of paramters
            paramsNames = {'plot','rank','iterations','sparsity'};
            
            % Read Args
            params = readArgs(defaultParams, varargin, paramsNames);

            % Run Evaluation for all Parameters
            numberComb = evaluationRnmf(@robustNMF, params, paramsNames, nrVideos, globalParams{2}, globalParams{1});
            ids = 1:numberComb;
            
        case 'robustBreg'
            % Default Parameters
            defaultParams = {};
            defaultParams{1} = [0];                             % Plot
            defaultParams{2} = [2];                            	% Parameter: Rank
            defaultParams{3} = [100];                           % Number of Iterations
            defaultParams{4} = [0.1];                           % Parameter: Sparsity of S

            % Create all Combinations of paramters
            paramsNames = {'plot','rank','iterations','sparsity'};
            
            % Read Args
            params = readArgs(defaultParams, varargin, paramsNames);

            % Run Evaluation for all Parameters
            numberComb = evaluationRnmf(@robustNMF_Breg, params, paramsNames, nrVideos, globalParams{2}, globalParams{1});
            ids = 1:numberComb;
            

        case 'robustNMF_excludeWHS'
            
            % Default Parameters
            defaultParams = {};
            defaultParams{1} = [0];              % Plot
            defaultParams{2} = [6];              % Parameter: Rank
            defaultParams{3} = [160];            % Number of Iterations
            defaultParams{4} = [0.05];           % Parameter: Sparsity of S
            defaultParams{5} = [0.5];            % Parameter: Excluding WHS

            % Create all Combinations of paramters
            paramsNames = {'plot','rank','iterations','sparsity','excluding'};
            
            % Read Args
            params = readArgs(defaultParams, varargin, paramsNames);

            % Run Evaluation for all Parameters
            numberComb = evaluationRnmf(@robustNMF_excludeWHS, params, paramsNames, nrVideos, globalParams{2}, globalParams{1});
            ids = 1:numberComb;
            
        case 'robustNMF_excludeWHS_Breg'
            
            % Default Parameters
            defaultParams = {};
            defaultParams{1} = [0];               % Plot
            defaultParams{2} = [5];               % Parameter: Rank
            defaultParams{3} = [160];             % Number of Iterations
            defaultParams{4} = [1];               % Parameter: Sparsity of S
            defaultParams{5} = [0.4];             % Parameter: Excluding WHS
            
            % Create all Combinations of paramters
            paramsNames = {'plot','rank','iterations','sparsity','excluding'};
            
            % Read Args
            params = readArgs(defaultParams, varargin, paramsNames);

            % Run Evaluation for all Parameters
            numberComb = evaluationRnmf(@robustNMF_excludeWHS_Breg, params, paramsNames, nrVideos, globalParams{2}, globalParams{1});
            ids = 1:numberComb;            
    end
end


