
clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\Akita'];

xls_list{1} = [base_path '\_Study Data\Study Akita 8Mo\Quant Exp_250 Akita Wt D224 IBC\blind'];
xls_list{2} = [base_path '\_Study Data\Study Akita 8Mo\Quant Exp_262 Akita Wt D224 IBC\blind'];

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

ibc_compile_results(strcat(xls_list,'/ibc_counts.xlsx'), curr_path,5);
