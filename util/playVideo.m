function playVideo(video)
fig = figure('Name','Play Video');
if ndims(video) == 3
    for frameNr = 1:size(video,3)
        imshow(video(:,:,frameNr));
        drawnow;
    end
else
    for frameNr = 1:size(video,4)
        imshow(video(:,:,:,frameNr));
        drawnow;
    end    
end
close(fig);