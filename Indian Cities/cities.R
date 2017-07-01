# This R environment comes with all of CRAN preinstalled, as well as many other helpful packages
# The environment is defined by the kaggle/rstats docker image: https://github.com/kaggle/docker-rstats
# For example, here's several helpful packages to load in 

library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function
library(tidyr)
library(dplyr)
library(stringr)
library(reshape2)
library(scales)
library(corrplot)

# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

list.files("../input")

# Any results you write to the current directory are saved as output.

#import data from csv to data frame
city_data <- read.csv("../input/cities_r2.csv",  stringsAsFactors = F)


#structure of the data imported
str(city_data)

#check if there are any na values
sum(is.na(city_data))

#check how many duplicated cities are there
sum(duplicated(city_data$name_of_city))

#which is the duplicated city
dup_city <- city_data[which(duplicated(city_data$name_of_city)),]$name_of_city

city_data[which(city_data$name_of_city==dup_city), ]

#both the cities belong to different states. So data is fine here.

#replace the extra spoace in cities
city_data$name_of_city <- gsub(" ", "", city_data$name_of_city)

#summary of each column
summary(city_data)
#Convevrt the categorical columns to factors
city_data$state_code <- as.factor(city_data$state_code)
city_data$state_name <- as.factor(city_data$state_name)
city_data$dist_code <- as.factor(city_data$dist_code)

##Treat the outliers from beginning
#Consider the total population will have the outlier
#we will exclude the outlier and maybe later we will analize them separately
#finding the 1st and 3rd quantiles
quantiles <- quantile(city_data$population_total,c(0.25,0.75))

#creating a range which could be tolerated

range <- 1.5*IQR(city_data$population_total)

#Filtering lower outliers if any
lower_outliers <- city_data[which(city_data$population_total < (quantiles[1] - range)),]

#removing it from data set
if(nrow(lower_outliers)!=0) {
  city_data <- city_data[-which(city_data$population_total < (quantiles[1] - range)),]
}

#finding the upper putliers

upper_outliers <- city_data[which(city_data$population_total > (quantiles[2] + range)),]

#removing it from data set
if (nrow(upper_outliers)!=0) {
  without_outlier_data <- city_data[-which(city_data$population_total > (quantiles[2] + range)),]
}
#We will consider Outliers separately

#Aggregate Data on State Level
state_df <- city_data %>% group_by(state_code, state_name) %>% summarise(total_cities = n(),
                                                                         total_population = sum(population_total), 
                                                                         male_population = sum(population_male),
                                                                         female_population = sum(population_female),
                                                                         state_sex_ratio = round((female_population/male_population)*1000,0),
                                                                         child_population = sum(X0.6_population_total),
                                                                         male_child_population=sum(X0.6_population_male),
                                                                         female_child_population=sum(X0.6_population_female),
                                                                         state_Child_sex_ratio = round((female_child_population/male_child_population)*1000,0),
                                                                         total_literates = sum(literates_total),
                                                                         male_literates = sum(literates_male),
                                                                         female_literates = sum(literates_female),
                                                                         effective_literacy_rate = round((total_literates/total_population)*100,1),
                                                                         male_effective_literacy_rate = round((male_literates/total_population)*100,1),
                                                                         female_effective_literacy_rate = round((female_literates/total_population)*100,1),
                                                                         graduates_total = sum(total_graduates),
                                                                         graduates_male = sum(male_graduates),
                                                                         graduates_female = sum(female_graduates),
                                                                         total_graduation_rate = round((graduates_total/total_population)*100,2),
                                                                         male_graduation_rate = round((graduates_male/male_population)*100,2),
                                                                         female_graduation_rate = round((graduates_female/female_population)*100,2)) %>% arrange(desc(total_population))



## Ploting the Number of cities for which data has been collected ##
### excluding the cities which were outliers ###
ggplot(state_df, aes(reorder(state_name, total_cities, desc), total_cities, fill=state_name)) + geom_bar(stat = "identity") + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position = "none") +
  geom_text(aes(label=total_cities), stat = "identity", vjust=-0.35) + 
  labs(x="State", y="Count", title="Number of Cities choosed from each State", 
       caption=paste("Total number of Cities considered =", sum(state_df$total_cities)))

### From this it is clear that for West Bengal most number of cities were covered
### Where as for north east states 3 or lesser number of cities were covered ###


## Plots for Population in States ##
### Filter Poplation Data from the aggregated data ###
population_data <- melt(state_df[, c("state_name", "total_population", "male_population", "female_population")], id="state_name")

### Ploting population in each state ###
ggplot(population_data, aes(state_name, value/(10^6), col=variable)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position="bottom") +
  geom_line(aes(group=variable)) + geom_point(alpha=0.3) +
  labs(x="State", y="Population in Billion", title="Total, Male and Female Population in Each State")

### From the chart we can see that the population is highest in west bengal followed by uttar pradesh
### This seems to be because of the number of cities covered as they also follow the same trend ###


### Ploting sex ratio for each state
ggplot(state_df, aes(reorder(state_name, state_sex_ratio, desc), state_sex_ratio, fill=state_name)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position="none") + geom_bar(stat="identity") +
  geom_text(aes(label=state_sex_ratio), stat = "identity",hjust=0, angle=90) +
  labs(x="State", y="Sex Ratio of Population", title="Sex Ratio of Population in each State")

### sex ratio is given by total female for each 1000 male which also indicates the female to male ratio in
### a state.
### Kerala has maximum results with 1063 while Himachal Pradesh has the worst 818
### Tripura, Mizoram, Puducherry, Meghalaya, Manipur and Kerla are doing well
### Rest other needs to catch up 1000 number where 1:1 ratio can be maintained ###

## Plot for Child Population study in states ##
### Filter Child Poplation Data from the aggregated data ###
child_population_data <- melt(state_df[, c("state_name", "child_population", "male_child_population", "female_child_population")], id="state_name")

### Ploting child population in each state ###
ggplot(child_population_data, aes(state_name, value/(10^6), col=variable)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position="bottom") + 
  geom_line(aes(group=variable)) + geom_point(alpha=0.3) +
  labs(x="State", y="Child Population in Billion", title="Total, Male and Female Child Population in Each State")

### From the chart we can see that the population is highest in uttar pradesh followed by west bengal
### and maharastra


### Ploting sex ratio for each state
ggplot(state_df, aes(reorder(state_name, state_Child_sex_ratio, desc), state_Child_sex_ratio, fill=state_name)) + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position="none") + geom_bar(stat="identity") +
  geom_text(aes(label=state_Child_sex_ratio), stat = "identity",hjust=0, angle=90) +
  labs(x="State", y="Sex Ratio of Child Population", title="Sex Ratio of Child Population in each State")

### sex ratio is given by total female for each 1000 male which also indicates the female to male ratio in
### a state.
### Mizoram has maximum results with 989 followed by Puducherry while Haryana has the worst 819
### Here it is clearly shows that none of the sates have female population more than 50% which is a reason of concern.###


## Graph expplaining the population with respect to education ##

literacy_data <- melt(state_df[, c("state_name", "total_literates", "male_literates", "female_literates")], id="state_name")

### Plot showing the literate total, male and female population in each state ###
ggplot(literacy_data, aes(state_name, value/(10^6), col=variable)) + 
  geom_line(aes(group=variable)) + geom_point(alpha=0.3) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position = "bottom") +
  labs(x="State", y="Literate Population in Billion", title="Literate Population in States") 

### From the plot we can say the number of literates are high in West Bengal Followed by Uttar Pradesh
### while the lowest is in Andaman & nicobar Islands and Mizoram. Here the number of cities considered
### might also be a factor in such results. ###

### Plot showing the female to male literates ratio in each state ###
ggplot(state_df, aes(state_name, round((female_literates/male_literates),2), fill=state_name)) + geom_bar(stat = "identity", position = position_dodge(width = 0.5), alpha=0.8) +
  geom_text(label=round((state_df$female_literates/state_df$male_literates),2), angle=90, hjust=0) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position = "none") +
  labs(x="State", y="Female to Male\nLiterate population", title="Female Literate to Male Literate population in States")

### For this if the result is 1 that means there are equal number of male and female literates. While if the number is more the 
### number of female literates are more than male and vice versa. So for states Kerala, Meghalaya and Mizoram where the population 
### was not significant the number of female literates are more than male literates. In other states it is the other way round.
### the state NCT of Delhi has the worst literate ratio followed by Rajasthan and Bihar.


## Graph expplaining the population literacy with respect to total population ##

literacy_rate_data <- melt(state_df[, c("state_name", "effective_literacy_rate", "male_effective_literacy_rate", "female_effective_literacy_rate")], id="state_name")

### to get clear picture of the literacy we need to see the percentage of population ###
ggplot(literacy_rate_data[literacy_rate_data$variable=="effective_literacy_rate",], aes(reorder(state_name, value, desc), value, fill=state_name)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.5), alpha=0.8) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1), legend.position = "none") +
  geom_text(aes(label=value), stat = "identity", hjust=0, angle=90) +
  labs(x="State", y="Literate rate of population", title="Literate Rate of Total Population in States")

### from above graph we can tell that Kerala tops the literacy rate with 87.6% while the 2 staes Uttar Pradesh and Bihar are almost equal
### and lowest in literacy rate at 69.75%

### Plot to see the percentage of total, male and female literacy rate for each state ###
ggplot(literacy_rate_data, aes(state_name, value, col=variable)) + geom_line(aes(group = variable)) + geom_point() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), legend.position = "bottom") +
  labs(x="State", y="Literate rate of population", title="Literate Rate of Total Population, Male and Female Population in States")

### from this graph we can tell that the females of Bihar are lagging most and female from Kerala are ahead of eveey other state females
### Himachal Pradesh males seems to be leading all other states male and female while uttar pradesh males seems to have least literacy rate ###



##It is important to see how the female to male ratio effect the literacy rate of state ##
## Filter data to show relationship between sex ratio and literacy rate ##
sex_ratio_vs_literacy_rate_data <- melt(state_df[, c("state_name", 
                                                     "state_sex_ratio",
                                                     "effective_literacy_rate", 
                                                     "male_effective_literacy_rate", 
                                                     "female_effective_literacy_rate")], 
                                        id="state_name")


### Bring the sex ratio to a comparable value ###
sex_ratio_vs_literacy_rate_data[sex_ratio_vs_literacy_rate_data$variable=="state_sex_ratio",]$value <-
  sex_ratio_vs_literacy_rate_data[sex_ratio_vs_literacy_rate_data$variable=="state_sex_ratio",]$value/10

### Plot the relation between sex ratio and literacy rate for each state ###
ggplot(sex_ratio_vs_literacy_rate_data, aes(state_name, value, col=variable)) + 
  geom_line(aes(group = variable)) + geom_point()  +
  theme(axis.text.x = element_text(angle = 90, hjust=1), legend.position = "bottom") +
  labs(x="Sex Ratio", y="Literate rate", title="Sex Ratio vs Literate Rate in States")

### From the graph it can be seen that thought the sex ratio in Himachal Pradesh is really bad (The lowest)
### The lteracy rate is really high (The highest). Similarly there is another interesting state AndhraPradesh
### where the sex ratio is about 100 but the literacy rate is not great. Most of the other state's literacy rate 
### follow the same trend as sex ratio and FEMALE literacy rate.This implies where there is good amount of 
### female population there is good amount of female education and good amount of literacy also and the vice versa.
### Female literacy is maximum in Kerala which is more than male literacy rate also in the state.


## It is important to see how the sex ratio and literacy rate affects the graduation rate ##
## Get the data of graduation rate and sex ratio for state #
sex_ratio_vs_graduation_rate_data <- melt(state_df[, c("state_name", 
                                                       "state_sex_ratio",
                                                       "total_graduation_rate", 
                                                       "male_graduation_rate", 
                                                       "female_graduation_rate")], 
                                          id="state_name")

### plot the total graduation rate across states ###
ggplot(sex_ratio_vs_graduation_rate_data[sex_ratio_vs_graduation_rate_data$variable=="total_graduation_rate",], 
       aes(reorder(state_name, value, desc), value, fill=state_name)) + geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle=90,hjust=1), legend.position = "none") + 
  geom_text(aes(label=value), angle=90, hjust=0) +
  labs(x= "States", y="Graduation Rate", title = "Graduation Rate across States", caption=paste("Over All Graduation Rate is", round((sum(state_df$graduates_total)/sum(state_df$total_population))*100,2)))

### Clearly Himachal Pradesh has the highest graduation rate and NCT of Delhi has the lowest. We can also observe that total graduation
### rate is around 13% only. The maximum graduating population is mearly 25%. This shows that employable people at executive level are 
### very less.

### Bring the sex ratio to a comparable value ###
sex_ratio_vs_graduation_rate_data[sex_ratio_vs_graduation_rate_data$variable=="state_sex_ratio",]$value <-
  sex_ratio_vs_graduation_rate_data[sex_ratio_vs_graduation_rate_data$variable=="state_sex_ratio",]$value/100


### plot the total graduation rate across states ###
ggplot(sex_ratio_vs_graduation_rate_data, aes(state_name, value, col=variable)) + geom_point() + 
  geom_line(aes(group=variable)) + theme(axis.text.x = element_text(angle=90,hjust=1), legend.position = "bottom") + 
  labs(x= "States", y="Graduation Rate", title = "Graduation Rate across States", 
       caption=paste("Over All Graduation Rate is", 
                     round((sum(state_df$graduates_total)/sum(state_df$total_population))*100,2)))
### Interestingly the total population, male and female graduation rate is equal for Himachal Pradesh and that is highest for total and female population
### The maximum graduation rate for females is in Manipur which has the second highest total graduation rate. Lowest graduation rate for male is in NCT of
### Delhi where as lowest graduation rate for female is in Bihar.

### sex Ratio doesn't seems to be affecting the graduation rate much. ###

## Lets Plot the literacy rate with graduation rate ##
### filter gradutaion rate data with effective literacy rate ###
literacy_rate_vs_graduation_rate_data <- melt(state_df[, c("state_name", 
                                                           "effective_literacy_rate",
                                                           "total_graduation_rate", 
                                                           "male_graduation_rate", 
                                                           "female_graduation_rate")], 
                                              id="state_name")
### plot graph for graduation rate along with literacy rate ###
ggplot(literacy_rate_vs_graduation_rate_data, aes(state_name, value, col=variable)) + 
  geom_line(aes(group=variable)) + geom_point() + 
  theme(axis.text.x = element_text(angle=90,hjust=1), legend.position = "bottom") + 
  labs(x= "States", y="Graduation Rate", title = "Graduation Rate across States")
### from the results the literacy rate seems to be affecting the graduation rate but it doesn't look too 
### strong.


## Some graphs showing relation between two variables ##

ggplot(city_data, aes(sex_ratio, child_sex_ratio)) + geom_point() + geom_smooth() +
  labs(x="Sex Ratio", y="Child Sex Ratio", title="Sex Ratio Vs. Child Sex Ratio")

ggplot(city_data, aes(sex_ratio, effective_literacy_rate_total)) + geom_point() + geom_smooth() +
  labs(x="Sex Ratio", y="Effective Literacy Rate", title="Sex Ratio Vs. Effective Literacy Rate")

ggplot(city_data, aes(sex_ratio, total_graduates*100/population_total)) + geom_point() + geom_smooth() +
  labs(x="Sex Ratio", y="Graduation Rate", title="Sex Ratio Vs. Graduation Rate")

ggplot(city_data, aes(effective_literacy_rate_total, total_graduates*100/population_total)) + geom_point() + geom_smooth() +
  labs(x="Literacy Rate", y="Graduation Rate", title="Literacy Rate  Vs. Graduation Rate")

city_num_data <- city_data[,!(colnames(city_data) %in% c("name_of_city","state_code", "state_name", "dist_code", "location"))]
cordata <- cor(city_num_data)
corrplot(cordata, method="shade", type="upper")
