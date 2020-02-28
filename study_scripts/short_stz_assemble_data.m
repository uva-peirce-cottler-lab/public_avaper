clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\Shortterm STZ'];

xls_list{1} = [base_path '\_Study Data\Study STZ D7\Quant Exp_243 STZ D7 IBC C57Bl6\blind'];
xls_list{2} = [base_path '\_Study Data\Study STZ D7\Quant Exp_256 D7 STZ Batch2\blind'];
xls_list{3} = [base_path '\_Study Data\Study STZ D14\Quant Exp_247 STZ D14 C57Bl6 IBC InsTx\blind'];
xls_list{4} = [base_path '\_Study Data\Study STZ D14\Quant Exp_255.1 STZ D14 C57Bl6\blind'];
xls_list{5} = [base_path '\_Study Data\Study STZ D14\Quant Exp_255.2 STZ D14 C57Bl6\blind'];

if PROCESS_XMLS
    for n=1:numel(xls_list)
        ibc_compile_cell_count_xmls(xls_list{n});
        
    end
end

if BACKUP_DATA
    for n=1:numel(xls_list)
        ibc_backup_data([xls_list{n} '/ibc_counts.xlsx'], curr_path);
    end
end



[avg_tbl, raw_tbl] = ibc_compile_results(strcat(xls_list,'/ibc_counts.xlsx'), curr_path,5);



if false
    %Plot Fractional colabeling of markers with COL-IV tracks
    d14_grp1_tbl = avg_tbl(avg_tbl.tp==14 & avg_tbl.group_id==1,:);
    grp_mat2 = table_to_grp_mat(d14_grp1_tbl, 'frac_marked_proc');grp_mat2(:,2)=2;
    
    grp_mat1 = grp_mat2; grp_mat1(:,4)=0; grp_mat1(:,2)=1;
    
    grp_mat3 =  table_to_grp_mat(d14_grp1_tbl, 'frac_unmarked_proc');
    grp_mat3(:,2)=3;
    
    grp_mat_all = vertcat(grp_mat1, grp_mat2, grp_mat3);
    
    [hf,signif_table] = plot_timecouse(grp_mat_all, {'CD31/CD105+','NG2+','Neither'},...
        0, 'Y_Text', 'Fract. of Col-IV Proc.','X_Text','', ...
        'Extra_Text', ['Days_14' '_procs'],...
        'Figure_Letter',char(64+15),'Export_Path',curr_path, ...
        'INCLUDE_LEGEND', 0,'CROSS_TP_STATS',0,'Marker_Symbols',{'bo','go','ro'},'DRAW_GROUP_LINE',0);
end 

% keyboard
% Collagen Analysis
 
if false 
    
    
    % Compare process radius in collagen 4
    
    img_name_cell = {'21L_I1.ids','21L_I2.ids','21R_I1.ids',...
        '22L_I1.ids','22L_I2.ids','22L_I6.ids',...
        '6L_I1.ids', '6L_I2.ids','6L_I4.ids'...
        '1L_I1.ids','1L_I5.ids','1R_I5.ids',...
        '2L_I2.ids','2L_I3.ids','2L_I5.ids',...
        '3L_I3.ids','3L_I4.ids','3L_I2.ids'};
    ng2_proc_diams_um = zeros(3,6);
    col4_proc_diams_um = zeros(3,6);
    vess_seg_diams_um = zeros(3,6);
    end_vess_rad_um = zeros(3,6);
        cont_vess_rad_um = zeros(3,6);
        
        
    dataset_path =xls_list{4};
    for n=1:numel(img_name_cell)
        
        % Find blinded image name
        [x, idx] = ismember(img_name_cell{n}, raw_tbl.img_name);
        img_rename = raw_tbl.img_rename{idx};
        
        end_vess_rad_um(n) = raw_tbl.end_vess_diam_um(idx);
        cont_vess_rad_um(n) = raw_tbl.cont_vess_diam_um(idx);
    
        % Load image
        rgb_img = imread([dataset_path '/' img_rename]);
        img = rgb_img(:,:,1);
        %      1.xml
        count_xml = xml2struct([dataset_path '/CellCounter_' regexprep(img_rename,'.tif','.xml')]);
        gs_proc_region = cellcounter_xml_2_watershed(count_xml,size(img));
        
        [edge_img,eg_thresh] = edge(img,'canny', [0.02 0.06]);
        %      figure; imshow(edge_img)
        %      conv2(edge_img, [1 0 0; 0 0 0; 0 0 0],'same')
        bw_proc = imerode(imclose(edge_img,strel('disk',3,0)),strel('disk',2));
        %      figure; imshow(img)
        % Load metadata
        st = load([dataset_path '/' regexprep(img_rename,'tif','mat')]);
       
        % Vessel tortuosity and # segments
        % Add average radius and calssify each lineseg
        rcind_seg_cell = skel_2_linesegs(st.derivedPic.wire,...
            fliplr(st.derivedPic.branchpoints),fliplr(st.derivedPic.endpoints));
        %      vess_nsegs(n,1) = size(rcind_seg_cell,1);
        %      vess_tort(n,1) = mean(rcind_seg_tortuosity(rcind_seg_cell));
        %         keyboard
        all_seg_rads= measure_segment_rad(rcind_seg_cell,...
            st.derivedPic.BW_2, fliplr(st.derivedPic.endpoints));
        
        [all_col4_proc_rads_pix, ng2_proc_rads_pix,col4_only_proc_rads_pix] = skel_2_proc_segs(st.derivedPic.wire,...
            st.derivedPic.BW_2,bw_proc,gs_proc_region);
        
%         ng2_proc_diams_um(n) = (2*ng2_proc_rads_pix+1).* (raw_tbl.fov_um(idx) ./ st.imageSize(1));
        col4_proc_diams_um(n) = (2*all_col4_proc_rads_pix+1).* (raw_tbl.fov_um(idx) ./ st.imageSize(1));
        
        vess_seg_diams_um(n)= 2*mean(all_seg_rads+1) .* (raw_tbl.fov_um(idx) ./ st.imageSize(1));
        
    end

    
    
    
    % ECs
    grp_mat1=zeros(6,4);
    grp_mat1(:,2)=1; grp_mat1(:,4)= mean(vess_seg_diams_um,1);
    % PCs
%     grp_mat2=zeros(6,4);
%     grp_mat2(:,2)=2; grp_mat2(:,4)= mean(ng2_proc_diams_um,1);
    % Nnot EC Marker
    grp_mat3=zeros(6,4);
    grp_mat3(:,2)=2; grp_mat3(:,4)= mean(col4_proc_diams_um,1);
    
    grp_mat_all = vertcat(grp_mat1,grp_mat3);
    
    [hf,signif_table] = plot_timecouse(grp_mat_all, {'EC+','EC-'},...
        0, 'Y_Text', 'Segment Diam. (um)','X_Text','', ...
        'Extra_Text', ['Days_14' '_proc_rad'],...
        'Figure_Letter',char(64+n),'Export_Path',curr_path, ...
        'INCLUDE_LEGEND', 0,'CROSS_TP_STATS',0,'Marker_Symbols',{'bo','go','ro'},'DRAW_GROUP_LINE',0);
    
    
    % data_by_group: TP || group || mouse || data
    grp_mat_seg = ones(12,4);
    grp_mat_seg(7:end,2)=2;
    grp_mat_seg(1:6,4)=mean(end_vess_rad_um,1)';
    grp_mat_seg(7:12,4)=mean(cont_vess_rad_um,1)';
    
    [hf,signif_table] = plot_timecouse(grp_mat_seg, {'Cont.','End'},...
        0, 'Y_Text', 'Col-IV Segment Rad. (um)','X_Text','', ...
        'Extra_Text', ['Days_14' '_proc_rad'],...
        'Figure_Letter',char(64+n),'Export_Path',curr_path, ...
        'INCLUDE_LEGEND', 0,'CROSS_TP_STATS',0,'Marker_Symbols',{'bo','go','ro'},'DRAW_GROUP_LINE',0);
end

