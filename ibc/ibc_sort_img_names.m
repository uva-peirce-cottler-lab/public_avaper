
% img_path = uigetdir('sellect img directory');
img_path = 'C:\Users\bac\Box Sync\11. IBC\Exp_245 3Mo STZ';
img_items = dir([img_path '/*.ids']);
img_names = {img_items(:).name};
mouse_num = cellfun(@(x) str2double(regexp(x,'^(\d*)','tokens','once')),img_names,'UniformOutput',1);
LReye = cellfun(@(x) ~isempty(regexp(x,'\d*R','once')),img_names,'UniformOutput',1);
img_num = cellfun(@(x) str2double(regexp(x,'I(\d*)\.','tokens','once')),...
    img_names,'UniformOutput',1);

sorted_img_names = nested_sort([mouse_num' LReye' img_num'], img_names);

f = fopen('img_include.csv','w');
fprintf(f,'img_name,INCLUDE,\n');
for n=1:numel(sorted_img_names)
    fprintf(f, '%s,\n',sorted_img_names{n});
end
fclose(f);

% Sort by mouse, and then by img_num and LR
[sorted_mouse_num,ix_mouse]=sort(mouse_num);
mousesort_img_names=img_names(ix_mouse);

% Left: 0, Right: 1



unq_mouse_num = unique(mouse_num);


ix_imgs=ix_mouse;



% Sort by L and R, and by img #
elem=@(x,y) x(y);
for n=1:numel(unq_mouse_num)
    bv_mouse = unq_mouse_num(n)==sorted_mouse_num;
    
    current_img_nums = img_num(bv_mouse);
    current_LR = LReye(bv_mouse);
    
    unq_LR = unique(current_LR);
    
    [~,ix1] = sort(current_LR);
    
    for k = 1:numel(unq_LR)
        bv_eye = unq_LR == current_LR;
        [~, ix2] = sort(current_img_nums(ix1));
        ix_imgs(bv2)=elem(ix_imgs(bv2),ix2);
    end
end

img_names(ix_imgs)


% % Sort by L and R, and by img #
% elem=@(x,y) x(y);
% for n=1:numel(unq_mouse_num)
%     bv = unq_mouse_num(n)==sorted_mouse_num;
%     current_img_nums = img_num(bv);
%     current_LR = LReye(bv);
%     
%     
%     [~, ix2] = sort(current_img_nums);
%     ix_imgs(bv)=elem(ix_imgs(bv),ix2);
% 
% end
% 
% img_names(ix_imgs)