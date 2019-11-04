function unpaired_plot(rep_gr_data,ytext,xgroups,extra_text,letter)

if sum(rep_gr_data{1})==0 & sum(rep_gr_data{2}==0);return; end
% keyboard
hf = figure();
plot(ones(size(rep_gr_data{1})),rep_gr_data{1},'ko')
hold on 
plot(2*ones(size(rep_gr_data{2})),rep_gr_data{2},'ko')
hold off
y =ylim;
axis([0 3 y(1) y(2)*1.25])
hold on
ylabel(ytext)
% h = errorbar(mean(rep_gr_data,1),std(rep_gr_data,1),'Linewidth',1);

% Draw error bars
add_errorbar(hf, 1,rep_gr_data{1}, 10)
add_errorbar(hf, 2,rep_gr_data{2}, 10)

% Set Group names
set(gca,'XTick', [1 2]);
set(gca,'XTickLabel',xgroups);

% Stat test
[h, p] = ttest2(rep_gr_data{1},rep_gr_data{2}, 'Alpha', 0.05,'Tail','both');



% Add textbox of pvalue
% y =ylim; ymin = min(vertcat(rep_gr_data{1},rep_gr_data{2}));
% ht = text(1.5,(ymin-y(1))/2+y(1),sprintf('p=%.4f',p),'HorizontalAlignment','center');

% keyboard

% If significant, dreaw black line with star
if ~isnan(h) & h; 
    y =ylim; yd = max(vertcat(rep_gr_data{1},rep_gr_data{2}));
    hold on; plot([1 2],[1 1] .*((y(2)-yd)/2+yd),'k','LineWidth',2.5);
%     p
    if p<.05; star_num=1;end
    if p<.01; star_num=2; end
    if p<.001;star_num=3;end
    text(1.5,(y(2)-yd)/1.7+yd,repmat('*',[1 star_num]),'HorizontalAlignment','center','FontSize',20,'Fontweight','bold');
end

% Resize figure, make smaller
pos = get(hf,'Position');
set(hf,'Position', [pos(1:2) pos(3:4)./[2 1.5]])

proj_path = getappdata(0,'proj_path');
if isempty(dir([proj_path '/out'])); mkdir([proj_path '/out']); end


% saveas(hf,[proj_path '/out/' regexprep(ytext,'/|\\','-') '.jpg']);
% hgexport(hf,[proj_path '/out/' regexprep(ytext,'/|\\','-')]);
set(gcf,'color','w');
img = getframe(gcf);
imwrite(img.cdata, [[proj_path '/out/' extra_text '_' regexprep(ytext,'/|\\','-')], '.png']);

close(gcf);

% keyboard
if ~isnan(h) & h; sig_str = ' significant'; else sig_str = 'n insignificant'; end
if mean(rep_gr_data{2})>mean(rep_gr_data{1}); sign_str = '+'; else sign_str = '-'; end

fprintf(['(' letter ') ' ytext ': The ' xgroups{2} ' Group(%3.2f' char(177) '%3.2f) has a' sig_str ' ' ...
    sign_str '%.1f%% change relative to ' ...
    xgroups{1} ' Group(%.2f' char(177) '%3.2f)'], ...
    mean(rep_gr_data{2}),std(rep_gr_data{2})/2,...
    abs(mean(rep_gr_data{2})./mean(rep_gr_data{1})*100-100), ...
    mean(rep_gr_data{1}), std(rep_gr_data{1})/2);

fprintf('(p=%8.2E)\n',p)


end