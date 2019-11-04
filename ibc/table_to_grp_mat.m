function grp_mat = table_to_grp_mat(tbl, var_name)
%UNTITLED Summary of this function goes here

% keyboard

grp_mat = [tbl.tp tbl.group_id tbl.mouse_num tbl.(var_name)];

end

