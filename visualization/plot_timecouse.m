function [hf, signif_table] = plot_timecouse(data_table,...
    groups_cell,DATA_IS_PAIRED, varargin)
%% ARGUMENT PARSING
% What is not an Parameter is an optinal arg (param words must fail
% validation for add optional).'Days Post STZ Inj.'
p = inputParser;
p.addParameter('Y_Text', '', @ischar);
p.addParameter('X_Text','',@ischar);
p.addParameter('Extra_Text', '', @ischar);
p.addParameter('Figure_Letter', '', @(x) ischar(x) || x==0);
p.addParameter('X_Axis_Pad', .2, @ischar);
p.addParameter('EXPORT_PATH','',@ischar);
p.addParameter('INCLUDE_LEGEND',0,@(x) islogical(x) | isnumeric(x));
p.addParameter('CROSS_TP_STATS',0,@(x) isnumeric(x) || islogical(x));
p.addParameter('Marker_Symbols',{'bo','rd','gs'},@iscellstr);
p.addParameter('Marker_Sizes',[2 2 3],@isnumeric);
p.addParameter('DRAW_GROUP_LINE',1,@(x) islogical(x) | isnumeric(x));
p.addParameter('ERROR_BAR_RELWIDTH',0.2,@isnumeric);

p.parse(varargin{:});
% Import parsed variables into workspace
fargs = fields(p.Results);
for n=1:numel(fargs); eval([fargs{n} '=' 'p.Results.' fargs{n} ';']);  end

unq_tp = unique(data_table(:,1));
unq_group = unique(data_table(:,2));

% If only 1 tp, smaller error bar width
if numel(unq_tp==1); ERROR_BAR_RELWIDTH=.05; end


hf = figure();
hold on;
x_ctr = [1 1.5];
sp=0.1;
x_ind=[x_ctr(1)-sp x_ctr(1)+sp; x_ctr(2)-sp x_ctr(2)+sp];
% Plot each series of group per timepoint
signif_table = [];
kk=1; n_prev=0;
for tp_ind = 1:numel(unq_tp) 
    % Print timepoint
    ix = data_table(:,1)==unq_tp(tp_ind);
    n_groups_per_tp = numel(unique(data_table(ix,2)));
    
    fprintf('\n\n%s, TP: %.0f: \n',strtrim(Y_Text), unq_tp(tp_ind));
    
    [x_coords, p_sig, tp_signif_table, hf] = plot_tp(data_table(ix,:),groups_cell,DATA_IS_PAIRED,'X_Range', ...
        [x_ind(tp_ind,1) x_ind(tp_ind,2)],'Marker_Symbols',Marker_Symbols,...
        'NEW_FIGURE',0,'EXPORT_PATH','','COMPUTE_STATS', ~CROSS_TP_STATS,...
        'Extra_Text', Extra_Text, 'Y_Text', Y_Text,...
        'Marker_Sizes',Marker_Sizes,'ERROR_BAR_RELWIDTH',ERROR_BAR_RELWIDTH);
    
    % Index TP group xcoord
    for n=1:n_groups_per_tp
       cohort_index(kk+n-1,1:4) = [kk+n-1 unq_tp(tp_ind) unq_group(n) x_coords(n)];    
    end
    kk=kk+n_groups_per_tp;
    
    % Cohort_index Cohort_index number of stars
    signif_table = vertcat(signif_table,tp_signif_table + ...
        repmat([n_prev n_prev 0 0], [size(tp_signif_table,1) 1]));
    n_prev = n_prev+numel(unique(data_table(ix,2)));
    % Signif_table: group1 group2 numstrars p_val
%     signif_table(tp_ind,:) = [kk kk+1 num_sig_stars(p_sig) p_sig];
%     keyboard
    
    max_y(tp_ind) = max(data_table(ix,3));
    min_y(tp_ind) = min(data_table(ix,3));
    %     pause();
    
%     keyboard
end 


plot_sig_bars(cohort_index, signif_table,gca);
% keyboard

% Reposition x axis
xr=xlim; yr=ylim;
children = get(gca,'children');

if strcmp(Y_Text,'bbPC Frac. of NG2+ Cells')
   keyboard 
end
% Readjust axis across all timepoints
for n=1:numel(children)
%     get(children(n))
    if isprop(children(n), 'XData')
        xmin_objs(n) = min(get(children(n),'XData'));
        xmax_objs(n) = max(get(children(n),'XData'));
    else
        xmin_objs(n)=NaN;
        xmax_objs(n)=NaN;
    end
    
end
xmin = min(xmin_objs);
xmax = max(xmax_objs);
axis([xmin-.10*(xmax-xmin) xmax+0.10*(xmax-xmin) yr])


ylabel([Y_Text '       ']);
beautifyAxis(gca);
set(gca, 'FontSize', 7.5);
set([get(gca,'XLabel'), get(gca,'YLabel')], 'FontSize', 8.2);
set(gca,'XMinorTick'  , 'off');
xticks(x_ctr);

if INCLUDE_LEGEND
    [h,icons,plots,legend_text]  = legend(groups_cell);
    set(plots(2),'Marker','d');
    set(plots(2),'MarkerEdgeColor','r');
    set(plots(3),'Marker','s');
    set(plots(3),'MarkerEdgeColor','g');
end

%Add letter for figure
if ~Figure_Letter
    y=ylim; yd = max(data_table(:,3));
    text(1.3,y(2)-abs(diff(y))/30,Figure_Letter,'HorizontalAlignment',...
        'right','FontSize',15,'Fontweight','bold');
end

% Get x axis ticks
% keyboard

if numel(unq_tp)==1;
    xa = xlim;  
    xticks(xa(1,1) + diff(xa(1,:)) * (1:numel(unq_group)-1)./numel(unq_group))
    
    xticklabels([]);
    
%    x_ind(1,1)+ xd * 1/3
%     numel(unq_group)
%     xticklabels(groups_cell)
else
    xticklabels([]);
    xticks(mean(x_ind(:)))
%      pos = get(gcf,'Position');
%     set(gcf,'Position',[pos(1:2) 165, 150]);
% %     xticklabels([]);
%     ha=gca;
% %     vec_pos = get(get(gca, 'XLabel'), 'Position');
%     xticks(mean(x_ind(:)))
%     ha.XAxis.FontSize=30;
%     xticklabels('')
%     
%     text(mean(x_ind(1,:)),.035,num2str(unq_tp(1)),'FontName', ...
%     'Ariel','FontSize',8,'HorizontalAlignment','center');
%     h=text(mean(x_ind(2,:)),.035,num2str(unq_tp(2)),'FontName', ...
%     'Ariel','FontSize',8,'HorizontalAlignment','center');
%     
%     h=text(vec_pos(1),.01,X_Text,'FontName', ...
%     'Ariel','FontSize',8.5,'HorizontalAlignment','center');
% %     xticklabels(arrayfun(@(x) sprintf('%i',x),unq_tp,'UniformOutput',0))
% %     xticks([])
% %     pos = get(gca,'position')
% %     line(
   
    
    
end

xr=xlim;
% xticks([diff(xr)/2+xr(1)])



% Draw line to top of ticklabels half way in between them
% xtl = get(gca,'xticklabel');

% if single timepoint, change xtick to groups
% if numel(unq_tp)==1 ;
%     set(gca,'XTick',[]);
%     set(gca,'XTickLabel',[]);
% end

% draw a thick grouping line on x axis for all groups in each tp
% if DRAW_GROUP_LINE
% for n=1:numel(unq_tp)
%    hline = line(x_ind(n,1:2),[min(ylim) min(ylim)],'Color', [0 0 0],'Linewidth',2);
% %    alpha(hline,.5);
% end
% end
% keyboard
% Export figure as image file
if ~isempty(EXPORT_PATH)
    pos = get(gcf,'Position');
    set(gcf,'Position',[pos(1:2) 165, 135]);
%     keyboard
    
    set(gcf,'color','w');
    saveas(gcf,[EXPORT_PATH '/' Figure_Letter '_' ...
        regexprep(Y_Text,'/|\\','-') '.tif']);
end


% if strcmp(Figure_Letter,'G'); keyboard; end
end