function fig = create3DPlot(segmentation,background)

% perm = [2,3,1];
perm = [1,2,3];
if ~isempty(background)
    % Background
    background = cat(3,zeros(size(background,1),size(background,2)),cat(3,background,zeros(size(background,1),size(background,2))));
    D= permute(background,perm);
    D = double(squeeze(D));
    D(D==0)=nan;

    D = D * 4;
%     h = slice(D, [], [], 1:size(D,3));
    h = slice(D, 1:size(D,1), 1:size(D,2), 1:size(D,3));
%     set(h, 'EdgeColor','none', 'FaceColor','interp','FaceAlpha','interp');
    set(h, 'EdgeColor','none', 'FaceColor',[0.10588,0.30588,0.51372],'FaceAlpha','interp');
    alpha color;
    alpha direct;
    hold on;
end
if ~isempty(segmentation)
    % Segmentation
    vidSave = cat(3,zeros(size(segmentation,1),size(segmentation,2)),cat(3,segmentation,zeros(size(segmentation,1),size(segmentation,2))));
    D= permute(vidSave,perm);
    D = double(squeeze(D));
     
    
    data = smooth3(D,'box',1);
    p = patch(isosurface(data));
    %set(p,'FaceColor',[0.99607,0.909803,0],'EdgeColor','none');
    c = isocolors(squeeze(L_col(:,:,1,:))/255,squeeze(L_col(:,:,2,:))/255,squeeze(L_col(:,:,3,:))/255,p);
    p.FaceVertexCData = c;
    p.FaceColor = 'interp';
    p.EdgeColor = 'none';
    %set(p,'FaceColor',c,'EdgeColor','none');
    xlabel('x')
    ylabel('y')
    zlabel('frames')

%     daspect([1 0.3 1])
    az = 0;
    el = 0;
    view(3); axis tight
    camlight('headlight')
    lighting gouraud


end

fig = gcf;


