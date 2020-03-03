



in_path = 'C:\Users\bac\Desktop\Exp_248.4 Human Retina IBC CD31 COl-IV/export';



tif_files = dir([in_path '/*.tif']);
tif_files = {tif_files(:).name};
tif_files = tif_files';



w = warning ('off','all');
tbl = readtable([in_path '/image_meta.csv']);
diam_tbl = table();
kk = 1;
for n = 1:numel(tif_files)
    img = imread([in_path '/' tif_files{n}]);
    fprintf('\t%s\n', tif_files{n})
    
    ind = find(strcmp(tif_files{n},tbl.name),1,'first');
    fov_um = tbl.fov_um(ind);
    
    % Scan for ROI files
    roi_files = dir([in_path '/' regexprep(tif_files{n},'.tif','') '_*.txt']);
   
    % Load each ROI file
    for k=1:numel(roi_files)
        fprintf('%s\n', roi_files(k).name)
        roi_img = false(size(img));
        xy = readmatrix([in_path '/' roi_files(k).name]);
        BW = poly2mask(xy(:,1),xy(:,2),size(roi_img,1),size(roi_img,2));
        skel =  bwmorph(BW, 'thin', Inf);
        ed = bwdist(~BW);
        mean_diam_pix = mean(2*mean(ed(skel))+1);
        
        diam_tbl.name{kk} = roi_files(k).name;
        diam_tbl.mean_diam_um(kk) = mean_diam_pix * fov_um/size(roi_img,1);
        
        if ~isempty(regexp(roi_files(k).name,'_ac_no_lumen', 'once'))
            diam_tbl.group{kk} = 'AC Lumen(-)';
        elseif ~isempty(regexp(roi_files(k).name,'_ac_lumen', 'once'))
            diam_tbl.group{kk} = 'AC Lumen(+)';
        elseif ~isempty(regexp(roi_files(k).name,'_vessel', 'once'))
            diam_tbl.group{kk} = 'Vessel';
        else
            diam_tbl.group{kk} = 4;
        end
        
        kk = kk + 1;
    end
end
[p,tbl,stats] = anova1(diam_tbl.mean_diam_um,diam_tbl.group)

[c,~,~,gnames] = multcompare(stats);


writetable(diam_tbl,[in_path '/diam_output.csv'])