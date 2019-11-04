
img_path = 'C:\Users\bac\Documents\Exp_300 C57Bl6 RetroOLectin Various Tissues';
  items = dir([img_path '/*.ids']);
   img_names = {items(:).name};

   mkdir([img_path '/zmax/'])

for n = 1:numel(img_names)
    fprintf('%s\n',img_names{n});
      [raw_xychz_img, img_meta] = img_open([img_path '/' img_names{n}]);
        xych_img = max(raw_xychz_img,[],4);
      img_write(imadjust(xych_img(:,:,end)), ...
          [img_path '/zmax/' img_names{n} '.jpg'], ...
          img_meta.fov_um_x./size(raw_xychz_img));
      
end