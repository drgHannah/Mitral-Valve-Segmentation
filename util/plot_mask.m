function vidSave = plot_mask(vidSave, mask, frames, color)
    BW2 = bwperim(mask,8);
    bound = imdilate(BW2, strel('disk',1));
    if color == "r"
        vidSave = cat(ndims(vidSave)+1, cat(ndims(vidSave)+1, min(1, bound + vidSave),vidSave-bound),vidSave-bound);
    else
        vidSave = cat(ndims(vidSave)+1, cat(ndims(vidSave)+1, vidSave-bound, min(1, bound + vidSave)),vidSave-bound);
    end
    
    
    vidSave = min(max(vidSave,0),1);
    createCollage(permute(vidSave,[1,2,4,3]),frames);