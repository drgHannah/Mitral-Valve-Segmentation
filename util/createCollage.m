function createCollage(vid,frames)
scale = 1;
[w,h,~] = size(vid);
numRecsAcross = ceil(sqrt(numel(frames)));
if numel(frames) <= 4
    numRecsAcross = numel(frames);
end
numRecsDown = ceil(numel(frames) / numRecsAcross);
figure('Name',['Collage, frames: ',num2str(frames)],'Position', [10 10 h*numRecsAcross*scale w*numRecsDown*scale]);


s = 1;
for i = 1: numRecsDown
    for j = 1: numRecsAcross
        
        if ndims(vid) == 4 
            rgbImage = vid(:,:,:,frames(s));
        else   
            rgbImage = vid(:,:,frames(s));
        end
        subplot('Position',[(j-1)*1/numRecsAcross (numRecsDown-i)*1/numRecsDown 1/numRecsAcross 1/numRecsDown]);
        imshow(rgbImage);
        s = s+1;
        if s > numel(frames)
            break;
        end
    end
end

end