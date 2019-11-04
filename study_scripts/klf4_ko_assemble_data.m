
clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\Myh11YFP KLF4-KO'];


% base_path = regexp(curr_path,'(^.*Box Sync)','tokens','once');
xls_list{1} = [base_path '\_Study Data\Study KLF4 KO Lam\Quant Exp_307.2 Myh11YFP-KLF4-KO BL_aGFP RD_CD31-105 Gr_Lam\blind'];
xls_list{2} = [base_path '\_Study Data\Study KLF4 KO Lam\Quant Exp_309.2 Myh11YFP-KLF4-KO BL_aGFP RD_CD31-105 Gr_Lam\blind'];
xls_list{3} = [base_path '\_Study Data\Study KLF4 KO Lam\Quant Exp_311.2 Myh11YFP-KLF4-KO BL_aGFP RD_CD31-105 Gr_Lam\blind'];
xls_list{4} = [base_path '\_Study Data\Study KLF4 KO Lam\Quant Exp_315 Myh11YFP-KLF4-KO BL_aGFP RD_CD31-105 Gr_Lam\blind'];


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

ibc_compile_results(strcat(xls_list,'/ibc_counts.xlsx'), curr_path,4);
