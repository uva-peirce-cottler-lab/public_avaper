function [img_out, FLAG_OV] = im_restricted_add(img, img_kernel, ...
    rc_ctr,start_val)
% bw: image that the kernel is conv over
% bwk: kernel to use for convolution, must be odd dim vals
% rc_ctr: center coordinate of crop
% If kernel has an even dimension, then the center is the far boundary between
% the halfway pixel
inc_img_kernel = immultiply(imadd(img_kernel,start_val),(img_kernel>0));

kern_dim = size( inc_img_kernel);

% Get row col of cell center
r = rc_ctr(1);% r_ind(shuff_lindex(n));
c = rc_ctr(2); %c_ind(shuff_lindex(n));

isEven= @(x) mod(x,2)==0;

% Kernel change in row and columnf rom center
% delta kernal [row,column]
dkr = [round((size(inc_img_kernel,1)-1)/2) round((size(inc_img_kernel,1)-1)/2)] -...
 [isEven(kern_dim(1)) 0];
dkc = [round((size(inc_img_kernel,2)-1)/2) round((size(inc_img_kernel,2)-1)/2)] -...
 [isEven(kern_dim(2)) 0];
% Kernel center coordinate
kr = dkr(1)+1;
kc = dkc(1)+1;

%  |   |  *|   |   |
% Find delta row + col from center to zero out (within simulation)
delt_r = [r-max([1 r-dkr(1)])...
    min([size(img,1) r+dkr(2)])-r];
delt_c = [c-max([1 c-dkc(1)])...
    min([size(img,2) c+dkc(2)])-c];


% Add more excluded region to the exclude image
img_out = img;
img_add = img_out(r-delt_r(1):r+delt_r(2), c-delt_c(1):c+delt_c(2));
kern_add = inc_img_kernel(kr-delt_r(1):kr+delt_r(2),kc-delt_c(1):kc+delt_c(2));

% keyboard

% Excise original image for insertion
img_out(r-delt_r(1):r+delt_r(2), c-delt_c(1):c+delt_c(2)) = ...
    imadd(img_add,kern_add);

% Check for overlap
FLAG_OV = any(any(img_add & kern_add));

