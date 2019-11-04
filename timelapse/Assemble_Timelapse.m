function Assemble_Timelapse()
% Scans for a series of IDS files in image directory and loads xychzt
% images, zmas projects, and assembles into a movie

% Reorder channels for RGB

Include_ScaleBar = 0;
Include_Timestamp = 0;

channel_order = [1 3 2];
rotation_angle = 0;
resize_backforth = 1/2;
imgs_path = uigetdir(pwd);
[parent_path, exp_name]=fileparts(imgs_path);

% Load frame limits if the exist
if ~isempty(dir([imgs_path '/meta.csv']))
   frame_tbl = readtable([imgs_path '/meta.csv']);
else
   frame_tbl=[]; 
end


% Scan for images
img_items =dir([imgs_path '/*.ics']);

% Parse time from filenames
elem = @(x) x{1};
raw_starts = arrayfun(@(x) elem(regexp(x.name,'^(\d*)-','tokens','once')), img_items,'UniformOutput',0);
raw_ends = arrayfun(@(x) elem(regexp(x.name,'-(\d*)\.','tokens','once')), img_items,'UniformOutput',0);
% Convert base 60 for hour to base 100 decimal time (count hours on base 10
% scale)
dec_start_times = cellfun(@(x) 60*str2double(x(1:numel(x)-2)) + str2double(x(end-1:end)),raw_starts);
dec_end_times = cellfun(@(x) 60*str2double(x(1:numel(x)-2)) + str2double(x(end-1:end)),raw_ends);
start_times = dec_start_times-dec_start_times(1);
end_times = dec_end_times - dec_start_times(1);


% Delte AVI and TIFF from previous export if exist
if ~isempty(dir([imgs_path '_timelapse.tif'])); delete([imgs_path '_timelapse.tif']); end
if ~isempty(dir([imgs_path '_timelapse.avi'])); delete([imgs_path '_timelapse.avi']); end

% img_time_str = cellfun(@(x) regexp(x,'.*-(\d*)_','tokens','once'), img_names,'uniformoutput', 0);
% img_time = cellfun(@(x) str2double(x), img_time_str);
% [~, ix] = sort(img_time,'ascend');


% Preallocate movie structure.
v = VideoWriter([imgs_path '_timelapse.avi']);
v.FrameRate=1;
open(v)

def_img_dim = [1024 1024];
acquire_time=0;
ntp = 1;
hw = waitbar(0,'Processing Images');
for n = 1:numel(img_items)
    
    % Load time zstack
    [xyczt_img, meta] = img_open([imgs_path '/' img_items(n).name]);
    fprintf('%s\n',img_items(n).name);
    
   
    [nr, nc, nch, nz, nt] = size(xyczt_img);
 
    % Estimate frame
    time_per_frame = (end_times(n) - start_times(n))/nt;
    
    % Z project, max intensity
    xyct = squeeze(max(xyczt_img(:,:,:,:,:),[],4));
    xyct = xyct(:,:,channel_order,:);
    
    
    for t = 1:nt
        fprintf('\tTP: %.f\n', t);
        
        % Skip if empty image
        if sum(xyct(:))==0; %keyboard; 
            acquire_time = acquire_time + meta.dt;continue; end
        
        % Timestamp
        time_str = ['Time(Min): ' num2str(start_times(n) + t*time_per_frame)];
        
        % Create rgb and sole channel image
        im = [xyct(:,:,:,t)]; % temp_xyct];

        % Resize image initally, then for target size of output
        im_bf = imresize(imresize(im,resize_backforth),1/resize_backforth);
        im = imrotate(imresize(im_bf, def_img_dim),rotation_angle);
        
        % Create the text mask
        sbar = round(nr/meta.fov_um_x * 100);
        sbar_height = 50;
        % Make an image the same size and put text in it
        hf = figure('color','white','units','normalized','position',...
            [.1 .1 .8 .8],'Visible','Off');
        %     image(ones(size(im)));
        set(gca,'units','pixels','position',[5 5 size(im,2)-1 size(im,1)-1],...
            'visible','off')
        % Text at arbitrary position
        if Include_Timestamp
        text('units','pixels','position',[10 30],'fontsize',18,'string',...
            time_str,'FontWeight','bold')
        end
        % Label for scale bar on bottom right of image
        movegui(gcf)
        img_temp = getframe(gcf);
        if Include_ScaleBar
            text('units','pixels','position',...
                [size(img_temp.cdata,2)-sbar+25 sbar_height+10],'fontsize',14,...
                'string','100','FontWeight','bold')
        end
        
        % Capture the text image
        % Note that the size will have changed by about 1 pixel
        tim = getframe(gcf);
        close(hf)
        % Make a mask with the negative of the text
        tmask = sum(tim.cdata,3)>0;
        tmask = imresize(tmask,[size(im,1) size(im,2)]);
       
        % Place Scale Bar bottom right
        if Include_ScaleBar
            tmask(end-50:end-40,end-(25+sbar):end-25,:) = 0;
        end 
        
        % Place white text
        % Replace mask pixels with UINT8 max
        % Apply mask to the image
        im(cat(3,~tmask,~tmask,~tmask)) = intmax(class(im));
        
        
        rgb=im;

        % Write image and video out only if within specified time range
        % found in meta.csv
        if isempty(frame_tbl) || (ntp>=frame_tbl.start_frame && ntp<=frame_tbl.end_frame)
            imwrite(rgb,[imgs_path '_timelapse.tif'],'WriteMode', 'append', 'Compression','none');
            writeVideo(v,rgb);
        end
        
        % Increment timepoint and time counter
        ntp = ntp+1;
        acquire_time = acquire_time + meta.dt;
    end
    % Increment waitbar
    waitbar(n/numel(img_items),hw)
end
close(hw);
close(v);







