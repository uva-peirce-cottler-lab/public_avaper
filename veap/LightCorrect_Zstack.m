function final_zimg = LightCorrect_Zstack(zimg,bck_kernel_size)


% Subtract background
bck_zimg=zeros(size(zimg),'like',zimg);
% keyboard
for z = 1:size(zimg,3)
    bck_zimg(:,:,z) = medfilt2(zimg(:,:,1),[bck_kernel_size ...
        bck_kernel_size].*4 ,'symmetric');  
end
sub_zimg = zimg-immultiply(bck_zimg,.99);



pix_int = zeros(1, size(sub_zimg,3));

for z = 1:size(sub_zimg,3)

    img = sub_zimg(:,:,z);
    BW1 = edge(sub_zimg(:,:,z),'sobel');
%     imshow(BW1);pause;
    pix_int(z) = median(img(BW1));
    npix(z) = sum(sum(BW1));
%     BW2 = edge(I,'canny');
end


% plot(pix_int)
% plot(npix);

% Eliminate z slices from fit that have an insufficient feature score
%     Union of pix number and pixel intensity from edge detection
feature_score = (pix_int./max(pix_int)) .* (npix./max(npix));
z_index = 1:size(sub_zimg,3);
signal_score = pix_int;
remove_ind = feature_score < 0.5;
signal_score(remove_ind)=[];
z_index(remove_ind)=[];

% Fit line to remaining slices, get pix_int scaling factors for each slice
pf = polyfit(z_index,signal_score./max(signal_score),1);
z=1:size(sub_zimg,3);
corr_factor = polyval(pf,z);
pf
% Apply correction
sub_corr_zimg = uint8(bsxfun(@times, double(sub_zimg), permute(1./corr_factor,[3 1 2])));

final_zimg = bsxfun(@minus, sub_corr_zimg, min(sub_corr_zimg,[],3));


% keyboard

end