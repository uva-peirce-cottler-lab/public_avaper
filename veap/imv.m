function imv(img)

h = figure;
for n = 1:size(img,3); imshow(img(:,:,n));pause; end

close(gcf);