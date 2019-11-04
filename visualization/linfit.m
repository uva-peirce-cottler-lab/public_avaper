function linfit(x,y,xtext,ytext)
figure
plot(x,y,'x')
[RHO,PVAL] = corr(x,y);

coeffs = polyfit(x, y, 1);
% Get fitted values
fittedX = linspace(min(x), max(x), 200);
fittedY = polyval(coeffs, fittedX);
% Plot the fitted line
hold on;
plot(fittedX, fittedY, 'r-', 'LineWidth', 3); 
xlabel(xtext);
ylabel(ytext);
title(['R^2: ' sprintf('%0.2f', RHO^2) ',   p: ' sprintf('%0.2e', PVAL)]);
    pos = get(gcf,'Position');
    set(gcf,'Position',[pos(1:2) 400, 300]);
    set(gcf,'color','w');
% keyboard


% keyboard