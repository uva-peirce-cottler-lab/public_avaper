new_min_mouse_num = 3;

% Scan for all images

% Select path
img_dir_path =  uigetdir('select img directory');

% Detect Images
items = dir([img_dir_path '/*.*']);
item_names = {items(:).name};
img_names = item_names(cellfun(@(x) ~isempty(...
    regexp(x,'(\.lsm)|(\.ids)|(\.ics)','once')),item_names));


%Extract mouse number/// and rest of strong
temp = cellfun(@(x) regexp(x,'^(\d*)(.*)','tokens','once'),img_names,'uniformoutput',0);

mouse_num = cellfun(@(x) str2double(x{1}),temp);
img_postfix = cellfun(@(x) x{2},temp,'uniformoutput',0);


mkdir([img_dir_path '/mouse_rename/'])
%Reassign mouse number from starting #
for n = 1:numel(img_names)
    fprintf('%s to %s\n', img_names{n},[img_dir_path '/mouse_rename/' ...
       num2str(new_min_mouse_num+mouse_num(n)-1) img_postfix{n}]);
   copyfile([img_dir_path '/' img_names{n}],[img_dir_path '/mouse_rename/' ...
       num2str(new_min_mouse_num+mouse_num(n)-1) img_postfix{n}]);
    
end
