

clear all
%
WRITE_BLIND=0;
MAXIMIZE_CONTRAST = 1;
CROP_530_UM=1;
ChannelOrder = [1 2 3];
%               [rgb r g b]
INCLUDE_SCALEBAR=[0 0 0 0];
ScaleBar_Length_Um=100;
WRITE_SINGLE_CHAN = 1;
StartAfterNumber = 0;
THRESH=[0 0 0];
unblind_ext = '.png';

% Select paths
img_dir_path =  uipickfiles('FilterSpec','C:\Users\bac\Box Sync\^.*');
if ~iscell(img_dir_path); return; end
pause(.1);


% out path is first dir path
exp_nums = cellfun(@(x) str2double(regexp(x,'\\Exp_(\d*)','tokens','once')),img_dir_path);


if numel(img_dir_path)==1
    [~,img_dir]=fileparts(img_dir_path{1});
    img_dir= regexp(img_dir_path{1},'\\([^\\]*)$','tokens','once');
    out_path = [fileparts(img_dir_path{1}) '/Quant ' img_dir{1}];
else
    out_path = [fileparts(img_dir_path{1}) '/Quant Exp_' regexprep(num2str(unique(exp_nums')),'\s*|\t*',',')];
end


if ~isempty(dir([out_path '/blind/rename_log.csv'])) && WRITE_BLIND
    warndlg(['Images have already been renamed in the out path, ' ...
        'must delete manually to re randomized images']);
    return;
end

% Make output folders
mkdir([out_path '/blind']);
mkdir([out_path '/unblind']);

exp_nums=[];
img_names={};
img_paths={};

for n=1:numel(img_dir_path)
    % Detect Images
    items = dir([img_dir_path{n} '/*.*']);
    item_names = {items(:).name};
    temp_img_names = item_names(cellfun(@(x) ~isempty(...
        regexp(x,'(\.lsm)|(\.ids)','once')),item_names));
    temp_exp_num = str2double(regexp(img_dir_path{n},'[Ee]xp_([\d.]*)','tokens','once'));
    
    exp_nums = [exp_nums ones(size(temp_img_names))*temp_exp_num];
    img_names = horzcat(img_names,temp_img_names);
    img_paths = horzcat(img_paths, repmat(img_dir_path(n),size(img_names)));
    
    % Load partial z projection data if it exists
    PARTIAL_ZPROJ = 0;
    xls_name ='z_proj.xlsx';
    if ~isempty(dir([img_dir_path{n} '/' xls_name]))
        PARTIAL_ZPROJ = true;
        [raw_data, str_data] = xlsread([img_dir_path{n} '/' xls_name], 1);
        list_img_names = regexprep(str_data(2:end,1),'''','');
        
        %Extract z project data
        zmins = raw_data(:,1);
        % Check number of listed and found images match
        assert(numel(list_img_names)==numel(img_names),'Listed and Existing images different in number');
        
        % Check each listed image is the same as each found image
        ind = 1:numel(img_names); ix = zeros(size(ind));
        for n =1:numel(img_names)
            ix(n) = ind(cellfun(@(x) ~isempty(x), strfind(list_img_names,img_names{n})));
        end
    end
    
    % TODO: If rename image log exists, import and use
end
img_name_index = 1:numel(img_names);



% Load exclude CSV file if it exists for blinded images
if ~isempty(dir([out_path '/exclude_index.csv'])) && WRITE_BLIND
    fprintf('Exclude List Detected.\n')
    txt = fileread([out_path '/exclude_index.csv']);
 
    dat = regexp(txt,'(?<img_name>[^,\n]*),(?<EXCLUDE>\d*),','names');
    
    exclude_img_names = {dat.img_name};
    EXCLUDE_BV =cellfun(@(x) str2double(x), {dat.EXCLUDE});
    
    
    sorted_exclude_index = cellfun(@(y)  img_name_index(...
        cellfun(@(x) strcmp(y,x), exclude_img_names)),img_names);
    srt_exclude_bv = logical(EXCLUDE_BV(sorted_exclude_index));
    
    fprintf('%0.0f/%0.0f Images Excluded.\n',sum(EXCLUDE_BV), numel(EXCLUDE_BV));
    %     keyboard
    img_names(srt_exclude_bv)=[];
elseif isempty(dir([out_path '/exclude_index.csv']))
    
%     assert( all((cellfun(@(x) ~isempty(regexp(x,'^(\d*)[LR]','tokens','once')),...
%         img_names))),'No all image follow [mouse#][L|R]_[region][image#] naming convention')
    mouse_nums = strread(num2str(ones(size(img_names))),'%s');
    ix = 1:numel(img_names);
%     [mouse_nums, ix] = sort(cellfun(@(x) ...
%         str2double(regexp(x,'^(\d*)[LR]','tokens','once')),img_names));
    unq_mouse_nums = unique(mouse_nums);
    
    f=fopen([out_path '/exclude_index.csv'],'w');
    fprintf(f,'img_name,EXCLUDE,\n');
    for n=1:numel(img_names)
        fprintf(f, '%s,0,\n',img_names{ix(n)});
    end
    fclose(f);
end



% Write mouse_info file if DNE, maps mouse_num to group_id
if isempty(dir([out_path '/blind/mouse_info.csv']))
    
    %     keyboard
    f=fopen([out_path '/blind/mouse_info.csv'],'w');
    fprintf(f,'"group_cell = {''Veh'',''+STZ''}"\n');
    fprintf(f,'mouse_num,group_id,EXCLUDE,N\n');
    
    % Find all unique mouse numbers
    mouse_nums = cellfun(@(x) ...
        str2double(regexp(x,'^(\d*)[LR]','tokens','once')),img_names);
    seq_mouse_nums=1:max(mouse_nums);
    %     [unq_mouse_nums, ix] = sort(unique(mouse_nums));
    mouse_freq = histc(mouse_nums',seq_mouse_nums');
    
    
    for n=1:numel(seq_mouse_nums)
        fprintf(f,'%i,%d,%d,%d\n',seq_mouse_nums(n),0,0,mouse_freq(n));
    end
    fclose(f);
    
end

% Generate image name aliases and save record
if WRITE_BLIND
    % Random index for new images
    img_index =StartAfterNumber + randperm(numel(img_names))';
    
    % Create random image names, remove spaces from number padding
    img_renames = cellfun(@(x) regexprep(x,'\s',''),...
        strcat(cellstr(num2str(img_index)),{'.tif'}),'UniformOutput',0);
    % Save record of image renames
    fid = fopen([out_path '/blind/rename_log.csv'],'w');
    fprintf('exp_num,img_name,img_rename\n');
    for n = 1:numel(img_names)
        fprintf(fid,'%f,%s,%s\n',exp_nums(n), img_names{n}, img_renames{n});
    end
    fclose(fid);
else
    img_renames=img_names;
end


diary([out_path '/blind/log.txt'])
diary('on')

% Write images to disk with new image names
for n = 1:numel(img_names)
    
    try
        [raw_xychz_img, xychz_meta] = img_open([img_paths{n} '/' img_names{n}]);
        orig_img_dim = size(raw_xychz_img);
%         keyboard
%         keyboard
    catch ME
        fprintf('Exp_%.0f: %s  (to  %s) FAILED\n', exp_nums(n), img_names{n}, img_renames{n});
        if isempty(dir([img_paths{n} '/failed_import'])); ...
                mkdir([img_paths{n} '/failed_import']); end
        copyfile([img_paths{n} '/' img_names{n}], ...
            [img_paths{n} '/failed_import/' img_names{n}]);
        copyfile([img_paths{n} '/' regexprep(img_names{n},'.ids','.ics')], ...
            [img_paths{n} '/failed_import/' regexprep(img_names{n},'.ids','.ics')]);
        continue;
    end
    % If FOV is not 530 um, crop
    if CROP_530_UM && (xychz_meta.fov_um_x > 530.2)
        fprintf('[Croppped %.2f to 530.2 um]',xychz_meta.fov_um_x);
        nr = size(raw_xychz_img,1);
        pix_dist = round(nr/xychz_meta.fov_um_x*530.2);
        raw_xychz_img = raw_xychz_img(round(nr/2-pix_dist/2):round(nr/2+pix_dist/2)+mod(pix_dist,2)-1,...
            round(nr/2-pix_dist/2):round(nr/2+pix_dist/2)+mod(pix_dist,2)-1,:,:);
        %           keyboard
    end
    xychz_img = raw_xychz_img(:,:,ChannelOrder,:);
    
    
    % Zmax projection
    if ~PARTIAL_ZPROJ; zmin=1;else  zmin = zmins(ix(n)); end
    xych_img = max(xychz_img(:,:,:,zmin:size(xychz_img,4)),[],4);
    
    if MAXIMIZE_CONTRAST
        xych_img(:,:,1) = imadjust(xych_img(:,:,1));
        xych_img(:,:,2) = imadjust(xych_img(:,:,2));
        xych_img(:,:,3) = imadjust(xych_img(:,:,3));
    end
%     keyboard
    %     if THRESH;
    %         for chi = 1:3
    %             xychz_img(xychz_img<THRESH(chi))=0;
    %             xychz_img(:,:,chi)=imadjust(xychz_img(:,:,chi));
    %         end
    %     end
    
    
    if WRITE_BLIND
        fprintf('Exp_%.0f:  %s  to  %s, [FOV %.2f], [Z: %.f/%.f]\n', exp_nums(n), ...
            img_names{n}, img_renames{n},xychz_meta.fov_um_x, zmin,size(xychz_img,4));
        img_write(xych_img,[out_path '/blind/' img_renames{n}], ...
            xychz_meta.fov_um_x./orig_img_dim(1))
    else
        fprintf('Exp_%.0f: %s, [FOV %.2f], [Z: %.f/%.f]\n', exp_nums(n), ...
            img_names{n},xychz_meta.fov_um_x,zmin,size(xychz_img,4));
        sbar_len = ceil(orig_img_dim(1)/xychz_meta.fov_um_x * ScaleBar_Length_Um);
        
        out_img = xych_img;
        if INCLUDE_SCALEBAR(1); out_img(end-35:end-20,end-50-sbar_len:end-50,:)=...
                intmax(class(out_img)); end
        img_write(out_img, [out_path '/unblind/' img_names{n} unblind_ext]);%, ...
%             meta.fov_um_x./size(xych_img,1));
        if WRITE_SINGLE_CHAN
            
            out_img = xych_img; out_img(:,:,[2 3]) = 0;
            if INCLUDE_SCALEBAR(2); out_img(end-35:end-20,end-50-sbar_len:end-50,:)=...
                    intmax(class(out_img)); end
            img_write(out_img, [out_path '/unblind/' img_names{n} '_R' unblind_ext]);%, ...
%                 meta.fov_um_x./size(xych_img,1));
            
            out_img = xych_img; out_img(:,:,[1 3]) = 0;
            if INCLUDE_SCALEBAR(3); out_img(end-35:end-20,end-50-sbar_len:end-50,:)=...
                    intmax(class(out_img)); end
            img_write(out_img, [out_path '/unblind/' img_names{n} '_G' unblind_ext]);%, ...
%                 meta.fov_um_x./size(xych_img,1));
            
            if any(xych_img(:,:,3)~=0)
                out_img = xych_img; out_img(:,:,[1 2]) = 0;
                if INCLUDE_SCALEBAR(4); out_img(end-35:end-20,end-50-sbar_len:end-50,:)=...
                        intmax(class(out_img)); end
                img_write(out_img, [out_path '/unblind/' img_names{n} '_B' unblind_ext]);%, ...
%                     meta.fov_um_x./size(xych_img,1));
            end
        end
    end
    %     keyboard
end

if WRITE_BLIND
    diary('off')
end



