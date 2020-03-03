

library(ggplot2)
library(dplyr)
library(forcats)
library(cowplot)

diam_df <- read.csv(file = 'diam_output.csv')
diam_df$group <- as.factor(diam_df$group)
diam_df$group <- recode(diam_df$group, "AC Lumen(-)" = "Lumen(-)\nBM Bridge", 
                         "AC Lumen(+)" = "Lumen(+) \nBM Bridge", 'Vessel' = "Capillary")



# Get standard deviation and mean for error bars
diam_mean_df <- diam_df %>% group_by(group) %>% summarize(mean = mean(mean_diam_um), sd = sd(mean_diam_um))



p1 <- ggplot(data=diam_df,aes(x=group, y = mean_diam_um)) + 
  geom_jitter(width=0.1, color = "grey", size = 0.5) +  
  geom_point(data = diam_mean_df, aes(x = group, y=mean), size = 1) +
  geom_errorbar(data = diam_mean_df, aes(x = group,ymin = mean - sd, ymax = mean + sd),
                inherit.aes = FALSE,width = 0.5)+
  theme_classic(base_size=8) + theme(legend.position="none") +
  xlab("") + ylab("Mean Diameter (um)") #+ coord_cartesian(ylim=c(0,20))
print(p1)

save_plot("Three groups.tiff",
           p1, ncol = 1, nrow = 1, base_asp = 3, dpi = 600,  
           base_height = 1.5, base_width =3)


diam_df2 <-diam_df;
diam_df2$group <- recode(diam_df2$group, "Lumen(-)\nBM Bridge" = "BM Bridge", 
                         "Lumen(+) \nBM Bridge" = "BM Bridge")

# Get standard deviation and mean for error bars
diam_mean_df2 <- diam_df2 %>% group_by(group) %>% summarize(mean = mean(mean_diam_um), sd = sd(mean_diam_um))



t.test(subset(diam_df2, group=="BM Bridge")$mean_diam_um,subset(diam_df2, group=="Capillary")$mean_diam_um)

p2 <- ggplot(data=diam_df2,aes(x=group, y = mean_diam_um)) + 
  geom_jitter(width=0.1,color="grey", size = 0.5) +  
  geom_point(data = diam_mean_df2, aes(x = group, y=mean), size = 1) +
  geom_errorbar(data = diam_mean_df2, aes(x = group,ymin = mean - sd, ymax = mean + sd),
                inherit.aes = FALSE,width = 0.5)+
  theme_classic(base_size=8) + theme(legend.position="none") +
  xlab("") + ylab("Mean Diameter (um)") #+ coord_cartesian(ylim=c(0,20))
print(p2)

save_plot("Two groups.tiff",
          p2, ncol = 1, nrow = 1, base_asp = 3, dpi = 600,  
          base_height = 1.5, base_width =3)


  

