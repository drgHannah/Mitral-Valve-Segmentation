%% Settings RNMF %%



function segment(name, onMethod, ids, varargin)

    % Global Parameter
    postProcessing = 'both'; % can become: both, true, false
    cropped = true;          % can become: true or false
    globalParams = readArgs({postProcessing,cropped}, varargin, {'postProcessing','cropped'});
    

    switch name
        
         case 'segmentCVPlus'
            % Default Parameters
            defaultParams = {};
            defaultParams{1} = [0];                                % Plot?
            defaultParams{2} = [50];                               % Number of Iterations
            defaultParams{3} = [0.5];                              % Parameter: Thresholding S
            defaultParams{4} = [0.04];                             % Add TV in Spacial Direction: TVxy(M)
            defaultParams{5} = [0];                                % Add TV in Temporal Direction: TVz(M)
            defaultParams{6} = [1];                                % Parameter: Thresholding W*H
            defaultParams{7} = [0.075];                            % Parameter: Area Constraint
            defaultParams{8} = [0.01];                             % t

            % Create all Combinations of paramters
            paramsNames = {'plot','iterations','threshS','TVxyM','TVzM','threshWH','area','thresh'};
            
            % Read Args
            params = readArgs(defaultParams, varargin, paramsNames);

            % Run Evaluation for all Parameters
            evaluationSegment(@segmentCVPlus, params, paramsNames,onMethod, ids, globalParams{1},globalParams{2});
          
        otherwise
            disp('Method not availiable.');
    end
end


