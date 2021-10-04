function vidMask = movingWindow(videoMatrix2DI, windowSizeI, stepSize, input, params)


%% Move Window

videoMatrix2D = videoMatrix2DI;
windowSize = windowSizeI;

Wwidth = size(videoMatrix2D,2);
wwidth = windowSize(1)-1;
stepsz_x = stepSize(1);

Wheight = size(videoMatrix2D,1);
wheight = windowSize(2)-1;
stepsz_y = stepSize(2);

x_numstep = floor((Wwidth - wwidth - 1) / stepsz_x) + 1;
y_numstep = floor((Wheight - wheight - 1) / stepsz_y) + 1;

frameNr = size(videoMatrix2D, 3);
nrSteps = (x_numstep * y_numstep) ;
normS = zeros([nrSteps , 1]);


parfor step = 1 : nrSteps   
warning('off','all') 

    % Calculate Mask    
    mask = false(size(videoMatrix2D(:,:,1)));
    pos_x = mod(step - 1, x_numstep)  * stepsz_x + 1;
    pos_y = floor((step - 1) / x_numstep) * stepsz_y + 1;    
    mask(pos_y : pos_y + wheight, pos_x : pos_x + wwidth) = true;
    
    
    % Mask Image 
    masked = reshape(videoMatrix2D(repmat(mask,1,1,frameNr)),[windowSize(2) windowSize(1) frameNr]);
    
    % NMF and Norm of S
    if nnz(masked) > 2
        
        
        if isa(input, 'function_handle')     
            % Run Function
            res = input(masked,params);
            S = res.S;
            
        else
            S = masked;
        end
        S = reshape(S,[windowSize(1)*windowSize(2) frameNr]);
       
        normStep = norm(S,'fro');
        normStep(find(isnan(normStep))) = 0; 
        normS(step,:) = normStep;
    end
    
    % Plot Close
    close all;
    
end

% Find Maximum norm of S per Frame
[~,maxIdx] = max(normS);

% Calculate mask coordinates
posX = mod(maxIdx - 1, x_numstep)  * stepsz_x + 1;
posY = floor((maxIdx - 1) / x_numstep) * stepsz_y + 1;


vidMask = [posY, posX, wheight, wwidth];




end


