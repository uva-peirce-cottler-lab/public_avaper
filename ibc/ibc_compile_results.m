function [avg_tbl raw_tbl] = ibc_compile_data(xls_list, out_path, NUM_REPLICATES)

% Thresholds, above this # (worse) gets filtered out
IMAGE_QUALITY_THRESHOLD = 10;
TISSUE_QUALITY_THRESHOLD = 10;
WRITE_MOUSE_NUM = 0;
FOV_ARE_AVERAGED = 1;
PLOT_INDIVIDUAL_TP=0;
CLEAR_PREVIOUS_RESULTS=1;

if CLEAR_PREVIOUS_RESULTS
%     keyboard
    prev_tifs = dir([out_path '/*.tif']);
    prev_pngs = dir([out_path '/*.png']);
    prev_results_names = [{prev_tifs(:).name} {prev_pngs(:).name}];
    deletion_names = prev_results_names;
    for n=1:numel(deletion_names)
       delete([out_path '/' deletion_names{n}]);
    end
end

if ~exist('xls_list','var')
    init_path = 'C:\Users\bac\Box Sync\11. IBC\_Study Data\Results';
    [xls_name,xls_dir_path ] = uigetfile([init_path '/*.xlsx'],'Select XLS file');
    if xls_name==0; return; end
    xls_list{1} = [xls_dir_path '/' xls_name];
    out_path=xls_dir_path;
end


for n=1:numel(xls_list)
    [raw_tbl_cell{n}, eval_str] = ibc_xls_to_table(xls_list{n});
    eval(eval_str);
    % Number of replicates
%     if DATA_IS_PAIRED && ~exist('NUM_REPLICATES','var'); NUM_REPLICATES=4; else; NUM_REPLICATES=6; end
end
raw_tbl=vertcat(raw_tbl_cell{:});
% keyboard


% Keep entries that are <= QC thresholds, or exluded image
ix1 = raw_tbl.img_qual <= IMAGE_QUALITY_THRESHOLD;
ix2 = raw_tbl.tiss_qual <= TISSUE_QUALITY_THRESHOLD;
ix3 = raw_tbl.EXCLUDE;  %ix3(:)=0;
% keyboard
culled_tbl=raw_tbl;
culled_tbl(~(ix1 & ix2 & ~ix3),:)=[];
fprintf('# Of image pass QCimg: %0.0f/%0.0f, QC_tiss: %0.0f/%0.0f\n',...
    sum(ix1),numel(ix1),sum(ix2),numel(ix2));
% keyboard

% Get timepoints
tp = raw_tbl.tp(ix1 & ix2 & ~ix3);
tps = unique(tp)';


% Export full table
writetable(culled_tbl,[out_path '/_image_metrics.csv']);


cell_vars = {'q_pc', 'p_ibc','ibc','b_ibc','ov_proc','unmark_ov_proc',...
    'unmark_ibc','img_qual','all_ov_proc','all_act_ibc','all_trans_ibc',...
    'all_cell','all_q_pc','frac_q_pc','frac_active_ibc','frac_marked_proc',...
    'frac_unmarked_proc','frac_trans_ibc','freq_labeled_ov_proc','bg_harv','A1C','wgt_harv'};
[Lia,Locb] = ismember(culled_tbl.Properties.VariableNames, cell_vars);
[avg_cell_tbl, cell_score] = grpmean(culled_tbl, raw_tbl.Properties.UserData.IsGroupVar, ...
    Lia,NUM_REPLICATES, culled_tbl.img_qual, DATA_IS_PAIRED, @(x,y) ...
    x); % culled_tbl.img_qual prioritize_image_selection_pc(x,y)
% keyboard
vld_vars = {'tiss_qual','vessel_len_um','bp_count','vess_nseg','vess_tort',...
    'vess_diam_um','end_vess_diam_um','cont_vess_diam_um', 'all_cell_p_mm_vl',...
    'vld_mmpmm2','vess_nseg_pmm','bp_count_pmm'};
[Lia,Locb] = ismember(culled_tbl.Properties.VariableNames, vld_vars);
[avg_vess_tbl, vld_score] = grpmean(culled_tbl, raw_tbl.Properties.UserData.IsGroupVar, ...
    Lia,NUM_REPLICATES,culled_tbl.tiss_qual, DATA_IS_PAIRED, ... %culled_tbl.vld_mmpmm2 culled_tbl.tiss_qual
    @(x,y) x);%prioritize_image_selection_vld(x,y));
% Combine cell and vld tables
culled_tbl.tiss_qual = vld_score;
writetable(culled_tbl,[out_path '/_edit_avg_img_metrics.csv']);
avg_tbl = combine_table_columns(avg_cell_tbl,avg_vess_tbl);
% keyboard

% Export table to file
writetable(avg_tbl,[out_path '/_avg_img_metrics.csv']);

% Grp table
% TP, group_id, exp_num, mouse_num
label_st.frac_active_ibc = ['PCb Frac. of ' cell_marker '+ PCs'];
label_st.frac_trans_ibc = ['   bbPC Frac. of ' cell_marker '+ PCs'];
label_st.frac_q_pc = ['aPC Frac. of ' cell_marker '+ PCs'];
label_st.all_cell = [cell_marker '+ PCs/ FOV'];
label_st.frac_marked_proc = ['     Frac. of ' cell_marker '+ Col-IV Bridges'];
label_st.ov_proc = [cell_marker '+ Bridges/ FOV'];
label_st.all_ov_proc = 'Col-IV+ Bridges/ FOV';
label_st.vld_mmpmm2 = 'VLD (mm/mm2)';
label_st.bp_count_pmm = 'Bp/ Vess Length (mm)';
% % label_st.vess_nseg_pmm = 'Seg./ Vess. Length (mm)';
label_st.vess_tort = 'Segment Tortuosity';
label_st.vess_diam_um = 'Vessel Diam. (um)';
% % label_st.end_vess_diam_um = 'End Vess. Diam. (um)';

if ismember('bg_harv',avg_tbl.Properties.VariableNames);
    label_st.A1C='HbA1c (%)';
end
if ismember('wgt_harv',avg_tbl.Properties.VariableNames);
    label_st.wgt_harv='Weight (g)';
end

% Record results
if ~isempty(dir([out_path '/results_output.txt']));
    delete([out_path '/results_output.txt']); 
end
diary([out_path '/results_output.txt'])
diary on
plot_varnames = fields(label_st);
for n = 1:numel(plot_varnames)
    % CPmvert table for group matrix, with cloumns as: 
    % tp group_id mouse_num variable
    grp_mat = table_to_grp_mat(avg_tbl, plot_varnames{n});
    
    hf = plot_timecouse(grp_mat, group_names,...
        DATA_IS_PAIRED, 'Y_Text', label_st.(plot_varnames{n}),'X_Text',x_axis_label, ...
        'Extra_Text', ['Days_' regexprep(num2str(tps),'\t|(\s)*',',') '_' plot_varnames{n}],...
        'Figure_Letter',char(64+n),'Export_Path',out_path, ...
        'INCLUDE_LEGEND', 0,'CROSS_TP_STATS',0); %DATA_IS_PAIRED && numel(unique(avg_tbl.tp)==2));
%     keyboard
    close(hf);
end
% keyboard
if ismember('bg_harv',avg_tbl.Properties.VariableNames)
    %     keyboard
    
    %     figure;
    
    %     % For each study group and timepoint, plot all data and fit line
    %     unq_group_num = unique(avg_tbl.group_num);
    %     for n=1:numel(unq_group_num)
    %         bv = avg_tbl.group_num==unq_group_num(n);
    %
    %         plot(avg_tbl.bg_harv(bv), avg_tbl.frac_active_ibc(bv),'.')
    %         hold on
    %
    %         [rho,pval] = corr(avg_tbl.bg_harv(bv), avg_tbl.frac_active_ibc(bv));
    %         fprintf('GR: %s, R=%.4f, p=%.4e\n',...
    %             group_names{unq_group_num(n)},rho,pval);
    %     end
    corr_vars = {'frac_active_ibc','frac_trans_ibc','ov_proc','all_ov_proc'};
    for n = 1:numel(corr_vars)
        % Plot correlation between BG and active IBCs
        plot(avg_tbl.A1C, avg_tbl.(corr_vars{n}),'k.','MarkerSize',5);hold on;
        % Calculate Pearson Correlation
        [rho,pval] = corr(avg_tbl.A1C, avg_tbl.(corr_vars{n}));
        fprintf([corr_vars{n} ': R=%.2f, p=%.1e\n'],rho,pval)
        % Calculate best fit line
        coeffs = polyfit(avg_tbl.A1C, avg_tbl.(corr_vars{n}), 1);
        % Get fitted values
        fittedX = linspace(min(avg_tbl.A1C), max(avg_tbl.A1C), 200);
        fittedY = polyval(coeffs, fittedX);
        % Plot the fitted line
        plot(fittedX, fittedY, '-', 'LineWidth', 0.75,'Color', [.5 .5 .5]);
        ya = ylim; 
        plot(([601 601] + 46.7)/28.7,ylim,'--','Color', [.5 .5 .5]);
        hold off
        % Formatting
        ylabel([strtrim(label_st.(corr_vars{n})) '   '])
%         keyboard
        xlabel('HbA1c (%)')
        beautifyAxis(gca);
        set(gca, 'FontSize', 7.5);
        set([get(gca,'XLabel'), get(gca,'YLabel')], 'FontSize', 8.2);
        set(gca,'XMinorTick'  , 'off');
        pos = get(gcf,'Position');
        set(gcf,'Position',[pos(1:2) 165, 150]);
        set(gcf,'color','w');
        saveas(gcf,[out_path '/1_' regexprep(label_st.(corr_vars{n}),'/','p-') '.png']);
    end
%     keyboard
    close(gcf);
end

% keyboard
% 
% culled_tbl.tiss_qual = vld_score;
% culled_tbl.img_qual = cell_score;
% culled_tbl = readtable([out_path '/ibc_metrics.csv']);

diary off

end




