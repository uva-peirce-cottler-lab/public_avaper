function [adj_zimg] = imadjustND(zimg,prc_sat,prc_undersat)

img_hist = imhist(zimg(:));
cum_norm_img_hist = cumsum(img_hist/numel(zimg)); 

% Determine what pixel intensity are the threshold currently at
elem = @(x,k) x(k);
index = 0:255;
int_floor = elem(elem(index,(cum_norm_img_hist > prc_undersat)),1);
int_ceil = elem(elem(index,(cum_norm_img_hist > (1-prc_sat))),1)-1;

adj_zimg = immultiply(imsubtract(zimg,int_floor), double(intmax(class(zimg)))/int_ceil);

% plot(cumsum(imhist(adj_zimg(:))))

% keyboard

end