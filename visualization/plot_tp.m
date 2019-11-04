function [X_grp_coords, p, signif_table,hf] = plot_tp(group_dat_table,groups_cell,DATA_IS_PAIRED, varargin)
%% ARGUMENT PARSING
% What is not an Parameter is an optinal arg (param words must fail
% validation for add optional).
p = inputParser;
p.addParameter('Y_Text', '', @ischar);
p.addParameter('Extra_Text', '', @ischar);
p.addParameter('Figure_Letter', '', @ischar);
p.addParameter('NEW_FIGURE', 1, @isnumeric);
p.addParameter('WRITE_MOUSE_NUM', 0, @isnumeric);
p.addParameter('X_Range', [1 2], @isnumeric);
p.addParameter('EXPORT_PATH', '', @ischar);
p.addParameter('Marker_Symbols', {'bo','rx'}, @iscell);
p.addParameter('Marker_Sizes', [2 2], @isnumeric);
p.addParameter('COMPUTE_STATS', 1, @(x) x==0 || x==1);
p.addParameter('ERROR_BAR_RELWIDTH',0.4,@isnumeric);
p.parse(varargin{:});
% Import parsed variables into workspace
fargs = fields(p.Results);
for n=1:numel(fargs); eval([fargs{n} '=' 'p.Results.' fargs{n} ';']);  end

% keyboard  

if NEW_FIGURE; hf = figure(); else hf = figure(gcf); end 

% Reformat data by group
% data_by_group: TP || group || mouse || data
unq_group = unique(group_dat_table(:,2));
for n = 1:numel(unq_group)
    group_n(n) = size(group_dat_table(unq_group(n)==group_dat_table(:,2),:),1);
end
% min_n = cellfun(@(x) size(x,1), data_by_group);
for n = 1:numel(unq_group)
    entries = group_dat_table(unq_group(n)==group_dat_table(:,2),:);
    data_by_group{n} = entries(1:min(group_n),:);
end


X_grp_coords = linspace(X_Range(1),X_Range(2), numel(unq_group));
for n=1:numel(unq_group)
x_cords{n} = X_grp_coords(n).*ones(size(data_by_group{n},1),1)+...
        (rand([size(data_by_group{n},1) 1])-0.5)*(diff(X_grp_coords)/6);
end

hold on
for n=1:numel(unq_group)
%     keyboard
    plot(x_cords{n},...
        data_by_group{n}(:,4),...
        [Marker_Symbols{unq_group(n)}], 'MarkerSize', Marker_Sizes(n))
end
xr = xlim; yr=ylim;
axis([min([xr(1)]) max([xr(1) X_grp_coords]) yr(1) yr(2)])
% mean(data_by_group{1}(:,4))
% mean(data_by_group{2}(:,4))

% Display mouse number for all datapoints (debugging purposes)
if WRITE_MOUSE_NUM
    %     keyboard
    for grn = 1:numel(data_by_group)
        for n= 1:size(data_by_group{grn},1)
            text(X_grp_coords(grn)-.2*(rand(1)+1),data_by_group{grn}(n,4),sprintf('%0.0f', ...
                data_by_group{grn}(n,3)),'HorizontalAlignment','center');
        end
    end
end



y = ylim;
if NEW_FIGURE; axis([0 3 y(1) y(2)+(y(2)-y(1))*0.25]); end

if ~isempty(Y_Text); ylabel([Y_Text '    ']); end
% h = errorbar(mean(rep_gr_data,1),std(rep_gr_data,1),'Linewidth',1);

if DATA_IS_PAIRED
    [h, p] = ttest(data_by_group{1}(:,4),data_by_group{2}(:,4), 'Alpha', 0.05,'Tail','both');
    
    % Connect  paired data
    for n = 1:size(data_by_group{1},1)
        plot([x_cords{1}(n) x_cords{2}(n)],[data_by_group{1}(n,4) data_by_group{2}(n,4)],'Color',[.5 .5 .5],'LineWidth', .1)
    end
    signif_table(1,1:4) = [1 2 num_sig_stars(p) p];
else
%     keyboard
    if numel(unq_group)>2
        
        for n=1:numel(unq_group)
           samples(n) = numel(data_by_group{n}(:,4));
        end
        N = min(samples);
        
        for n=1:numel(unq_group)
            data_tbl(1:N,n) = data_by_group{n}(1:N,4);
        end
        % signif_table = ind1 ind2 #star pval

        
        [p,t,stats] = anova1(data_tbl,unq_group,'off');
%         [p,t,stats] = kruskalwallis(data_tbl,unq_group,'off');
%         keyboard
        h=p<.05;
        
        str1 = sprintf('\tANNOVA[n=%s] P: %0.2E  ',num2str(stats.n),p);
        fprintf(regexprep(str1,'E-0','E-'));
        [c,m,hd,nms] = multcompare(stats,'Display','off');
        signif_table = [c(:,1:2) num_sig_stars(c(:,6)) c(:,6)];
        
%         keyboard
%         mean_by_group = cellfun(@(x) mean(x(:,4)),data_by_group)
%         keyboard
    else
        % Unpaired ttest
        [h, p] = ttest2(data_by_group{1}(:,4),data_by_group{2}(:,4), 'Alpha', 0.05,'Tail','both');
        signif_table(1,1:4) = [1 2 num_sig_stars(p) p];
    end
end

%PRint output for summarizing results,
% #TODO INCLUDE P
if ~isnan(h) && h; sig_str = 'REJ H'; else sig_str = 'ACC H'; end
fprintf('n=%s \t%s\n',...
    string(strcat(cellfun(@(x) num2str(size(x,1)),...
    data_by_group,'UniformOutput',0),',')),sig_str)
for n=1:numel(data_by_group)
    
    fprintf('\t%s::%3.3f %s %3.3f,', groups_cell{unq_group(n)},...
        mean(data_by_group{n}(:,4)),char(177),std(data_by_group{n}(:,4))/2);
    for k=1:n-1
        fprintf('\t[%.f->%.f]%.1f%%',k,n,100*(1 - mean(data_by_group{k}(:,4))./...
            mean(data_by_group{n}(:,4))))
        [~,ia,~] = intersect(signif_table(:,1:2),[k n],'rows');
        str1 = sprintf(', p= %3.2E',...
            signif_table(ia,4));
        fprintf(regexprep(str1,'E-0','E-'));
    end
    fprintf('\n')
end

% Stat test and draw paired lines
if COMPUTE_STATS && numel(unq_group)<3
    
%     
%     if ~isnan(h) && h; sig_str = 'REJ H'; else sig_str = 'ACC H'; end
%     if mean(data_by_group{2})>mean(data_by_group{1}); sign_str = '-'; 
%     else sign_str = '+'; end
    
    %     % Set Group names
    if NEW_FIGURE
    set(gca,'XTick', X_grp_coords);
    set(gca,'XTickLabel',groups_cell(unq_group));
    end
    %     keyboard
%     fprintf(['\t' sig_str ', ' groups_cell{unq_group(1)} ':%3.3f ' char(177) ' %3.3f,' ...
%         '\t' groups_cell{unq_group(2)} ':%3.3f ' char(177) ' %3.3f' ...
%         '\t'  '%.1f%%\t' 'p = %8.2E\n'], ...
%         mean(data_by_group{1}(:,4)), std(data_by_group{1}(:,4))/2,...    
%         mean(data_by_group{2}(:,4)), std(data_by_group{2}(:,4))/2,...
%         mean(data_by_group{2}(:,4))./mean(data_by_group{1}(:,4))*100-100,p);
%     

end


% Draw error bars on top of other data
for n=1:numel(unq_group)
    add_errorbar(gcf, X_grp_coords(n),data_by_group{n}(:,4), ERROR_BAR_RELWIDTH,'ABSOLUTE_WIDTH',1);
end

% keyboard
% yd = max(vertcat(data_by_group{1}(:,4),data_by_group{2}(:,4)));


% If significant, dreaw black line with star
% Draw black lines with significant table
if COMPUTE_STATS && ~isnan(h) && h;

    % data_by_group{n}: TP || group || mouse || data
    
    % Cohort: Index TP group_id xcoord
    % Signif: ind1 ind2 #stars pval
    for n=1:numel(data_by_group)
        cohort_index(n,1:4) = [1 data_by_group{n}(1,1) n X_grp_coords(n)];
    end
     
%     plot_sig_bars(cohort_index, signif_table,hf);
%     if numel(unq_group)==3; keyboard; end
end


% Resize figure, make smaller
if NEW_FIGURE
    pos = get(hf,'Position');
    set(hf,'Position', [pos(1:2) pos(3:4)./[2 1.5]])
end


if ~isempty(EXPORT_PATH)
    
    % saveas(hf,[proj_path '/out/' regexprep(ytext,'/|\\','-') '.jpg']);
    % hgexport(hf,[proj_path '/out/' regexprep(ytext,'/|\\','-')]);
    beautifyAxis(gcf);
    pos = get(gcf,'Position');
    set(gcf,'Position',[pos(1:2) 175, 200]);
    set(gcf,'color','w');
    img = getframe(gcf);
    imwrite(img.cdata, [[EXPORT_PATH '/' Extra_Text '_' Figure_Letter '_' ...
        regexprep(Y_Text,'/|\\','-')], '.png']);
end
% close(gcf);

% keyboard


end

