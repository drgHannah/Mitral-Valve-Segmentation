function [precision,recall,accuracy] = compareMasks(maskGT, maskCalc)
% For mask 3D or 2D
% Calculate Mask

if ismatrix(maskGT)
    maskGT = repmat(maskGT,[1 1 size(maskCalc,3)]);
end
maskdiff = maskGT - double(maskCalc);

TruePositive = numel(find(maskdiff==0 & maskCalc==1));
TrueNegatives = numel(find(maskdiff==0 & maskCalc==0));
FalseNegatives = numel(find(maskdiff==1));
FalsePositives = numel(find(maskdiff==-1));

recall = TruePositive / (TruePositive + FalseNegatives);
precision =  TruePositive / (TruePositive + FalsePositives);
accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);


end

