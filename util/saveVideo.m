function saveVideo(name, video)
% name -> save as 'name'
% video = input
v = VideoWriter(name);
open(v);

    
if ndims(video) == 3
    for frameNr = 1:size(video,3)
        writeVideo(v,video(:,:,frameNr));
    end
else
    for frameNr = 1:size(video,4)
        writeVideo(v,video(:,:,:,frameNr));
    end    
end

close(v);