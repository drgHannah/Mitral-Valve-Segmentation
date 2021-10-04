function videoMatrix = loadVideo(path,color)
% Path: Path of the Video
% Color: 1 if load as color image, 0 else

if strcmp(path,'UI') == 1
	[FileName,PathName]  = uigetfile('*.*');
    if FileName == 0
        return;
    end
    path = [PathName,FileName];
end

    video = VideoReader(path);
    
    videoMatrix = [];
    if ~color
        while (hasFrame(video))
            frame = readFrame(video);
            frame2D = im2double(rgb2gray(frame));
            videoMatrix = cat(3,videoMatrix,frame2D);
        end
    else   
        while (hasFrame(video))
            frame = readFrame(video);
            frame2D = im2double((frame));
            videoMatrix = cat(4,videoMatrix,frame2D);
        end
    end
end