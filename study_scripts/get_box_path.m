function [box_path] = get_box_path()
proj_path = getappdata(0,'proj_path');
mkdir([proj_path '/temp/']);

if isempty(dir([proj_path '/temp/box_path.mat']))
    box_path = uigetdir('Select Box Folder');
    if box_path==0; return; end
    save([proj_path '/temp/box_path.mat'],'box_path');
else
    load([proj_path '/temp/box_path.mat']);
    if box_path==0; 
        box_path = uigetdir('Select Box Folder');
        if box_path==0; return; end
        save([proj_path '/temp/box_path.mat'],'box_path');
    end
%     if ~
end
end

