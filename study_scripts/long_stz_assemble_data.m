
clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\LongTermSTZ'];
 

% base_path = regexp(curr_path,'(^.*Box Sync)','tokens','once');
xls_list{1} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_245 STZ D96 C57Bl6 IBC\blind'];
xls_list{2} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_251 STZ D96 C57Bl6 IBC\blind'];
xls_list{3} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_254 STZ D96 C57Bl6 IBC\blind'];
xls_list{4} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_258 STZ D96 C57Bl6 IBC\blind'];
xls_list{5} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_260.1 Reimage STZ D96 C57Bl6\blind'];
xls_list{6} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_260 STZ D96 C57Bl6 IBC\blind'];
xls_list{7} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_261.1 Reimage STZ D96 C57Bl6\blind'];
xls_list{8} = [base_path '\_Study Data\Study STZ D96 C57BL6\Quant Exp_261 STZ D96 C57Bl6 IBC\blind'];

if PROCESS_XMLS
    for n=1:numel(xls_list);
        ibc_compile_cell_count_xmls(xls_list{n});
    end
end


if BACKUP_DATA
    for n=1:numel(xls_list)
        ibc_backup_data([xls_list{n} '/ibc_counts.xlsx'], curr_path);
    end
end

ibc_compile_results(strcat(xls_list,'/ibc_counts.xlsx'), curr_path,6);
