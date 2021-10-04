function meanDist = MADistance(binaryRes, binaryGT, plot_it)
% Mean Absolute Distance

% Binarize Image
binaryRes = imbinarize(double(binaryRes),0.5);
binaryGT = imbinarize(double(binaryGT),0.5);

% Extract contours from binaryRes and binaryGT
contRes = cell2mat(bwboundaries(binaryRes));
contGT = cell2mat(bwboundaries(binaryGT));

% Calculate Distancies
dist = pdist2(contRes,contGT);
[sz_distA, sz_distB] = size(dist);

% Get minimal distancies --> distance to clostest points
distA = min(dist,[],1);
distB = min(dist,[],2);

% Calculate Mean Distance
meanDistA = sum(distA) / sz_distA;
meanDistB = sum(distB) / sz_distB;

meanDist = 0.5 * (meanDistA + meanDistB);

% Plot
if plot_it == 1
    figure, imshow(binaryRes);
    hold on; 
    plot(contRes(:,2),contRes(:,1),'g','LineWidth',2);
    
    figure, imshow(binaryGT);
    hold on; 
    plot(contGT(:,2),contGT(:,1),'g','LineWidth',2);
end