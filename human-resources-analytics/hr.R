library(tidyr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(scales)


hr_data <- read.csv("./Extra DS/Kaggle_Repos/human-resources-analytics/HR_comma_sep.csv", stringsAsFactors = F)

str(hr_data)
unique(hr_data$left)
table(hr_data$left)


hr_data %>% ggplot()  + geom_histogram(aes(satisfaction_level, col="red"), binwidth = 0.1) + scale_x_continuous(breaks = seq(0,1,0.1))
#This shows most of the employess are highly satisfied 

hr_data %>% filter(left==1) %>% group_by(sales) %>%
ggplot()  + geom_histogram(aes(satisfaction_level), binwidth = .1) + facet_wrap(left~sales)

#most unsatisfied people are in sales and also there is most attiration happenign followed by technical and support

