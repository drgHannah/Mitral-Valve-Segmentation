%% Create Ground Truth
clc;
clear;
close all;
addpath(genpath('..'));

opts.Interpreter = 'none';
opts.Default = 'Manually';
question = 'How do you want to load your video(s) ?';
answerManual = questdlg(question,'Please Select.','Manually','All Automatic','Only Without Ground Truth',opts);

datadir = '../data/original/';
savedir = '../data/ground_truth_window/';
savediradapt = '../data/ground_truth/';

%% Load All Videos without GT from Folder



if strcmp(answerManual,'Only Without Ground Truth')

    % Get Videonames
    files = dir(datadir);
    videoNames = {files(~[files.isdir]).name};
    nrVideos = size(videoNames,2);

    opts.Interpreter = 'none';
    opts.Default = 'No';
    for i = 1:nrVideos

        % Get Name of Video
        name = videoNames{i};

        % Check if GT already exists
        splitname = strsplit(name,'.');
        exists1 = min(max(exist([savedir,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
        exists2 = min(max(exist([savediradapt,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
        exists = exists1 && exists2;
        whichExists = ['Windowed: ', num2str(exists1), ', Adapted: ', num2str(exists2)];
        
        if (~exists)
            % Ask if calculating GT
            question = ['Do you want to create a Ground Truth for ',num2str(splitname{1}),'? (',whichExists,')'];
            answer = questdlg(question,'Please Select.','Yes, a window.','Yes, an adapted shape.','No',opts);
        else
            answer = 'No';
        end

        % Cancel
        if strcmp(answer,'')
            break;
        end


        % Create GT
        if strcmp(answer,'Yes, a window.')
            CreateGT(name,datadir,savedir);
        end 
        if strcmp(answer,'Yes, an adapted shape.')
            CreateGTExact(name,datadir,savediradapt);
        end
    end

end



%% Load All Videos from Folder

if strcmp(answerManual,'All Automatic')

    % Get Videonames
    files = dir(datadir);
    videoNames = {files(~[files.isdir]).name};
    nrVideos = size(videoNames,2);

    opts.Interpreter = 'none';
    opts.Default = 'No';
    for i = 1:nrVideos

        % Get Name of Video
        name = videoNames{i};

        % Check if GT already exists
        splitname = strsplit(name,'.');
        exists1 = min(max(exist([savedir,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
        exists2 = min(max(exist([savediradapt,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
        exists = exists1 && exists2;
        whichExists = ['Windowed: ', num2str(exists1), ', Adapted: ', num2str(exists2)];

        % Ask if calculating GT
        if exists == 1
            question = ['Ground Truth of ',num2str(splitname{1}),' already exists: ',whichExists,'. Do you want to create a new Ground Truth?'];
            answer = questdlg(question,'Please Select.','Yes','No',opts);
        else
            question = ['Do you want to create a Ground Truth for ',num2str(splitname{1}),'?'];
            answer = questdlg(question,'Please Select.','Yes, a window.','Yes, an adapted shape.','No',opts);
        end

        % Cancel
        if strcmp(answer,'')
            break;
        end

        % Create GT
        if strcmp(answer,'Yes, a window.')
            CreateGT(name,datadir,savedir);
        end 
        if strcmp(answer,'Yes, an adapted shape.')
            CreateGTExact(name,datadir,savediradapt);
        end
    end

end


%% Manually

if strcmp(answerManual,'Manually')
    
    % For Question
    opts.Interpreter = 'none';
    opts.Default = 'No';
    
    % Set Path and get Videoname
    [name,~] = uigetfile([datadir,'*.*']);
    if name == 0
        return;
    end

    
    % Check if GT already exists
    splitname = strsplit(name,'.');
    exists1 = min(max(exist([savedir,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
    exists2 = min(max(exist([savediradapt,'gt_',num2str(splitname{1}),'.mat'],'file'),0),1);
    exists = exists1 && exists2;
    whichExists = ['Windowed: ', num2str(exists1), ', Adapted: ', num2str(exists2)];
    
    question = ['Do you want to create a Ground Truth?'];
    if exists == 1
        question = ['Ground Truth of ',num2str(splitname{1}),' already exists: ',whichExists,'. Do you want to create a new Ground Truth?'];    
    end
    answer = questdlg(question,'Please Select.','Yes, a window.','Yes, an adapted shape.','No',opts);
    
    % Create GT
    if strcmp(answer,'Yes, a window.')
    	CreateGT(name,datadir,savedir);
    end 
    if strcmp(answer,'Yes, an adapted shape.')
        CreateGTExact(name,datadir,savediradapt);
    end
    
        
    
end


%% Create Ground Truth

function CreateGT(name,file,destfile)

    opts.Interpreter = 'none';
    opts.Default = 'No';
    BW = 0;

    % Set Name
    splitname = strsplit(name,'.');


    % Load Video and Set Answer to 'Yes'
    video = VideoReader([num2str(file), num2str(name)]);
    answer = 'Yes';

    % Play Video
    while (hasFrame(video))
        frame = readFrame(video);
        imshow(frame)  
    end

    % Create GT
    while strcmp(answer,'Yes')

        % Create Mask
        H = imrect();
        if isempty(H)
            close all;
            return;
        end
        pos = getPosition(H);
        BW = createMask(H);

        % Load Video Again
        video = VideoReader([num2str(file), num2str(name)]);

        % Show Mask on Video
        while (hasFrame(video))
            frame = readFrame(video);
            frame = im2double(rgb2gray(frame));
            imshow(0.7 * (BW.*frame) + 0.3 * frame) ;
            drawnow;
        end

        % Ask if Selected GT Okay
        answer = questdlg('Repeat Selecting Window?','Please Select.','Yes','No','Cancel',opts);
        if strcmp(answer,'Cancel')
            break;
        end


    end
    
    % Save
    if strcmp(answer,'Cancel') == 0 && strcmp(answer,'') == 0
        
        
        % Save Coordinates
        coordinates = pos;
        mask = BW;
        save([num2str(destfile),'gt_',num2str(splitname{1})],'coordinates','mask');
        disp(['Saved gt_',num2str(splitname{1}),'.']);
    end
    
    
    close all;
    
end




function CreateGTExact(name,file,destfile)
    opts.Interpreter = 'none';
    opts.Default = 'No';
    BW = [];
    frames = [];

    % Set Name
    splitname = strsplit(name,'.');


    % Load Video and Set Answer to 'Yes'
    video = VideoReader([num2str(file), num2str(name)]);
    answer = 'Yes';

    % Play Video
    while (hasFrame(video))
        frame = readFrame(video);
        imshow(frame);
        frames = cat(4,frames, frame);
    end

    % Create GT
    while strcmp(answer,'Yes')
        close all;
        
        for actF = 1:size(frames,4)
        % Create Mask
            
            imshow(frames(:,:,:,actF));
            title([num2str(actF),' of ', num2str(size(frames,4))]);
            set(gcf, 'Position', get(0, 'Screensize'));
            
            H1 = impoly(gca);
            if isempty(H1)
                close all;
                return;
            end
            H2 = impoly(gca);
            if isempty(H2)
                close all;
                return;
            end

            BW1 = createMask(H1);
            BW2 = createMask(H2);

            BW = cat(3,BW, BW1 | BW2);

        end
        close all;
        
        framesG = [];
        for frameNr = 1:size(frames,4)
            framesG = cat(3,framesG, im2double(rgb2gray(frames(:,:,:,frameNr))));
        end


        maskedFrames = double(BW) .* framesG;
        playVideo( 0.7 * maskedFrames + 0.3 * framesG);

        % Ask if Selected GT Okay
        answer = questdlg('Repeat Selecting Window?','Please Select.','Yes','No','Cancel',opts);
        if strcmp(answer,'Cancel')
            break;
        end


    end
    
    % Save
    if strcmp(answer,'Cancel') == 0 && strcmp(answer,'') == 0
        % Save Coordinates
        mask = BW;
        save([num2str(destfile),'gt_',num2str(splitname{1})],'mask');
        disp(['Saved Exact gt_',num2str(splitname{1}),'.']);
    end
    
    
    close all;
end