function evaluationSegmentDiffData(fun, params, paramsNames, onMethod, onMethodIds, postProcessing,croppedInput)

% Display
functionInfo = functions(fun);
nameFunction = functionInfo.function;
disp(['Evaluate ',nameFunction,'.'])


% Create all combinations of paramters
comb = {};
comb.names = paramsNames;
comb.params = createParameterCombinations(params);



% Set Path
gtdir = './data/ground_truth/';
datadir = './newDataset/echo_net';



% Struct: precision recall accuracy - for all videos
precisionVideo = {};
recallVideo = {};
accuracyVideo = {};



% For every res video ------ onMethodIdx
for vid = 1:numel(onMethodIds)
    
    % Postporccesing iteration
    postIt = 1;
    postItStart = 1;
    
    % Get ID of S
    curRnmfIdx = onMethodIds(vid);
    
    % Create result folders and delete the old results
    dirResults = ['./results/',onMethod,'/method_wholeVideo/',num2str(curRnmfIdx),'_',onMethod,'/'];
    if exist(dirResults,'dir') == 0
        mkdir(dirResults);
    end
    
    
    % Check if calculate postprocessing
    if strcmp(postProcessing,'both')
        postIt = 2;
    end
    if strcmp(postProcessing,'true')
        postIt = 2;
        postItStart = 2;
    end
    
    for postproIt = postItStart:postIt
        
        % Current Funtion Name
        funName = functionInfo.function;
        if postproIt == 2
            funName = [functionInfo.function,'Post'];
        end
        if croppedInput == 1
            funName = [functionInfo.function,'Cropped'];
        end
        
        % Precision, recall, accuracy, id - for each individual video
        percentagePrecision = zeros(1,size(comb.params,2));
        percentageRecall = zeros(1,size(comb.params,2));
        percentageAccuracy = zeros(1,size(comb.params,2));
        

        % Ids
        ids = zeros(1,size(comb.params,2));
        
        % Get name of current video
        nameVid = getVideoname(curRnmfIdx, onMethod);
        
        % Display
        disp(['Run on ',nameVid,' - ',num2str(vid),' of ',num2str(numel(onMethodIds))]);
        
        % Load video
        rnmfRes = loadRnmfResult(onMethod,curRnmfIdx);
        X = rnmfRes;
        

        
        % Check ground truth
        gtVidDirs = dir([datadir,'/',nameVid,'/*.png']);
        groundTruthExists = 1;


        
        
        
        if(groundTruthExists)
            
            for param = 1:size(comb.params,2)
                
                
                % Display
                tic;
                fprintf(['..... Parameter Combination ', num2str(param),' of ',num2str(size(comb.params,2)),' ']);
                
                
                % ID
                id = param;
                
                % For Postprcessing: Check if prepost result exists
                [pathN,fileN] = getMatPath(onMethod,functionInfo.function,curRnmfIdx, id);
                
                if exist([pathN,fileN]) && (postproIt == 2)
                    % Load Function Result
                    load([pathN,fileN]);
                    result = {};
                    result.M = res.M;
                elseif (croppedInput == true) & exist([pathN,fileN])
                    % Load Function Result
                    load([pathN,fileN]);
                    result = {};
                    result.M = res.M;
                else
                    % Run Function
                    result = fun(X,comb.params(:,param)');
                end
                
                
                
                if postproIt == 2
                    result.M = postprocessing(result.M,0);
                end
                
                
                % Cropped
                if croppedInput == true
                    background = zeros(size(result.M));
                    background(X.M(1):(X.M(1)+X.M(3)), X.M(2):(X.M(2)+X.M(4)),:) = 1;
                    result.M = uint8(result.M) .* uint8(background);
                end
                
                
                % Save
                saveResultsMat(result,onMethod,funName,curRnmfIdx,id);
                close all;
                
                
                
                % Get Precision and Time
                [prec,recall,accuracy] = compareMasks(gtVidDirs, result.M);
                percentagePrecision(param) = prec;
                percentageRecall(param) = recall;
                percentageAccuracy(param) = accuracy;
                time = toc;
                
                
                % Display Precision and Time
                if strcmp(postProcessing,'both')
                    multPost = 2;
                else
                    multPost = 1;
                end
                remainingTimeT = time * (size(comb.params,2) - param) + (  numel(onMethodIds) - vid + 1) * size(comb.params,2) * time;
                remainingTime = round(remainingTimeT / 3600 * 100) / 100;
                
                if (remainingTime < 1)
                    remainingTime = round(remainingTimeT / 60 * 100) / 100;
                    fprintf(['-> Precision: ', num2str(prec),' (in ',num2str(round(time)),' sec., remaining time ca. ',num2str(remainingTime*multPost),' min.) \n']);
                else
                    fprintf(['-> Precision: ', num2str(prec),' (in ',num2str(round(time)),' sec., remaining time ca. ',num2str(remainingTime*multPost),' hours) \n']);
                end
                
                
                % Write IDs
                ids(param) = id;
                
                
            end
            
            % Save Precision Values for each Video
            precisionVideo.values = percentagePrecision;
            precisionVideo.name = nameVid;
            precisionVideo.id = ids;
            
            recallVideo.values = percentageRecall;
            accuracyVideo.values = percentageAccuracy;
            
            % Save Interim Results
            saveResults(accuracyVideo,recallVideo,precisionVideo, comb,onMethod,funName,  curRnmfIdx);
            
            
        else
            disp('Ground Truth does not exist for this video.');
            precisionVideo.id =      ones([1,size(comb.params,2)]) * -1;
            precisionVideo.values =  ones([1,size(comb.params,2)]) * -1;
            precisionVideo.name =    num2str(nameVid);
            
            recallVideo.values = ones([1,size(comb.params,2)]) * -1;
            accuracyVideo.values = ones([1,size(comb.params,2)]) * -1;
            
            % Save Results
            saveResults(accuracyVideo,recallVideo,precisionVideo, comb,onMethod,funName,  curRnmfIdx);
            
        end
        
    end
    
end
end



%% Get videoname of ID
function nameVid = getVideoname(id, onMethod)

path = ['./results/',onMethod,'/method_wholeVideo/'];
name = [onMethod,'_method_wholeVideo.xls'];
if exist([path,name],'file')
    loadedTable = readtable([path,name]);
else
    error('Could not load Videoname.');
end

% Table Data
tableData = table2cell(loadedTable);

% Get Name
nameVid = tableData{id,2};

end


%% Load Mat file by index and onmethod name

function res = loadRnmfResult(onMethod,onMethodId)
path = ['./results/',onMethod,'/method_wholeVideo/'];
name = [num2str(onMethodId),'_',onMethod,'.mat'];
if exist([path,name],'file')
    load([path,name],'res');
else
    error('You tried to segmentate a nonexisting video.');
end
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

function saveResultsMat(res ,rnmfFunctionName,segmFunctionName,idRNMF, idSegm)
path = ['./results/',num2str(rnmfFunctionName),'/method_wholeVideo/',num2str(idRNMF),'_',num2str(rnmfFunctionName),'/'];
filename = [num2str(idSegm),'_',segmFunctionName,'_',num2str(idRNMF),'_',num2str(rnmfFunctionName),'.mat'];
save([path,filename],'res');
end

% Get Path of Mat
function [path,filename] = getMatPath(rnmfFunctionName,segmFunctionName,idRNMF, idSegm)
path = ['./results/',num2str(rnmfFunctionName),'/method_wholeVideo/',num2str(idRNMF),'_',num2str(rnmfFunctionName),'/'];
filename = [num2str(idSegm),'_',segmFunctionName,'_',num2str(idRNMF),'_',num2str(rnmfFunctionName),'.mat'];
end

%% function compare Masks

function [precision,recall,accuracy] = compareMasks(maskGT, maskPred)
% For mask 3D or 2D
% Calculate Mask
accuracies = 0;
recalls = 0;
precisions = 0;
similarity=0;

for i = 1:size(maskGT,1)

    path_i = [maskGT(i).folder,'/',maskGT(i).name];
    gt = rgb2gray(imread(path_i));
    gt = gt>0;

    rr = regexp(maskGT(i).name,'\d*','Match');
    frame_nr = str2num(rr{1});

    maskCalc = maskPred(:,:,frame_nr);

    maskdiff = double(gt) - double(maskCalc);

    TruePositive = numel(find(maskdiff==0 & maskCalc==1));
    TrueNegatives = numel(find(maskdiff==0 & maskCalc==0));
    FalseNegatives = numel(find(maskdiff==1));
    FalsePositives = numel(find(maskdiff==-1));

    recall = TruePositive / (TruePositive + FalseNegatives);
    precision =  TruePositive / (TruePositive + FalsePositives);
    accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);
    
    accuracies = accuracies+accuracy;
    recalls = recalls+recall;
    precisions = precisions+precision;
    similarity = similarity+jaccard(double(maskCalc), double(gt));
end
accuracy = accuracies/size(maskGT,1);
recall = recalls/size(maskGT,1);
precision = precisions/size(maskGT,1);
similarity = similarity/size(maskGT,1);
end

%% Save Results of one Algorithm in Table: Recall Precision and Accuracy
function saveResults(accuracyEachVideo, recallEachVideo, precisionEachVideo, parameterValuesNames,  rnmfFunctionName,segmFunctionName,idRNMF)


% Multiple Time Video Name
VideoName = cellstr(repmat( precisionEachVideo.name,size(parameterValuesNames.params,2),1)); % Just First

% Precision
Precision = precisionEachVideo.values';
Recall =    recallEachVideo.values';
Accuracy =  accuracyEachVideo.values';

% ID
ID = precisionEachVideo.id';

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
T = TNew;




% Delete entries without result
toDelete = T.Precision < 0;
T(toDelete,:) = [];


% Save Results
path = ['./results/',num2str(rnmfFunctionName),'/method_wholeVideo/',num2str(idRNMF),'_',num2str(rnmfFunctionName),'/'];
filename = [segmFunctionName,'_',num2str(idRNMF),'_',num2str(rnmfFunctionName),'.xls'];
writetable(T,[path,filename]);



disp('Finished.');
end