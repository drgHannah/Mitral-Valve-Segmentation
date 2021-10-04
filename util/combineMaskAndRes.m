function combineMaskAndRes(newname)

base_path = "/media/hannah/Volume/Arbeit/Work/Send/Mitral-Valve/code/results/";
mask_path = strcat(base_path,"robustNMF_excludeWHS_Breg/method_wholeVideo/");
swh_path = strcat(base_path,"/robustNMF/method_wholeVideo/");
final_path = strcat(base_path,newname,"/method_wholeVideo/");
mkdir(final_path)


datadirs = dir(mask_path);
for i = 1:size(datadirs,1)
    disp(datadirs(i).name)
    if endsWith(datadirs(i).name,'.xls')
        copyfile(fullfile(mask_path,datadirs(i).name),  strcat(final_path,newname,'_method_wholeVideo.xls'));
    end
    if endsWith(datadirs(i).name,'.mat')
        spl = split(datadirs(i).name,'_');
        number = spl{1};
        name_swh = dir(strcat(swh_path,'/',num2str(number),'_*.mat'));
        name_swh = name_swh.name;
        swh_file = load(strcat(swh_path,name_swh));
        mask_file = load(strcat(mask_path,datadirs(i).name));
        new_file = swh_file;
        disp([num2str(new_file.res.M),' --> ', num2str(mask_file.res.M)]);
        new_file.res.M = mask_file.res.M;
        res = new_file.res;
        save(strcat(final_path,num2str(number),'_',newname,'.mat'),'res');
    end
end