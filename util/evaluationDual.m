function evaluationDual(fun, params, paramsNames, maxNumberVideos)

% Display
functionInfo = functions(fun);
nameFunction = functionInfo.function;
disp(['Evaluate ',nameFunction,'.'])


% Create all combinations of paramters
comb = {};
comb.names = paramsNames;
comb.params = createParameterCombinations(params);


% Optional: load saves status
status = loadStatus(functionInfo);

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
dirResults = ['./results/',num2str(functionInfo.function)];
if exist(dirResults,'dir') ~= 0 && ~isstruct(status)
    deleteFolder(dirResults);
end
mkdir(dirResults);


% Set Path
datadir = './data/original/';
gtdir = './data/ground_truth/';


% Get Videos
files = dir(datadir);
videoNames = {files(~[files.isdir]).name};
nrVideos = min(numel(videoNames),maxNumberVideos);


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
            precisionVideo = status.precisionVideo;
            recallVideo = status.recallVideo;
            accuracyVideo = status.accuracyVideo;
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
            
            
            
            % Run Function
            result = fun(X,comb.params(:,param)');
            

            % Save
            saveResultsMat(result,functionInfo.function,id);
                    
              
            close all;
            
            
            % Get Precision and Time
            [prec,recall,accuracy] = compareMasks(groundTruthMask, result.M);
            percentagePrecision(param) = prec;
            percentageRecall(param) = recall;
            percentageAccuracy(param) = accuracy;
            time = toc;
            
            
            % Display Precision and Time
            remainingTimeT = time * (size(comb.params,2) - param) + (nrVideos - vid + 1) * size(comb.params,2) * time;
            remainingTime = round(remainingTimeT / 3600 * 100) / 100;
            
            if (remainingTime < 1)
                remainingTime = round(remainingTimeT / 60 * 100) / 100;
                fprintf(['-> Precision: ', num2str(prec),' (in ',num2str(round(time)),' sec., remaining time ca. ',num2str(remainingTime),' min.) \n']);
            else
                fprintf(['-> Precision: ', num2str(prec),' (in ',num2str(round(time)),' sec., remaining time ca. ',num2str(remainingTime),' hours) \n']);
            end
            
            
            % Write IDs
            ids(param) = id;
            
            
            % Save Status
            saveStatus(fun, vid, param, precisionVideo, percentagePrecision, recallVideo, percentageRecall, accuracyVideo, percentageAccuracy,ids,comb.params);
            
            
        end
        
        % Save Precision Values for each Video
        precisionVideo{vid}.values = percentagePrecision;
        precisionVideo{vid}.name = splitname{1};
        precisionVideo{vid}.id = ids;
        
        recallVideo{vid}.values = percentageRecall;
        accuracyVideo{vid}.values = percentageAccuracy;
        
        % Save Interim Results
        saveResults(accuracyVideo,recallVideo,precisionVideo, comb, functionInfo.function);
        
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
saveResults(accuracyVideo,recallVideo,precisionVideo, comb, functionInfo.function);

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

function saveResultsMat(res,functionName,id)
    path = ['./results/',num2str(functionName),'/'];
    filename = [num2str(id),'_',num2str(functionName),'.mat'];
    save([path,filename],'res');
end

%% Load and save current status
function status = loadStatus(functionInfo)

% Get name of function
name =  functionInfo.function;
status = -1;

% File with saved status information
filename = ['./data/tmp/',name,'_status.mat'];

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
        '\n Already evaluated video: ', num2str(status.imgNr - 1), ...
        '\n Already evaluated combinations in actual video: ', num2str(status.combNr), ...
        '\n Actual ID: ', num2str(max(status.ids)), ...
        '\n \n']);
    
end

end



% Save Status
function saveStatus(fun, imgNr, combNr, precisionVideo, percentagePrecision,...
    recallVideo, percentageRecall, accuracyVideo, percentageAccuracy,...
    ids, combParams)

functionInfo = functions(fun);
name =  functionInfo.function;

status = {};
status.ids = ids;
status.imgNr = imgNr;
status.combNr = combNr;

status.recallVideo = recallVideo;
status.percentageRecall = percentageRecall;

status.precisionVideo = precisionVideo;
status.percentagePrecision = percentagePrecision;

status.accuracyVideo = accuracyVideo;
status.percentageAccuracy = percentageAccuracy;

status.combParams = combParams;
save(['./data/tmp/',name,'_status.mat']','status');
end


%% function compare Masks

function [precision,recall,accuracy] = compareMasks(maskGT, maskCalc)
        % For mask 3D or 2D
        % Calculate Mask
   
        if ismatrix(maskGT)
            maskGT = repmat(maskGT,[1 1 size(maskCalc,3)]);
        end
        maskdiff = maskGT - maskCalc;
        
        TruePositive = numel(find(maskdiff==0 & maskCalc==1));
        TrueNegatives = numel(find(maskdiff==0 & maskCalc==0));
        FalseNegatives = numel(find(maskdiff==1));
        FalsePositives = numel(find(maskdiff==-1));
        
        recall = TruePositive / (TruePositive + FalseNegatives);
        precision =  TruePositive / (TruePositive + FalsePositives);
        accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);
 
    
end

%% Save Results of one Algorithm in Table: Recall Precision and Accuracy
function saveResults(accuracyEachVideo, recallEachVideo, precisionEachVideo, parameterValuesNames, nameTable)

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
        end
        if vid > 1
            T = vertcat(T,TNew);
        end
        
    end
    
    % Delete entries without result
    toDelete = T.Precision < 0;
    T(toDelete,:) = [];
   
    
    % Save Results
    dir = ['./Results/',nameTable,'/'];
    writetable(T,[dir, nameTable,'.xls']);
    
    
    
    disp('Finished.');
end