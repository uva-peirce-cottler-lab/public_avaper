function ibc_compile_cell_count_xmls(xmls_path)

count_types = {'Quiescent PC', 'PC w/ OV Process', ...
    'Classic IBCs', 'Bridging PC', 'OV Process', 'Unmarked OV Process','Unmarked IBCs',...
    'Stain Quality','Tissue Quality','Vessel Length','Branchpoint Density',...
    'Vessel segment count','Vessel Tortuosity','Vessel Tortuosity2','Vessel Diam.','End Segment Diam.','Cont. Segment Diam.','FOV Um'};
count_type_varnames = {'q_pc', 'p_ibc', 'ibc', 'b_ibc', ...
    'ov_proc', 'unmark_ov_proc','unmark_ibc','img_qual','tiss_qual','vessel_len_um',...
    'bp_count','vess_nseg','vess_tort','vess_tort2','vess_diam_um','end_vess_diam_um','cont_vess_diam_um','fov_um'};
if ~exist('xmls_path','var')
    % Select folder where input xml files are
    xmls_path = uigetdir('C:\Users\bac\Box Sync\11. IBC\_Study Data','select count directory');
end
xmls_items = dir([xmls_path '/*.xml']);
xmls_names = {xmls_items(:).name}';
 

% Get rename log to get original names of images
[raw_data, str_data] = xlsread([xmls_path '/mouse_info.csv']);
eval(str_data{1,1});
hdr_info = [str_data{1,1} ' hdr_row=4;'];
req_vars = {'DATA_IS_PAIRED','group_names','cell_marker','x_axis_label'};
for n=1:numel(req_vars)
    assert(logical(exist(req_vars{n},'var')),[req_vars{n} ' not included in mouse_info.csv']);
end

% Metadata from mouse_info files (EXCLUDE, group_id, mouse_num, extra mouse
% info
group_id_by_mouse = raw_data(:,2);
extra_data_labels = str_data(2,3:end);
extra_data = raw_data(:,3:end);

%Get XML files in image path
elem = @(x) x{1};
img_renames = cellfun(@(x) elem(regexp(x,'(\d*\.tif)|(\d*\.xml)','once','tokens')), ...
    xmls_names,'UniformOutput', 0);
xml_img_num = cellfun(@(x) str2double(elem(regexp(x,'(\d*)\.','once','tokens'))), ...
    img_renames, 'UniformOutput', 1);
[sorted_xml_img_num,ix] = sort(xml_img_num);
sorted_xmls_names = xmls_names(ix);
n_xmls = numel(sorted_xmls_names);
% Variables with same order
% sorted_xml_img_num, sorted_xmls_names

% Get timepoint data
dir_names = regexp(xmls_path,'[\\\/]','split');
tp = regexp(dir_names{end-1}, '\sD(\d*)\s','tokens','once');

if isempty(tp) || isempty(tp{1}); tp= {'0'}; end
tp_cell = repmat(tp, [n_xmls,1]);


% Get rename log to get original names of images 
[raw_data, str_data] = xlsread([xmls_path '/rename_log.csv']);
% get image num of renames, sort orig images
rename_img_num = cellfun(@(x) str2double(elem(regexp(x,'(\d*)','once','tokens'))), str_data(:,2), 'UniformOutput', 1);
[sorted_rename_img_num,ix] = sort(rename_img_num);
sorted_img_renames = str_data(ix,2);
sorted_orig_img_names = str_data(ix,1);
sorted_mouse_nums = cellfun(@(x) str2double(regexp(x,'^(\d*)[LRlr]','tokens','once')),...
    sorted_orig_img_names,'UniformOutput',1);

if DATA_IS_PAIRED
    sorted_group_id = cellfun(@(x) ...
        sprintf('%.f',strcmpi(regexp(x,'[\d]*([LRlr])_.*', 'tokens','once'),'R')+1), ...
        sorted_orig_img_names,'UniformOutput', 0);
else
    sorted_group_id= strread(num2str(group_id_by_mouse(sorted_mouse_nums )'),'%s');
end
exp_num = raw_data(ix,1);
% keyboard

% For each xml image num, find corresponding unmasked filename
ind = 1:numel(sorted_rename_img_num);
quant_imgs_index = arrayfun(@(x)  ind(x==sorted_rename_img_num), sorted_xml_img_num);
quant_imgs_name = sorted_orig_img_names(quant_imgs_index);
quant_imgs_rename = sorted_img_renames(quant_imgs_index);
quant_exp_num = exp_num(quant_imgs_index);
quant_group_id = sorted_group_id(quant_imgs_index);
quant_mouse_nums = sorted_mouse_nums(quant_imgs_index);

% Count data, img x count classes:
% pc, part_ibc, bridge_ibc, classic_ibc, ov proc
counts = zeros(numel(sorted_xmls_names,5));


% If img_qual.csv exists, overwrite tiss_qual (9)
img_qual_tbl=[];
if ~isempty(dir([xmls_path '/img_qual.csv']));
    img_qual_tbl = readtable([xmls_path '/img_qual.csv']);
end


% Load count data, vessel density, from each xml file
counts = zeros(numel(sorted_xmls_names), 9);
for n = 1:numel(sorted_xmls_names)
    % Read xm data into struct
    xdoc = xmlread([xmls_path '/' sorted_xmls_names{n}]);
    st = xml2struct(xdoc);
    
    % Count instances of each marker class
    for k = 1:9
        if (k<= numel(st.CellCounter_Marker_File.Marker_Data.Marker_Type)) && ...
                isfield(st.CellCounter_Marker_File.Marker_Data.Marker_Type{k},'Marker');
            counts(n,k) = numel(st.CellCounter_Marker_File.Marker_Data.Marker_Type{k}.Marker);
        end
    end
    
    
    if ~isempty(img_qual_tbl)
        % Find index of image name in img_qual table
        bv = cellfun(@(x) strcmp(x,sorted_orig_img_names{n}),img_qual_tbl.img_name);
        inds = 1:numel(sorted_xmls_names);
        match_ind = inds(bv);
        
        % Update counts valus
        counts(n,k) = img_qual_tbl.tiss_qual(match_ind(1));
    end
    
    % Field of view is hardcoded
    fov_um(n,1)=530.2;
    
    
    if ~isempty(dir([xmls_path '/' num2str(sorted_xml_img_num(n)) '.mat']))
        % Load matlab file if it exists
        st=load([xmls_path '/' num2str(sorted_xml_img_num(n)) '.mat']);
            
        % IF a corrected BW exists load that instead
         if ~isempty(dir([xmls_path '/correctedData/' num2str(sorted_xml_img_num(n)) '.mat']))
            st2 = load([xmls_path '/correctedData/' num2str(sorted_xml_img_num(n)) '.mat']);
            st.derivedPic.BW_2 = st2.derivedPic.BW_2;
         end
         
        % Vessel length and Branchpoint density
        vessel_len_um(n,1) = nnz(st.derivedPic.wire) * ...
            (fov_um(n,1)/mean(st.imageSize));
        bp_count(n,1)=size(st.derivedPic.branchpoints,1);

        
        % Vessel tortuosity and # segments
        % Add average radius and calssify each lineseg
        rcind_seg_cell = skel_2_linesegs(st.derivedPic.wire,...
            fliplr(st.derivedPic.branchpoints),fliplr(st.derivedPic.endpoints));
        vess_nsegs(n,1) = size(rcind_seg_cell,1);
        vess_tort(n,1) = mean(rcind_seg_tortuosity(rcind_seg_cell));
        % Richard's tortuosity function
%         keyboard
        vess_tort2(n,1) = tortuosityCalculatorFunction(...
            [xmls_path '/' num2str(sorted_xml_img_num(n)) '.mat']);


       % Measure segment radii and record diameter
        [all_seg_rads, index_tbl] = measure_segment_rad(rcind_seg_cell,...
            st.derivedPic.BW_2, fliplr(st.derivedPic.endpoints));
       all_seg_diams = 2.*all_seg_rads+1;
       vess_diam_um(n,1) = mean(all_seg_diams) .* (fov_um(n,1) ./ st.imageSize(1));
       end_vess_diam_um(n,1) = mean(all_seg_diams(index_tbl.end_seg_idx)) .*...
           (fov_um(n,1) ./ st.imageSize(1));
       cont_vess_diam_um(n,1) = mean(all_seg_diams(~index_tbl.end_seg_idx)) .*...
           (fov_um(n,1) ./ st.imageSize(1));
       
    else 
        vessel_len_um(n,1)=NaN;
        bp_count(n,1)=NaN;
        vess_nsegs(n,1)=NaN;
        vess_tort(n,1)=NaN;
        vess_tort2(n,1)=NaN;
        vess_diam_um(n,1)=NaN;
        end_vess_diam_um(n,1)=NaN;
        cont_vess_diam_um(n,1)=NaN;
        
    end
    
end


% Text version of output data sorted by image number
count_data_cell = arrayfun(@(x) sprintf('%.0f',x),counts,'UniformOutput',0);



% keyboard
% vessel_density = arrayfun(@(x) sprintf('%0.0f',x),zeros(numel(img_renames),1),'UniformOutput', 0);
% FOV_um = arrayfun(@(x) sprintf('%0.0f',x),ones(numel(img_renames),1)*530.2,'UniformOutput', 0);

% Add extra data sorted by mouse
quant_extra_data = arrayfun(@(x) sprintf('%0.1f',x), extra_data(quant_mouse_nums,:),'UniformOutput',0);

% [~,xml_dir] = fileparts(fileparts(xmls_path));
% dir_names = regexp(xmls_path,'[\\\/]','split');
% tp = regexp(dir_names{end-1}, 'D(\d*)','tokens','once');
% if isempty(tp{1}); tp= {'0'}; end
% tp_cell = repmat(tp, [n_xmls,1]);
% keyboard

% keyboard
% keyboard
% Create output table
% exp_num = regexp(xmls_path,'\\Exp_([\d\.]*)','tokens','once');
% keyboard

% col_labels = horzcat({'exp_num', 'tp_day', 'mouse_num','img_name', 'img_rename','group_id'}, ...
%     count_type_varnames, extra_data_labels)
% num_labels = [repmat({' '},[1 6]) arrayfun(@(x) sprintf('%d',x),1:9,'UniformOutput',0)...
%     ];
     
xhdr = vertcat([hdr_info, cell(1,24+numel(extra_data_labels))],...
    [{'','','','','','','1','2','3','4','5','6','7','8','9','','','','','','','','','',''}, cell([1 numel(extra_data_labels)])],...
    horzcat({'Exp', 'TP', 'Mouse #','Name','IsLeft','Alias', 'Group'}, count_types, extra_data_labels),...
    horzcat({'exp_num', 'tp', 'mouse_num','img_name', 'is_lefteye' ,'img_rename','group_id'}, ...
    count_type_varnames, extra_data_labels));
% keyboard
left_eye = cellfun(@(x) sprintf('%d', ~isempty(regexp(x,'^.d*[Ll]_', 'once'))),...
    quant_imgs_name,'uniformoutput', 0);

% keyboard
% exp_num, sorted_group_id,
xdata = horzcat(strread(num2str(quant_exp_num'),'%s'), tp_cell,...
    strread(num2str(quant_mouse_nums'),'%s'),...
    quant_imgs_name, left_eye,quant_imgs_rename,quant_group_id,...
    count_data_cell,cellstr(num2str(vessel_len_um)),...
    cellstr(num2str(bp_count)),cellstr(num2str(vess_nsegs)), cellstr(num2str(vess_tort)),...
    cellstr(num2str(vess_tort2)),...
    cellstr(num2str(vess_diam_um)),cellstr(num2str(end_vess_diam_um)),...
    cellstr(num2str(cont_vess_diam_um)),...
    cellstr(num2str(fov_um)), quant_extra_data);

% keyboard 
if ~isempty(dir([xmls_path '/ibc_counts.xlsx'])); delete([xmls_path '/ibc_counts.xlsx']); end
xlswrite([xmls_path '/ibc_counts.xlsx'],vertcat(xhdr,xdata));


% keyboard

end