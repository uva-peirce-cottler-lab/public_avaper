
clear all
clc

PROCESS_XMLS=0;
BACKUP_DATA=0;

% Get input and output directories
[base_path] = get_box_path();
curr_path = [base_path '\_Study Data\Results\Ang2'];

xls_list{1} = [base_path '\_Study Data\Study Ang2 C57Bl6\Quant Exp_237 C67Bl7 Ang2 D4 IBC\blind'];
xls_list{2} = [base_path '\_Study Data\Study Ang2 C57Bl6\Quant Exp_246 Ang2 D28 C57Bl6\blind'];
xls_list{3} = [base_path '\_Study Data\Study Ang2 C57Bl6\Quant Exp_320 Ang2Inj C57Bl6 D28 L_PBS R_1ug-uLAng2\blind'];

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
