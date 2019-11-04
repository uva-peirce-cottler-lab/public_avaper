clear all;
INCLUDE_SCALEBAR=0;


vessel_channel_ind = 1;
bio_meta.t1__bv_diam_um = 25;
bio_meta.t2_bv_diam_um = 6;
bio_meta.t3_bv_diam_um = 3;
bio_meta.t1_lectin_diam_um = 30;
bio_meta.t2_lectin_diam_um = 12;
bio_meta.t3_lectin_diam_um = 5;

% Select folder for image
base_path = 'C:\Users\bac\Box Sync\1. ARCAS\ExperimentData\Exp_259 ARCAS Imgs VEAP';
% base_path = uigetdir('Select folder for images');
output_path = [base_path '/veap'];
if isempty(dir(output_path)); mkdir(output_path); end

% get all images
items = dir([base_path '/*.ids']);
% PRocess each image
all_imgs = {items(:).name};

% parse image info
% mouse_num = cellstr(cellfun(@(x) x(1), all_imgs)');
% Get mouse eye
% eye_LR = cellstr(cellfun(@(x) x(2), all_imgs)');

hw = waitbar(0,'Processing Images');
for n = 1:numel(all_imgs)
%     n=16
    fprintf('Processing: %s\n', all_imgs{n})
    [xych_zimg, meta] =img_open([base_path '/' all_imgs{n}]);
    [r, c,ch,z] = size(xych_zimg);
    zimg = squeeze(xych_zimg(:,:,vessel_channel_ind,:));
       
    Lcorr_zimg = LightCorrect_Zstack(zimg,round(6*bio_meta.t3_lectin_diam_um *r/meta.fov_um_x));
    img = max(Lcorr_zimg,[],3);
    figure; imshow(img)
    
    % Threshold adn export RGB
    temp_img=img; temp_img(temp_img<20)=0;
    rgb_img = zeros([r c 3],'like', xych_zimg);
    rgb_img(:,:,2) =imadjust(temp_img);
%     sbar_len = ceil(r/meta.fov_um_x * 100);
%     if INCLUDE_SCALEBAR; rgb_img(end-45:end-30,end-50-sbar_len:end-50,:)=...
%                 intmax(class(rgb_img)); end
%         keyboard
 
    img_write(zimg,[output_path '/' regexprep(all_imgs{n},'\..*','') '.tif'],r/meta.fov_um_x);
    img_write(rgb_img,[output_path '/' regexprep(all_imgs{n},'\..*','') '_proc.tif'],r/meta.fov_um_x);
%      keyboard
    thresh_img = bwareaopen(max(Lcorr_zimg,[],3)>30,200);
    
    area_frac(n)= sum(thresh_img(:))/numel(thresh_img);
    if area_frac(n)>.7; keyboard; end
%     keyboard
    clean_bw = imclose(thresh_img,strel('disk',round(bio_meta.t3_lectin_diam_um*r/meta.fov_um_x)/2,0));
    img_write(clean_bw,[output_path '/' regexprep(all_imgs{n},'\..*','') '_bv.tif'],r/meta.fov_um_x);
    
    skel_bw = bwmorph(clean_bw,'thin','inf');
    img_write(skel_bw ,[output_path '/' regexprep(all_imgs{n},'\..*','') '_skel.tif'],r/meta.fov_um_x);
    vld_mmpmm2(n) = (sum(sum(skel_bw))* meta.fov_um_x/1000/r)/(1000^2/meta.fov_um_x^2);
    
%     [bw_vessel_skel, vld_um(n)] =  QuantifyLectinCapillaries(xych_zimg, meta, vessel_channel_ind, bio_meta);
% %     keyboard
% 
% %     vessl_zimg = squeeze(zimg(:,:, vessel_channel_ind,:));
%  
% 
%     vessel_skel_img = uint8(imdilate(bw_vessel_skel,strel('disk',3))*256);
%     imwrite(cat(3, vimg, vessel_skel_img, zeros(r, c,'uint8')), ...
%         [output_path '/skel_' all_imgs{n} '.jpg']);
    
%     keyboard
%     img_temp1 = imfilter(raw_img,fspecial('disk',1));
%     
%     img = img_temp1;
%     
%     bw_red = img(:,:,1) > red_thresh;
%     bw_green = (img(:,:,2) -  ...
%         imfilter(img(:,:,2),fspecial('gaussian',200,100),'replicate')) > green_thresh;
%     bw_blue = img(:,:,3) > blue_thresh;
% 
%     npix_red(n) = sum(sum(bw_red));
%     npix_green(n) = sum(sum(bw_green));
%     npix_blue(n) = sum(sum(bw_blue));
%     npix_green_blue(n) = sum(sum(bw_green | bw_blue));
%     
%     keyboard
%     figure(gcf);
%     set(gcf,'name',all_imgs{n},'numbertitle','off')
%     subplot(1,3,1); imshow(img(:,:,1) > red_thresh);
%     subplot(1,3,2); imshow(img(:,:,2) > green_thresh);
%     subplot(1,3,3); imshow(img(:,:,3) > blue_thresh);
%     pause();
waitbar(n/numel(all_imgs),hw);
end
close(hw);

% %Remove OD images
% all_imgs(od)=[];
% 
% od_imgs = all_imgs(od);
% keyboard
%Write output file
fid=fopen([output_path '/output.csv'],'w');
fprintf(fid, 'img_name,area_frac,vld_mmpmm2\n');
for n = 1:numel(all_imgs)
   fprintf(fid,'%s,%0.3f,%0.2f,\n', all_imgs{n},area_frac(n),vld_mmpmm2(n)); 
end
fclose(fid);


% keyboard
% 
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
% fprintf(fid, 'mouse_num_eye,red,green,blue,green_blue\n');
% for n = 1:numel(C)
%    fprintf(fid,'%s,%.0f,%.0f,%.0f,%.0f,\n', C{n}, st.avg_npix_red(n), ...
%        st.avg_npix_green(n), st.avg_npix_blue(n), st.avg_npix_green_blue(n)); 
% end
% fclose(fid);
% 
% 
% display('Done')