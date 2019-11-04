

img_path = 'D:\Box Sync\Publications\Review_VesselNetworks\Figure images\Exp_302_mouse2_MAX_col4_track_3d_zstack.tif';

st = imfinfo(img_path);

xyzch_img = zeros([st(1).Width st(1).Height numel(st)],'uint16');

V = zeros([256 256 numel(st)],'uint8');
for z=1:numel(st)
    xyzch_img(:,:,z) = imread(img_path,z);
    V(1:256, 1:256,z) = imgaussfilt(im2uint8(imresize(xyzch_img(:,:,z), [256 256])),...
        [3,3]);
end

% [xyzch_img, meta] = img_open(img_path);


% xyzch_bw = xyzch_img>0.15*2^8;
W = smooth3(V,'box',[5 5 3]);

% Zero out each z 50% below max
max(W,[],3)/2

bwW = bsxfun(@lt,W,max(W,[],3)/2);

% V = xyzch_bw;
% [X,Y,Z] = meshgrid(1:size(xyzch_bw,1),1:size(xyzch_bw,2),1:size(xyzch_bw,3));
isosurface(W>0.16*256,0.5);



analysis_path = 'D:\Box Sync\11. IBC\Exp_302 Retina HighResolution PC Col-IV Tracks\mouse2 NG2_647 CD31_488 COL-IV_546\Session2';


items = dir([analysis_path '/*.txt']);

is_track = arrayfun(@(x) ~isempty(regexp(x.name,'track','once')),items);

pix_int = zeros(numel(items),10);
for n=1:numel(items)
        tbl = readtable([analysis_path '/' items(n).name]);
        rescaled = interp1(1:size(tbl,1),tbl.Var3,linspace(1,size(tbl,1)-1,10));
        pix_int(n,:) = rescaled./max(rescaled);
end

track_vals = pix_int(is_track,:);
vess_vals = pix_int(~is_track,:);



% SEM = std(x)/sqrt(length(x))

c1 = [156 91 205]./256;
c2 = [97 149 61]./256;

plot(0.05:.1:1,mean(track_vals,1),'+','Color',c1); hold on
errorbar(0.05:.1:1,mean(track_vals,1),std(track_vals,1),'-','Color',c1)

plot(0.05:.1:1,mean(vess_vals,1),'+','Color',c2); hold on
errorbar(0.05:.1:1,mean(vess_vals,1),std(vess_vals,1),'-','Color',c2)
hold off
xlabel('Rel. Cross-Section Distance')
ylabel('Rel. Pixel Intensity')
beautifyAxis(gca)
axis([0.0 1 0 1.1])
set(gcf,'Position',[680   723   304   255])

for c=1:10;
   [~,pval(1,c)]=ttest2(track_vals(:,c),vess_vals(:,c)); 
    
end

[p,tbl,stats] = anova2(vertcat(track_vals, vess_vals),10);
c = multcompare(stats)