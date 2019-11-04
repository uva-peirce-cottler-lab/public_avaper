
clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\PDGFBB'];


% base_path = regexp(curr_path,'(^.*Box Sync)','tokens','once');
xls_list{1} = [base_path '\_Study Data\Study PDGFBB C57Bl6\Quant Exp_319.1 PDGFBB D4 L_SW R_PDGFBB 2_ug-uL 1.5_uL\blind'];
xls_list{2} = [base_path '\_Study Data\Study PDGFBB C57Bl6\Quant Exp_319.2 PDGFBB D4 L_SW R_PDGFBB 2_ug-uL 1.5_uL\blind'];
xls_list{3} = [base_path '\_Study Data\Study PDGFBB C57Bl6\Quant Exp_321 PDGFBB Inj_2uL D28 L_SW R_PDGFBB\blind'];



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

ibc_compile_results(strcat(xls_list,'/ibc_counts.xlsx'), curr_path,3);
