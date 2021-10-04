function plot_f1_over_time()

base_path = "/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code";
result_path =  strcat("/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code/overview_of_result/older/results-old/robustNMF_mitP/method_wholeVideo/");
gt_path = strcat("/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code/data","/ground_truth/");
original_path = strcat("/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code/data","/original/");
label_path = strcat("/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code/data","/labels/");

datadirs = dir(result_path);


for i = 1:size(datadirs,1)
    if endsWith(datadirs(i).name,'.xls')
        T = readtable(strcat(result_path,datadirs(i).name));
        
    end
end
mean_dia = []
mean_sys = []
for i = 1:size(datadirs,1)
    if datadirs(i).isdir && ~endsWith(datadirs(i).name,".")
        
        spl = split(datadirs(i).name,'_');
        number = spl{1};
        videoname = char(T{str2num(number),2});
        if videoname == "Case10-0008"
            videoname =  "Case0-0008";
        end

        fullpath = strcat(datadirs(i).folder,"/", datadirs(i).name,"/");
        data = dir(fullpath);
        for j = 1:size(data,1)
            if endsWith(data(j).name,".mat") && startsWith(data(j).name,"4") && contains(data(j).name,"Post")
                file = load(strcat(fullpath,data(j).name));
                calc_mask = file.res.M;
                file = load(strcat(gt_path,'/gt_',videoname,'.mat'));
                gt_mask = file.mask;
                [dices,recall_vals,precision_vals] = allCompare(gt_mask, calc_mask);
                orig = loadVideo(strcat(original_path,videoname,".avi"),0);
                playVideo(double(calc_mask.*0.5) + orig .*0.5)
                
                load(strcat(label_path,'/',videoname,'.mat'));
                sys = gTruth.LabelData.Systole;
                dia = gTruth.LabelData.Diastole;
                mean_dia = [mean_dia,mean(dia.*dices)];
                mean_sys = [mean_sys,mean(sys.*dices)];
                
                
                fig = figure('visible','off');
                plot(dia),hold on,plot(dices);
                %plot(dices);%hold on;
                %plot(recall_vals);hold on;
                %plot(precision_vals);
                xlabel('frame')
                ylabel('f1-score')
                %legend('dices','recall_vals','precision_vals');
                saveas(fig,strcat('./fone_time/',videoname,'_',num2str(j),'.png'));
                
                fig = figure('visible','off');
                [val,frame] = max(dices);
                imshow(orig(:,:,frame));
                saveas(fig,strcat('./fone_time/',videoname,'_',num2str(j),'_max_img.png'));
                
                fig = figure('visible','off');
                [val,frame] = min(dices);
                imshow(orig(:,:,frame));
                saveas(fig,strcat('./fone_time/',videoname,'_',num2str(j),'_min_img.png'));
              
            end          
        end
    end
end

disp(mean(mean_dia))
disp(mean(mean_sys))


end

function [dice,recall_vals,precision_vals] = allCompare(gt_mask, calc_mask)
    dice = zeros(size(gt_mask,3),1);
    recall_vals = zeros(size(gt_mask,3),1);
    precision_vals = zeros(size(gt_mask,3),1);
    for k=1:size(dice)
        [precision,recall,acc] = compareMasks(gt_mask(:,:,k), calc_mask(:,:,k));
        yValues = (2 .* recall .* precision) ./ (recall + precision);
        yValues(isnan(yValues))=0;
        dice(k) = yValues;
        recall_vals(k) = recall;
        precision_vals(k) = precision;
    end
end
    

function [precision,recall,accuracy] = compareMasks(maskGT, maskCalc)
% For mask 3D or 2D
% Calculate Mask

maskdiff = maskGT - double(maskCalc);

TruePositive = numel(find(maskdiff==0 & maskCalc==1));
TrueNegatives = numel(find(maskdiff==0 & maskCalc==0));
FalseNegatives = numel(find(maskdiff==1));
FalsePositives = numel(find(maskdiff==-1));

recall = TruePositive / (TruePositive + FalseNegatives);
precision =  TruePositive / (TruePositive + FalsePositives);
accuracy = (TruePositive + TrueNegatives) / (TruePositive + TrueNegatives + FalseNegatives + FalsePositives);


end
