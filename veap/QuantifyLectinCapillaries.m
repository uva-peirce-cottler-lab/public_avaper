function [bw_vessel, vld_um] =  QuantifyLectinCapillaries(zimg, img_meta, vessel_channel_ind,bio_meta)
% Quantify capillary Density

% Define kernel relative to vessel size of 4 um
 
t3_diam_pix = ceil(bio_meta.t3_lectin_diam_um*size(zimg,2)/img_meta.fov_um_x);
thresh=50; 


raw_vessel_zimg = squeeze(zimg(:,:,vessel_channel_ind, :));
adj_raw_vessel_zimg = imadjustND(raw_vessel_zimg,0.03,0.03);


% keyboard
vessel_zimg = imfilter(adj_raw_vessel_zimg, fspecial('gaussian', ceil(t3_diam_pix/4), double(intmax(class(zimg))/25)));
% imv
% keyboard

% raw_vessel
vessel_img = max(vessel_zimg,[],3);

corr_vessel_zimg = LightCorrect_Zstack(vessel_zimg);

% keyboard





%Adjust each zslice intensity
bvessel_zimg = imfilter(corr_vessel_zimg, fspecial('disk',3));
background_zimg = imfilter(bvessel_zimg, fspecial('disk',4*t3_diam_pix));
bs_vessel_zimg = (bvessel_zimg - background_zimg);
bw_vessel_zimg = bs_vessel_zimg > thresh;
bw_vessel_img = (max(bvessel_zimg - background_zimg,[],3)) > thresh;
% keybosard

bw_raw_skel = bwmorph(bw_vessel_img,'skel',Inf);


bw_skel = RemoveSmall_EndpointSegments(bw_raw_skel,img_meta,bio_meta);

bw_vessel = bw_skel;

vld_um = sum(bw_vessel(:)) * img_meta.fov_um_x/size(zimg,1);






end


