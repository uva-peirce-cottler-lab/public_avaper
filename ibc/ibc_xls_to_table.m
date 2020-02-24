function [raw_tbl, eval_str] = ibc_xls_to_table(xls_path)


%                    Read xlm file
% Read in xlsx file
[raw_data, str_data] = xlsread([xls_path], 1);
% DATA_IS_PAIRED, group_names, cell_marker
eval_str = str_data{1,1}; 
eval(eval_str);

% q_pc	p_ibc	ibc	b_ibc	ov_proc
% ibcs/fov	QC PCS/FOV	all pcs/fov	fraction of (IBC/PC)	Vasc. Density
% total Ibcs		total pcs	frac ibcs	vasc_dens_umpmm
% hdr_row = find((sum(isnan(raw_data(2:end,:)),2)==size(raw_data,2))==0,1,'first');

% Cull images not included in data
ind = 1:size(raw_data,1);
ix = ind(~isnan(raw_data(:,1)));

% assign variables
img_names = str_data(ix+1,4);
img_names(cellfun(@(x) isempty(x),img_names))=[];

hdrs = str_data(hdr_row,:);
% Autoload 
raw_tbl = table();
for n=1:numel(hdrs)
   dbl_vals = raw_data(ix,n);
   str_vals = str_data(hdr_row+1:end,n);
   isNaN_str_vals = cellfun(@(x) strcmp('NaN',x),str_vals);
   if isempty(str_vals{1}) || all(isNaN_str_vals)
       raw_tbl.(hdrs{n}) = dbl_vals;
   else
      raw_tbl.(hdrs{n}) = str_vals; 
   end
end
% If all is nans then convert to double

% keyboard
% 	u

% Additional Variables
raw_tbl.all_ov_proc = raw_tbl.ov_proc + raw_tbl.unmark_ov_proc;
raw_tbl.all_act_ibc = raw_tbl.p_ibc+raw_tbl.ibc+raw_tbl.b_ibc;
raw_tbl.all_trans_ibc = raw_tbl.unmark_ibc;
raw_tbl.all_cell = raw_tbl.all_act_ibc+raw_tbl.q_pc+raw_tbl.unmark_ibc;
raw_tbl.all_q_pc = raw_tbl.q_pc + raw_tbl.unmark_ibc;
raw_tbl.frac_q_pc = raw_tbl.all_q_pc./(raw_tbl.all_cell);
raw_tbl.frac_active_ibc = raw_tbl.all_act_ibc./(raw_tbl.all_cell);
raw_tbl.frac_marked_proc = raw_tbl.ov_proc ./ (raw_tbl.ov_proc + raw_tbl.unmark_ov_proc);
raw_tbl.frac_unmarked_proc = raw_tbl.unmark_ov_proc ./ (raw_tbl.ov_proc + raw_tbl.unmark_ov_proc);
raw_tbl.frac_trans_ibc = raw_tbl.all_trans_ibc./(raw_tbl.all_cell);
raw_tbl.freq_labeled_ov_proc = raw_tbl.ov_proc./raw_tbl.all_cell;
raw_tbl.all_cell_p_mm_vl = raw_tbl.all_cell./raw_data(ix,16);
% keyboard
raw_tbl.vld_mmpmm2 = (raw_tbl.vessel_len_um/1000) ./ (raw_tbl.fov_um ./1000).^2;
raw_tbl.vess_nseg_pmm = raw_tbl.vess_nseg./ (raw_tbl.vessel_len_um/1000);
raw_tbl.bp_count_pmm = raw_tbl.bp_count./ (raw_tbl.vessel_len_um/1000);
% raw_tbl.vess_rad_um = raw_tbl.vess_rad_pix .* raw_tbl.umppix;
% raw_tbl.end_seg_rad_um = raw_tbl.end_seg_rad_pix .* raw_tbl.umppix;


bg_harv_ind = find(cellfun(@(x) strcmp(x,'bg_harv'),str_data(4,:)));
if ~isempty(bg_harv_ind)
    raw_tbl.bg_harv = raw_data(ix,bg_harv_ind);
end
 

% Denote which variables are data and which metadata
grp_vars = {'exp_num','tp','mouse_num','group_id'};
% if DATA_IS_PAIRED; grp_vars = [grp_vars {'is_lefteye'}]; end
meta_vars = {'img_name','is_lefteye','img_rename','EXCLUDE'};

% keyboard
% vars for grouping data for averaging
raw_tbl.Properties.UserData.IsGroupVar = ...
    cellfun(@(x) ismember(x,grp_vars),raw_tbl.Properties.VariableNames);

% Data vars that get averaged
raw_tbl.Properties.UserData.IsDataVar = ...
    ~cellfun(@(x) ismember(x,[grp_vars,meta_vars]),raw_tbl.Properties.VariableNames);

%  = bv; 



