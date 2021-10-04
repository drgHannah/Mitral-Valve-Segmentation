function numberComb = evaluationRnmf(fun, params, paramsNames, maxNumberVideos, evaluationMethod, masksize)

% Display
functionInfo = functions(fun);
nameFunction = functionInfo.function;
disp(['Evaluate ',nameFunction,'.'])


% Create all combinations of paramters
comb = {};
comb.names = paramsNames;
comb.params = createParameterCombinations(params);


% Optional: load saves status
status = loadStatus(functionInfo,evaluationMethod);

% Check if parameter combinations in loaded status are equal to the selected ones
if isstruct(status)
    if sum(status.combParams(:) ~= comb.params(:)) > 0
        warning('on');
        warning('Parameter Combinations in loaded Status are different to the current ones. Changed to the old ones.');
        warning off MATLAB:subscripting:noSubscriptsSpecified;
        warning('off','all');
        comb.values = status.combParams;
    end
end


% Create result folders and delete the old results
 dirResults = ['./results/',num2str(functionInfo.function),'/method_',evaluationMethod];
% if exist(dirResults,'dir') ~= 0 && ~isstruct(status)
%     deleteFolder(dirResults);
%     pause(0.5);
%     if exist(dirResults,'dir')
%         error('Issues deleting the old folder.');
%     end
% end
 mkdir(dirResults);


% Set Path
datadir = './data/original/';
gtdir = './data/ground_truth_window/';


% Get Videos
files = dir(datadir);
videoNames = {files(~[files.isdir]).name};
nrVideos = min(numel(videoNames),maxNumberVideos);

% Number Combinations
numberComb = nrVideos *size(comb.params,2);

% Struct: precision recall accuracy - for all videos
precisionVideo = {};
recallVideo = {};
accuracyVideo = {};

% For every video
for vid = 1:nrVideos 
    
    % Precision, recall, accuracy, id - for each individual video
    percentagePrecision = zeros(1,size(comb.params,2));
    percentageRecall = zeros(1,size(comb.params,2));
    percentageAccuracy = zeros(1,size(comb.params,2));
    ids = zeros(1,size(comb.params,2));
    
    % Optional: load saved status
    if isstruct(status)
        if status.imgNr >  vid
            continue;
        end
        if status.imgNr ==  vid
            evaluationMethod = status.evaluationMethod;
            precisionVideo = status.precisionVideo;
            recallVideo = status.recallVideo;
            accuracyVideo = status.accuracyVideo;
            masksize = status.maskSize;
            ids = status.ids;
        end
    end
    
    % Display
    disp(['Run on ',videoNames{vid},' - ',num2str(vid),' of ',num2str(nrVideos)]);
    
    % Load video
    X = loadVideo([datadir,videoNames{vid}], 0);
    
    % Check ground truth
    splitname = strsplit(videoNames{vid},'.');
    gtVidDir = [gtdir,'gt_',num2str(splitname{1}),'.mat'];
    groundTruthExists = exist(gtVidDir,'file');
    
    
    if(groundTruthExists)
        
        % Load mask of ground truth
        load(gtVidDir,'mask');
        groundTruthMask = mask;
        
        % Adapt masksize
        load(gtVidDir,'coordinates');
        if ~isnumeric(masksize)
            vidMasksize = [coordinates(3), coordinates(4)];
            vidMasksize = round(vidMasksize);
        else
            vidMasksize = masksize;
        end
        
        
        for param = 1:size(comb.params,2)
            
            % Status
            if isstruct(status)
                if status.imgNr ==  vid
                    if status.combNr >  param
                        continue;
                    end
                    if status.combNr ==  param
                        percentagePrecision = status.percentagePrecision;
                        percentageAccuracy = status.percentageAccuracy;
                        percentageRecall = status.percentageRecall;
                        continue;
                    end
                    
                end
            end
            
            
            % Display
            tic;
            fprintf(['..... Parameter Combination ', num2str(param),' of ',num2str(size(comb.params,2)),' ']);
            
            % ID
            id = (vid-1) * size(comb.params,2) + param;
            
            
            switch evaluationMethod
                
                case 'movingWindow'
                    
                    % Run Function
                    result = {};
                    result.M = movingWindow(X, vidMasksize, [20, 20] , fun, comb.params(:,param)');
                    
                    % Save
                    saveResultsMat(result,functionInfo.function,evaluationMethod,id);
                    
                case 'wholeVideo'
                    
                    % Run Function
                    result = fun(X,comb.params(:,param)');

                    % Get Mask
                    result.M = movingWindow(result.S, vidMasksize, [20, 20], -1, -1);

                    % Save
                    saveResultsMat(result,functionInfo.function,evaluationMethod,id);
                    
                otherwise % Otherwise
                    error('Variable method has an invalid value.');
            end
            close all;
            
            
            % Get Precision and Time
            %[prec,recall,accuracy] = compareMasks(groundTruthMask, result.M);
            [prec,recall,accuracy] = compareMasksOriginal(result.M, splitname{1});
            percentagePrecision(param) = prec;
            percentageRecall(param) = recall;
            percentageAccuracy(param) = accuracy;
            time = toc;
            
            
            % Display Precision and Time
            fprintf(['-> Precision: ', num2str(prec),' (in ',num2str(round(time)),' sec.\n']);
            
            
            % Write IDs
            ids(param) = id;
            
            
            % Save Status
            saveStatus(fun, vid, param, precisionVideo, percentagePrecision, recallVideo, percentageRecall, accuracyVideo, percentageAccuracy,evaluationMethod,masksize,ids,comb.params);
            
            
        end
        
        % Save Precision Values for each Video
        precisionVideo{vid}.values = percentagePrecision;
        precisionVideo{vid}.name = splitname{1};
        precisionVideo{vid}.id = ids;
        
        recallVideo{vid}.values = percentageRecall;
        accuracyVideo{vid}.values = percentageAccuracy;
        
        % Save Interim Results
        saveResults(accuracyVideo,recallVideo,precisionVideo, comb, functionInfo.function, evaluationMethod);
        
    else
        disp('Ground Truth does not exist for this video.');
        precisionVideo{vid}.id =      ones([1,size(comb.params,2)]) * -1;
        precisionVideo{vid}.values =  ones([1,size(comb.params,2)]) * -1;
        precisionVideo{vid}.name =    num2str(splitname{1});
        
        recallVideo{vid}.values = ones([1,size(comb.params,2)]) * -1;
        accuracyVideo{vid}.values = ones([1,size(comb.params,2)]) * -1;
    end
    
end

% Save Results
saveResults(accuracyVideo,recallVideo,precisionVideo, comb, functionInfo.function, evaluationMethod);

end





%% Create all parameter combinations

function comb = createParameterCombinations(params)
nrVar = numel(params);
comb = params{1};
for i = 2:nrVar
    comb = combvec(comb,params{i});
end
end



%% Delete Folder

function deleteFolder(pathFolder)

% Get Subfolder
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

% Delete Entries
for k = 1:length(d)
    delete([ pathFolder ,'/', d(k).name])
end

% Delete All Subfolder
for i = 1:size(nameFolds)
    deleteFolder([pathFolder,'/',nameFolds{i}]);
end

% Delete Old Folders
rmdir(pathFolder)
end

%% Save Returned Values as mat

function saveResultsMat(res,functionName,method,id)
    path = ['./results/',num2str(functionName),'/method_',method,'/'];
    filename = [num2str(id),'_',num2str(functionName),'.mat'];
    save([path,filename],'res');
end

%% Load and save current status
function status = loadStatus(functionInfo,evaluationMethod)

% Get name of function
name =  functionInfo.function;
status = -1;

% File with saved status information
filename = ['./data/tmp/',name,'_method',num2str(evaluationMethod),'_status.mat'];

% Check if saved status exists
if exist(filename, 'file') ~= 2
    return;
end

% Load saved status
question = 'Do you want to load your saved status?';
answerManual = questdlg_timer(10,question,'Continue in 10 seconds ...','Y','N','N');
if strcmp(answerManual,'Y')
    
    % Load data
    load(filename,'status');
    
    % Plot data
    fprintf(['\nLoaded Status with the following values:',...
        '\n Evaluation method: ',num2str(status.evaluationMethod),...
        '\n Moving window mask size: ', num2str(status.maskSize), ...
        '\n Already evaluated video: ', num2str(status.imgNr - 1), ...
        '\n Already evaluated combinations in actual video: ', num2str(status.combNr), ...
        '\n Actual ID: ', num2str(max(status.ids)), ...
        '\n \n']);
else
    delete(filename);
end

end



% Save Status
function saveStatus(fun, imgNr, combNr, precisionVideo, percentagePrecision,...
    recallVideo, percentageRecall, accuracyVideo, percentageAccuracy,...
    evaluationMethod,maskSize,ids, combParams)

functionInfo = functions(fun);
name =  functionInfo.function;

status = {};
status.ids = ids;
status.evaluationMethod = evaluationMethod;
status.maskSize = maskSize;
status.imgNr = imgNr;
status.combNr = combNr;

status.recallVideo = recallVideo;
status.percentageRecall = percentageRecall;

status.precisionVideo = precisionVideo;
status.percentagePrecision = percentagePrecision;

status.accuracyVideo = accuracyVideo;
status.percentageAccuracy = percentageAccuracy;

status.combParams = combParams;
save(['./data/tmp/',name,'_method',num2str(status.evaluationMethod),'_status.mat']','status');
end


%% function compare Masks

function [precision,recall,accuracy] = compareMasks(maskGT, maskIn)
        % For mask 3D or 2D
        % Calculate Mask
        maskCalc = false(size(maskGT));
        maskCalc(maskIn(1) : maskIn(1) + maskIn(3), maskIn(2) : maskIn(2) + maskIn(4), :) = true;

        if ismatrix(maskGT)
            maskGT = repmat(maskGT,[1 1 size(maskCalc,3)]);
        end
        
        TruePositive = numel(find(maskGT==1 & maskCalc==1));
        TrueNegatives = numel(find(maskGT==0 & maskCalc==0));
        FalseNegatives = numel(find(maskGT==1 & maskCalc==0));
        FalsePositives = numel(find(maskGT==0 & maskCalc==1));
        
        recall = TruePositive / (TruePositive + FalseNegatives);
        precision =  TruePositive / (TruePositive + FalsePositives);
        accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);
 
end

%%% Try
function [precision,recall,accuracy] = compareMasksOriginal(maskIn, splitname)
        % For mask 3D or 2D
        % Calculate Mask
        path_other_mask = ['./data/ground_truth/','gt_',num2str(splitname),'.mat'];
        maskGT = load(path_other_mask,'mask');%.mask;
        maskGT = maskGT.mask;
        
        maskCalc = false(size(maskGT));
        maskCalc(maskIn(1) : maskIn(1) + maskIn(3), maskIn(2) : maskIn(2) + maskIn(4), :) = true;
        
        TruePositive = numel(find(maskGT==1 & maskCalc==1));
        TrueNegatives = numel(find(maskGT==0 & maskCalc==0));
        FalseNegatives = numel(find(maskGT==1 & maskCalc==0));
        FalsePositives = numel(find(maskGT==0 & maskCalc==1));
        
        recall = TruePositive / (TruePositive + FalseNegatives);
        precision =  TruePositive / (TruePositive + FalsePositives);
        accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);
 
        
end

%% Save Results of one Algorithm in Table: Recall Precision and Accuracy
function saveResults(accuracyEachVideo, recallEachVideo, precisionEachVideo, parameterValuesNames, nameTable,method)

    % For each Video
    for vid = 1:size(precisionEachVideo,2)
        
        
        % Multiple Time Video Name
        VideoName = cellstr(repmat( precisionEachVideo{vid}.name,size(parameterValuesNames.params,2),1)); % Just First
        
        % Precision
        Precision = precisionEachVideo{vid}.values';
        Recall =    recallEachVideo{vid}.values';
        Accuracy =  accuracyEachVideo{vid}.values';
        
        % ID
        ID = precisionEachVideo{vid}.id';
        
        % Variable for Parameter Values
        paramsValues = parameterValuesNames.params;
        
        % Vector for all names of parameters
        nameCols = [];

        % Go through parameters
        for i = 1:size(parameterValuesNames.names,2)
            nameString = parameterValuesNames.names{i};
            paramValues = num2str(paramsValues(i,:));
            
            % Add Values to Parameter Name
            str = [nameString '= ['  paramValues ']strich;'];
            str = strrep(str,'strich',"'");
            eval(str);
            
            % Add Name to Name List
            eval(['nameCols = [nameCols,' nameString '];']);
        end

        % Create Table
        stringVal = ['TNew=table(ID,VideoName,' strjoin(parameterValuesNames.names) ',Precision,Recall,Accuracy);' ];
        stringVal = strrep(stringVal,' ',',');
        eval(stringVal);
        
        % Concat Tables
        if vid == 1 
            T = TNew;
        else
            T = vertcat(T,TNew);
        end
        
    end
    
    % Delete entries without result
    toDelete = T.Precision < 0;
    T(toDelete,:) = [];
   
    
    % Save Results
    dir = ['./results/',nameTable,'/method_',method,'/'];
    writetable(T,[dir, nameTable,'_method_',method,'.xls']);
    
    
    
    disp('Finished.');
end

