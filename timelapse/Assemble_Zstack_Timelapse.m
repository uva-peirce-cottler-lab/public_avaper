

imgs_path = uigetdir(pwd);

[parent_path, exp_name]=fileparts(imgs_path);


img_items =dir([imgs_path '/*.ics']);

if ~isempty(dir([imgs_path '.tif'])); delete([imgs_path '.tif']); end


img_names = {img_items(:).name};

img_time_str = cellfun(@(x) regexp(x,'.*-(\d*)_','tokens','once'), img_names,'uniformoutput', 0);
img_time = cellfun(@(x) str2double(x), img_time_str);
[~, ix] = sort(img_time,'ascend');

hw = waitbar(0,'Processing Images');
for n = 1:numel(img_items)
    
    [zimg, meta] =img_open([imgs_path '/' img_items(ix(n)).name]);
    
%     [nr, nc, nch, nz] = size(zimg);
    
    %Flatten
    img = squeeze(max(zimg,[],4));
    
    % Threshold Image
    img(img < 50) = 0;
    img(img > 240) = 240;
    
    % Some images were taken at wrong resolution, would not be issue for
    % any software supported with timelapse
    im = imresize(imadjust(img(:,:,2)), [1024 1024]);
    
    % Parse time of each image from image name
    time_str{n} = regexp(img_items(ix(n)).name,'.*-(\d*)_','tokens','once');
    formatted_time_str = time_str{n}{1}; 
    formatted_time_str = [formatted_time_str(1:end-2) ':' formatted_time_str(end-1:end)];
    
    %open first image
    %% Create the text mask
     sbar = round(size(im,2)/meta.fov_um_x * 100);
    % Make an image the same size and put text in it
    hf = figure('color','white','units','normalized','position',[.1 .1 .8 .8],'Visible','Off');
%     image(ones(size(im)));
    set(gca,'units','pixels','position',[5 5 size(im,2)-1 size(im,1)-1],'visible','off')
    % Text at arbitrary position
    text('units','pixels','position',[10 30],'fontsize',30,'string',formatted_time_str,'FontWeight','bold')
    
    text('units','pixels','position',[size(im,2)-(sbar/2+25+20) 20],'fontsize',20,'string','100','FontWeight','bold')
    
    % Capture the text image
    % Note that the size will have changed by about 1 pixel
    tim = getframe(gca);
    close(hf)
    % Make a mask with the negative of the text
    tmask = sum(tim.cdata,3)>0;
    tmask = imresize(tmask,[1024 1024]);
    %Write flatten img
    % Scale 127/2 =
    tmask(end-50:end-40,end-(25+sbar):end-25,:) = 0;
%     imshow(tmask);

    % Place white text
    % Replace mask pixels with UINT8 max
    im(~tmask) = intmax(class(zimg));
    
    rgb = cat(3,im,uint16(~tmask)*intmax(class(zimg)),uint16(~tmask)*intmax(class(zimg)));
    
%     keyboard
    imwrite(imresize(rgb, [1024 1024]),[imgs_path '.tif'],'WriteMode', 'append', 'Compression','none');
    waitbar(n/numel(img_items),hw)
end
close(hw);




