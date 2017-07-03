library(tidyr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(scales)


hr_data <- read.csv("./Extra DS/Kaggle_Repos/human-resources-analytics/HR_comma_sep.csv", stringsAsFactors = F)

str(hr_data)
sum(is.na(hr_data))
unique(hr_data$left)
table(hr_data$left)

hr_data$left <- as.factor(hr_data$left)
hr_data$Work_accident <- as.factor(hr_data$Work_accident)
hr_data$sales <- as.factor(hr_data$sales)
hr_data$number_project <- as.factor(hr_data$number_project)
hr_data$time_spend_company <- as.factor(hr_data$time_spend_company)
hr_data$salary <- as.factor(hr_data$salary)


ggplot(hr_data, aes(left, fill=left)) + geom_histogram(stat="count") +
  geom_text(aes(label=..count..), stat="count", vjust=-0.35) +
  labs(x="Left or Not", y="Count", title="Histogram for Employee Leaving vs Not Leaving")

ggplot(hr_data, aes(satisfaction_level, fill=factor(left)))  + geom_histogram(binwidth = 0.1, position = "dodge") + 
  scale_x_continuous(breaks = seq(0,1,0.1)) +
  labs(x="Employee Satisfaction Level", y="Count", title="Histogram for Employee satisfaction", fill="Left")
#This shows most of the employess are highly satisfied and they are not leaving while
### the opposite is true

ggplot(hr_data, aes(factor(left), satisfaction_level, fill=left)) + geom_boxplot() +
  labs(x="Left or Not", y="Satisfaction Level", title="Boxplot for Employee satisfaction", fill="Left")
### From this plot we can see satisfaction level for leaving employees vary from .10 to .75
### which shows there is some other factor which is involved in causing the attiration

ggplot(hr_data, aes(last_evaluation, fill=left)) + geom_histogram(binwidth = 0.1, position = "dodge") +
  scale_x_continuous(breaks = seq(0,1,0.1)) + 
  labs(x="Employee Evaluation Score", y="Count", title="Histogram for Employee Evaluation Score", fill="Left")
### This shows that who are levaing majorly have a rating above 0.5 or 0.8 which is causing a good amount of 
### talent loss

ggplot(hr_data, aes(factor(left), last_evaluation, fill=left)) + geom_boxplot() +
  labs(x="Left or Not", y="Last Evaluation", title="Boxplot for Employee Evaluation", fill="Left")
### This concludes this is also not the reason for the employees to leave

ggplot(hr_data, aes(number_project, fill=left)) + geom_bar(position = "fill") +
  labs(x="Number of Projects", y="% of employee leaving to not leaving", 
       title="Bar plot showing employee chances of leaving vs number of projects", fill="Left")

hr_data %>% group_by(left) %>% summarise(Total_work_hour = sum(average_montly_hours), 
                                      average=mean(average_montly_hours),
                                      median=median(average_montly_hours))

ggplot(hr_data, aes(left, average_montly_hours, fill=left)) + geom_boxplot() +
  labs(x="Left or Not", y="Average Monthly Working Hours", 
       title="Box plot showing employee chances of leaving vs working hours", fill="Left")
### There is no doubt that for employees leaving had high number of projects and we are seeing
### a supporting factor the number of average monthly hours to that which is in average higher
### than the employees who are not leaving.

ggplot(hr_data, aes(left, average_montly_hours, fill=left)) + geom_boxplot() + facet_wrap(~number_project) +
  labs(x="Left or Not", y="Average Monthly Working Hours", 
       title="Box plot showing employee chances of leaving vs number of projects vs working hours", fill="Left")
### It can be seen that the people who are leaving are putting more average monthly hour except for people
### who are working on 2 projects only. They are giving around 150 hours a month on an average.

ggplot(hr_data, aes(time_spend_company, fill=left)) + geom_bar(position = "fill") +
  labs(x="Time spent with company", y="% of employees Left or Not",
       title="Box plot showing employee chances of leaving vs working hours", fill="Left")
### This shows that the number of people working for more than 3 years and less than or equal to 6 years are 
### leaving the company 

### This looks like one of the reasons where people who were involved in 2 projects
### or had more than 5 project are likely to leave

hr_data %>% filter(left==1) %>% group_by(sales) %>%
ggplot()  + geom_histogram(aes(satisfaction_level), binwidth = .1) + facet_wrap(left~sales)
### The median rating is around 0.8 for the employee who left.

#most unsatisfied people are in sales and also there is most attiration happenign followed by technical and support

