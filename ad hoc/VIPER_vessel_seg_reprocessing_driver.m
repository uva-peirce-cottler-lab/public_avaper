
img_dir_paths_cell{1} = 'C:\Users\bac\Box Sync\_Study Data\Study Akita 8Mo\Quant Exp_250 Akita Wt D224 IBC\blind';
img_dir_paths_cell{2} = 'C:\Users\bac\Box Sync\_Study Data\Study Akita 8Mo\Quant Exp_262 Akita Wt D224 IBC\blind';

%  for n=1:numel(img_dir_paths_cell)
%         ibc_backup_data([img_dir_paths_cell{n} '/ibc_counts.xlsx'], curr_path);
%  end
    
for n=1:numel(img_dir_paths_cell)
    VIPER_vessel_seg_reprocessing(img_dir_paths_cell{n})
end