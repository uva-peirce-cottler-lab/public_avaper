function [ output_args ] = plot_sig_bars(cohort_index, signif_table,hf)
%PLOT_SIG_BARS Summary of this function goes here
%   cohort_index: [table columns]: % Index tP group xcoord
%   signif_table: [signif_table]: cohort_index cohort_index num_stars p_val
% keyboard
% get all data points from graph, find max data point
children = get(gca,'Children');

%Filter Children
if numel(children)>20
%     keyboard
end 
for n=1:numel(children);

   child = get(children(n));
  all_one_x_bv(n)=0;
  
  if isfield(child, 'XData')
    all_one_x_bv(n) = numel(unique(get(children(n), 'XData')))==1;
    more_one_pt(n) =  numel(get(children(n), 'XData'))>1;
  end

end

bv = all_one_x_bv & more_one_pt; 
% data_by_group = getappdata(hf,'data_by_group');

% Get min and may y values
ix = arrayfun(@(x) strcmp(x.Type,'line'),children,'UniformOutput',1);
max_y = max(arrayfun(@(x) max(x.YData),children(ix),'UniformOutput',1));
min_y = min(arrayfun(@(x) min(x.YData),children(ix),'UniformOutput',1));
% keyboard
axis([xlim min_y-(max_y-min_y)/10 max_y+(max_y-min_y)/5]);


% Print text to get height
 ht=text(1,1,'*','HorizontalAlignment','center','FontSize',8,'Fontweight','bold');
ext = get(ht,'extent');
lvl_height = ext(4)*2;
delete(ht);

%increase hiehgt of graph split into 4 levels
nlvls = max([sum(signif_table(:,3)>0) 1]);  %size(signif_table,1);
% lvl_height = (max_y-min_y)/2/(nlvls+1);
% keyboard
% signif_table

% if any(signif_table(:,3)); keyboard; end

% Plot sig bar between each sig relationship
% keyboard
k=1;
hold on
for n = 1:size(signif_table)
    if (signif_table(n,3)>0)

       y = max_y+lvl_height*k;
       pt_xx =  [cohort_index(signif_table(n,1),4)...
           cohort_index(signif_table(n,2),4)];
       pt_yy =  [y y];
    
       
    plot(pt_xx,pt_yy,'k','LineWidth',1);
    
    text(mean(pt_xx),pt_yy(1)+lvl_height/4,repmat('*',[1 signif_table(n,3)]),'HorizontalAlignment',...
        'center','FontSize',8,'Fontweight','bold');
   k=k+1;
    end
    
end
hold off

xa=xlim; ya=ylim;
axis([xa min_y-(max_y-min_y)/10 max_y+lvl_height*(nlvls+1)]);
% 
% signif_table

end

