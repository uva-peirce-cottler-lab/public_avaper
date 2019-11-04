clear all;
fov = 530; %um

thresh = [1 1 1]*10;
% Array of channels to be processed
chan_proc_ind = [1 2];

% Select folder for image
% base_path = 'C:\Users\bac\Box Sync\6. Uveitis\Exp_KF1 Uveitis C6_Ceramide';
base_path = uigetdir('Select folder for images');
if base_path==0; return; end

% get all images
items = dir([base_path '/*.tif']);
% Find images with all channels
bv = cellfun(@(x) ~isempty(regexp(x,'.*all_chan.*', 'once')), {items(:).name});

% Process each image
all_imgs = {items(bv).name};

% parse image info
mouse_num = cellstr(cellfun(@(x) x(1), all_imgs)');
% Get mouse eye
eye_LR = cellfun(@(x) ~isempty(regexp(x,'\d*R_','once'))*1,all_imgs);

% Image Depth
% Top:1, Mid:2, Bot:3
depth_1 = cellfun(@(x) ~isempty(regexp(x,'_top_','once'))*1,all_imgs);
depth_2 = cellfun(@(x) ~isempty(regexp(x,'_mid_','once'))*2,all_imgs);
depth_3 = cellfun(@(x) ~isempty(regexp(x,'_bot_','once'))*3,all_imgs);
depth = depth_1+depth_2+depth_3;

% OD:1
% Central: 2
% Peripheral: 3
loc_1 = cellfun(@(x) ~isempty(regexp(x,'_OD','once'))*1,all_imgs);
loc_2 = cellfun(@(x) ~isempty(regexp(x,'_C|c\d\.','once'))*2,all_imgs);
loc_3 = cellfun(@(x) ~isempty(regexp(x,'_P|p\d\.','once'))*3,all_imgs); 
loc_xy = loc_1+loc_2+loc_3;



output_path = [base_path '/out'];
if isempty(dir(output_path)); mkdir(output_path); end


area_fraq = zeros(numel(all_imgs),numel(chan_proc_ind)+1);
union_fraq = zeros(numel(all_imgs),1);


for n = 1:numel(all_imgs)
     raw_img = imread([base_path '/' all_imgs{n}]);
    export_img = zeros(size(raw_img),'uint8');
    fprintf('Opening: %s\n', all_imgs{n});
    
    for ch = chan_proc_ind
     
%     keyboard
%     raw_img = imread('C:\Users\bac\Box Sync\6. Uveitis\Exp_KF1 Uveitis C6_Ceramide\2R_OD.ics_top_all_chan.tif');
    
    % Light blurring of image
    img_f = imfilter(raw_img(:,:,ch),fspecial('gaussian',5,3),'symmetric');
    
    img_max = max(max(imfilter(raw_img(:,:,ch),fspecial('gaussian',30,3),'symmetric')));
    
    bck_lvl = medfilt2(img_f, [50 50],'symmetric');
    
    % Method 1: subtract global background found in each image, fixed
    % threshold
%    export_img(:,:,ch) = ((img_f - bck_lvl) > thresh(ch))*256;
    
    % Method 2: Subtract global background found in each image, variable max
    % based threshold 
%     export_img(:,:,ch) = ((img_f - bck_lvl) > (img_max-bck_lvl)/10)*256;
    
    % Method 3: Subtract background image with fixed threshold
    bck_img = medfilt2(img_f, [25 25],'symmetric');
    export_img(:,:,ch) = ((img_f - bck_img) > thresh(ch))*256;
    
    end
       
    area_fraq(n,:) =squeeze(sum(sum(export_img))./ numel(raw_img(:,:,1)))';
    union_fraq(n,1) = squeeze(sum(sum(export_img(:,:,1) | export_img(:,:,2) | export_img(:,:,3)))...
        ./ numel(raw_img(:,:,1)));
    
    imwrite(uint8(export_img), ...
        [output_path '/' all_imgs{n}]);
    
    imwrite(raw_img, ...
        [output_path '/' all_imgs{n} 'orig.tif']);
end

% keyboard

% Write output file
fid=fopen([output_path '/output.csv'],'w');
fprintf(fid, 'mouse_num,eye,xy_loc,depth,red,green,blue,red_green\n');
for n = 1:numel(all_imgs)
   fprintf(fid,'%s,%d,%d,%d,%d,%d,%d,%d\n', all_imgs{n}, eye_LR(n), loc_xy(n),depth(n), ...
       area_fraq(n,1), area_fraq(n,2), area_fraq(n,3), union_fraq(n)); 
end
fclose(fid);

% % Group OD and peripheral groups
% % [C,ia,ic]  = unique(strcat(mouse_num, eye_LR, depth,od));
% [C,ia,ic]  = unique(strcat(mouse_num, eye_LR,depth));
% 
% for n = 1:numel(C);
%     st.avg_npix_red(n) = mean(npix_red(n == ic));
%     st.avg_npix_green(n) =  mean(npix_green(n == ic));
%     st.avg_npix_blue(n) =  mean(npix_blue(n == ic));
%     st.avg_npix_green_blue(n) = mean(npix_green_blue(n == ic));
% end
% 
% % Write output file
% fid=fopen([base_path '/avg_output.csv'],'w');
% fprintf(fid, 'mouse_num,eye,red,green,blue,green_blue\n');
% for n = 1:numel(C)
%    fprintf(fid,'%s,%.0f,%.0f,%.0f,%.0f,\n', C{n}, st.avg_npix_red(n), ...
%        st.avg_npix_green(n), st.avg_npix_blue(n), st.avg_npix_green_blue(n)); 
% end
% fclose(fid);
% 

display('Done')