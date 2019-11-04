
img_path = uigetdir('sellect img directory');

img_items = dir([img_path '/*.*']);
img_names = {img_items(3:end).name};

img_names(cellfun(@(x) isempty(regexp(x,'(.ids)|(.ics)','once')),img_names))=[];

for n=1:numel(img_names)
    if ~isempty(dir([img_path '/' regexprep(img_names{n},'C','I')])); continue; end
   movefile([img_path '/' img_names{n}],[img_path '/' regexprep(img_names{n},'C','I')]) 
   fprintf('.')
   pause(0.1)
end





return


img_index = randperm(numel(img_items))';

img_names = {img_items(:).name}';

img_renames = strcat(cellstr(num2str(img_index)),{'.tiff'});

mkdir([img_path '/blind']);

for n = 1:numel(img_names)
    fprintf(' %s  to  %s\n', img_names{n}, img_renames{n});
    copyfile( [img_path '/' img_names{n}], [img_path '/blind/' img_renames{n}])
    
end


fid = fopen([img_path '/rename log.csv'],'w');
for n = 1:numel(img_names)
    fprintf(fid,'%s,%s\n',img_renames{n},img_names{n}(1:9));
end
fclose(fid);

csvwrite([img_path '/rename log.csv'],horzcat(img_renames,img_names))
