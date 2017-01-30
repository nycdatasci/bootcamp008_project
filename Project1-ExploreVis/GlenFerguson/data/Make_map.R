library(ggplot2)
library(maps)

World = map_data('world')
World <- World[World$region != 'Antarctica',]

World$Group[World$region %in% c('South Africa','Turkey')] = 'AME'
World$Group[World$region %in% c('Australia','New Zealand')] = 'ANZ'
World$Group[World$region %in% c('China','India','Japan','Korea',|'Malaysia','Philippines',
                                'Singapore','Thailand')] = 'APA'
World$Group[World$region %in% c('Bulgaria','Croatia','Georgia','Hungary','Moldova',
                                'Romania','Russia','Ukraine')] = 'ECA'
World$Group[World$region %in% c('Argentina','Brazil','Chile','Mexico','Uruguay')] = 'LAC'
World$Group[World$region %in% c('USA','Canada')] = 'USC'
World$Group[World$region %in% c('Austrian','Belgium','Denmark','Finland','Germany',
                                'Greece','Ireland','Netherlands','Sweden','Switzerland',
                                'UK')] = 'WEM'
World$Group[World$region %in% c('France','Italy','Spain','Portugal')] = 'WEX'
World$Group[!(World$Group %in% c('AME','ANZ','APA','ECA', 'LAC','USC','WEM','WEX'))] = 'OTHER'


g <- ggplot(data=World, aes(x=long, y = lat)) +
  geom_polygon(aes(group=group, fill=Group)) + 
  coord_quickmap() + 
  theme_void()
g

#ggtitle('Population of Texas Counties') +
#  coord_map() +
#  theme_bw() +
#  xlab('') + ylab('') +
#  theme(plot.title=element_text(hjust=0.6, vjust= -1)) +
#  scale_fill_brewer(palette = "YlOrRd", 
#                    name ="Population", labels = c("0 - 999", "1,000 - 9,999",
#                                                   "10,000 - 99,999", "100,000 - 999,999",
#                                                   "1,000,000+"))