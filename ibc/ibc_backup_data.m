function ibc_backup_data(xls_path, out_path)
%IBC_BACKUP_DATA Summary of this function goes here
%   Detailed explanation goes here


% For each path to an excel file
% 1 Zip all xml, csv, mat, xlsx files
% Create temp zip archive
% Compare to latest zip archive
% If not different delete
% If it is, ass timestamp to name
% keyboard
% Get Exp Num
[raw_tbl, eval_str] = ibc_xls_to_table(xls_path);
exp_str = regexprep(num2str(unique(raw_tbl.exp_num)),'\s',',');
% Get timestamp
c = clock;
date_str = regexprep(num2str(c(1:3)),'\t*|\s*','_');

in_dir = fileparts(xls_path);

if isempty(dir([out_path '/data_backup/']));
    mkdir([out_path '/data_backup/']);
end

zip([out_path '/data_backup/Exp_' exp_str '_Backup_' date_str '.zip'],...
    {[in_dir '/*.xml'], [in_dir '/*.mat'],...
    [in_dir '/*.csv'], [in_dir '/*.xlsx']});



