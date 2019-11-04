function [bw_skel]=RemoveSmall_EndpointSegments(bw_raw_skel,img_meta, bio_meta)


t3_diam_pix = ceil(bio_meta.t3_lectin_diam_um*size(bw_raw_skel,2)/img_meta.fov_um_x);

[bw_prev_skel, bw_skel] = deal(bw_raw_skel);
 
for n=1:20
    % Remove segments that are attached to endpoint that are too short
    bw_ep = bwmorph(bw_skel,'endpoints');
    bw_bp = bwmorph(bw_skel,'branchpoints');
    bw_seg = bw_skel & ~bw_bp;
    bw_ep_seg = bw_seg + bw_ep;
    
    
    CC = bwconncomp(bw_ep_seg);
    remove_bv = cellfun(@(x) sum(bw_ep_seg(x)==2)>0 & numel(x)< (2*t3_diam_pix), CC.PixelIdxList);

    bw_skel(vertcat(CC.PixelIdxList{remove_bv}))=0;
    fprintf('%0.0f: %0.0f total pixels, %0.0f pixel removed\n',n,...
        sum(bw_skel(:)), sum(bw_prev_skel(:)-bw_skel(:)));
    
    if sum(bw_prev_skel(:)-bw_skel(:))==0;  
        break; 
    end
        bw_prev_skel = bw_skel; 
end

