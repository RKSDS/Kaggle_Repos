# #import file from csv file
# library(stringr)
# library(tidyr)
# library(dplyr)
# library(plyr)
# library(ggplot2)
# library(reshape2)
# 
# #import data from csv file.
# trips <- read.csv("Uber Request Data.csv", stringsAsFactors = F)
# 
# #View(trips)
# str(trips)
# 
# #check to see any row in particular duplicated or not
# sum(duplicated(trips$Request.id))
# 
# 
# length(unique(na.omit(trips$Driver.id))) # unique drivers with NA 301
# 
# #Unique pickup-points
# unique(trips$Pickup.point) #only Airport and city => only rides included to and from airport and city
# 
# #Unique Status of trips
# unique(trips$Status)
# #No discrepancy in pickup point and status
# 
# #date strings contain / and - as splitters which is an issue and needs resolution
# trips$Request.timestamp <- gsub("-","/", trips$Request.timestamp) #bringging all the dates to same format
# 
# trips$Drop.timestamp <- gsub("-","/", trips$Drop.timestamp) #bringging all the dates to same format
# 
# #where seconds are not available in request timestamp we are considering it to be at 00 seconds and adding in below statement so that 
# #string can be converted to date using POSIXct easily.
# requesttime_updated <- sapply(trips$Request.timestamp, function(x){if(nchar(x)<19) {paste(x, ":00", sep = "")} else {x}}, simplify = T)
# 
# #check if any value is na
# sum(is.na(trips$Request.timestamp))
# 
# #check if any value is ""
# sum(as.character(trips$Request.timestamp)=="")
# 
# 
# #Converting Request.timestamp to date format as the format in string is know and the value is not NA for any entry.
# trips$Request.timestamp <- as.POSIXct(requesttime_updated, format="%d/%m/%Y %H:%M:%S")
# 
# #Check if everything is converted properly.
# sum((nchar(as.character(trips$Request.timestamp))<19 || nchar(as.character(trips$Request.timestamp))>19) )
# 
# #extract day, month, year, weekdays, hour, minute and seconds from Request.timestamp considering that to be start of the trip
# trips <- cbind(trips, trip_year=format(trips$Request.timestamp, "%Y"), 
#                   trip_month=format(trips$Request.timestamp, "%m"), trip_day=format(trips$Request.timestamp, "%d"), 
#                   trip_weekday=weekdays(trips$Request.timestamp), trip_start_hour=as.numeric(format(trips$Request.timestamp, "%H")), 
#                   trip_start_min=format(trips$Request.timestamp, "%M"), trip_start_sec=format(trips$Request.timestamp, "%S"))
# 
# #segmenting hours in parts of days
# trips <- cbind(trips, day_part=sapply(trips$trip_start_hour, function(x) { 
#   if(4<=x && x<8) {"earlymorning"} 
#   else if(8<=x&&x<12) {"morning"} 
#   else if(12<=x&&x<16) {"noon"} 
#   else if(16<=x&&x<20) {"afternoon"} 
#   else if(20<=x&&x<=23) {"evening"}
#   else {"night"}}))
# 
# 
# #converting to factors for easy ploting
# trips$Pickup.point <- as.factor(trips$Pickup.point)
# trips$Status <- as.factor(trips$Status)
# trips$trip_start_hour <- as.factor(trips$trip_start_hour)
# 
# #summary of trips
# summary(trips)
# 
# 
# #each day how many trips are happening
# count(trips, c("trip_weekday"))
# 
# #arrange in descending order of number of trips for each hour
# arrange(count(trips[trips$trip_weekday=="Monday", ], c('trip_start_hour', "Pickup.point", "Status")),trip_start_hour, desc(freq))
# 
# arrange(count(trips[trips$trip_weekday=="Tuesday", ], c('trip_start_hour', "Pickup.point", "Status")),trip_start_hour, desc(freq))
# 
# arrange(count(trips[trips$trip_weekday=="Wednesday", ], c('trip_start_hour', "Pickup.point", "Status")),trip_start_hour, desc(freq))
# 
# arrange(count(trips[trips$trip_weekday=="Thursday", ], c('trip_start_hour', "Pickup.point", "Status")),trip_start_hour, desc(freq))
# 
# arrange(count(trips[trips$trip_weekday=="Friday", ], c('trip_start_hour', "Pickup.point", "Status")),trip_start_hour, desc(freq))
# 
# # Total number of requests at each pickup point
# aggregate(trips$Pickup.point, by=trips[c("Pickup.point")], length)
# 
# #Total number of requests that got completed, cancelled and no cars available
# aggregate(trips$Status, by=trips[c("Status")], length)
# 
# # Numbers of different request status at airport and city
# aggregate(trips$Status, by=trips[c("Pickup.point","Status")], length)
# 
# #sort the number of trips done by each driver in descending order
# arrange(aggregate(trips$Status, by=trips[c("Driver.id")], length),desc(x))
# #Driver.id 27 has done max 22 trips followed by 21 trips by 5 other drivers.
# 
# #summary of number of trips done by drivers.
# summary(aggregate(trips$Status, by=trips[c("Driver.id")], length))
# #mean and median are 13.50 and 13.65 respectively. So on an average 
# # adriver partner drives 13.50 (round it to lower floor 13) trips
# 
# #Splitting Data Sets when no cars were available
# 
# sum(trips$Status=="No Cars Available")
# trips_NA <- trips[trips$Status=="No Cars Available",] # Gives all the data where No cars were available.
# 
# #checks how many Drop.timestamps are NA
# sum(is.na(trips_NA$Driver.id))
# sum(is.na(trips_NA$Drop.timestamp))
# #Above two statements verify that when car was not available Drop.timestamp and driver.id is NA.
# 
# 
# 
# 
# 
# #splitting data set when the trip was cancelled by driver
# 
# sum(trips$Status=="Cancelled")
# trips_cancelled <- trips[trips$Status=="Cancelled", ] # Gives all the data for cancelled trips.
# 
# sum(is.na(trips_cancelled$Drop.timestamp))
# sum(is.na(trips_cancelled$Driver.id))
# #From above two statements it is evident that the cancelled trips dont have the drop time but have a river id who is/against whom the 
# 
# 
# 
# 
# 
# # Data set when trip got completed.
# 
# sum(trips$Status=="Trip Completed")
# trips_completed <- trips[trips$Status=="Trip Completed", ]
# 
# #check if any data is na
# sum(is.na(trips_completed))
# 
# #check if any drop time is invalid or empty
# sum(is.na(trips_completed$Drop.timestamp))
# sum(trips_completed$Drop.timestamp=="")
# 
# #where seconds are not available for drop timestamp we are considering it to be at 00 seconds
# #and adding it so that string to date format conversion can be done easily.
# droptime_updated <- sapply(trips_completed$Drop.timestamp, function(x){if(nchar(x)<19) {paste(x, ":00", sep = "")} else {x}}, simplify = T)
# 
# #converting string to date
# trips_completed$Drop.timestamp <- as.POSIXct(droptime_updated, format="%d/%m/%Y %H:%M:%S")
# 
# #Check if everything is converted properly.
# sum((nchar(as.character(trips$Request.timestamp))<19 || nchar(as.character(trips$Request.timestamp))>19) )
# 
# #finding the time taken for completing a trip
# time_taken_in_min <- as.numeric(round(difftime(trips_completed$Drop.timestamp, trips_completed$Request.timestamp, units = "mins"),2))
# 
# #finding drop hohur minute and second
# #combining it with triups completed
# trips_completed <- cbind(trips_completed, 
#                          trip_end_hour=format(trips_completed$Drop.timestamp, "%H"), trip_end_min=format(trips_completed$Drop.timestamp, "%M"), 
#                          trip_end_sec=format(trips_completed$Drop.timestamp, "%S"), time_taken_in_min)
# 
# #Summarizing completed trips
# summary(trips_completed)
# #the trip ended within max of 1.5 hours
# 
# unique(trips_completed[which(!(trips_completed$Driver.id %in% unique(trips_cancelled$Driver.id))),3]) #Drivers who never cancelled a trip.
# 
# 
# 
# 
# 
# 
# #Total Demand including airport and city at different hours
# demand <- as.data.frame(table(trips$trip_start_hour))
# 
# #rename columns for demand df
# names(demand) <- c("trip_hour", "total_request")
# 
# # get the total number of trips for each status
# counts <- as.data.frame(count(trips, c('trip_start_hour', "Status")))
# 
# #get total number of trips for earch pickup point
# pickup_point_count <- count(trips, c('trip_start_hour', "Pickup.point"))
# 
# str(counts)
# 
# # add new columns to the demand
# demand <- cbind(demand, completed_count=counts[counts$Status=="Trip Completed",3],
#                 cancelled_count=counts[counts$Status=="Cancelled",3], 
#                 nocarsavailable_count=counts[counts$Status=="No Cars Available",3],
#                 airport_count=pickup_point_count[pickup_point_count$Pickup.point=="Airport", 3],
#                 city_count=pickup_point_count[pickup_point_count$Pickup.point=="City", 3])
# 
# #total gap including airport and city at diffenrent hours
# # equal to Cancelled + No Cars Available or total_request - completed_requests
# demand <- cbind(demand, gap=demand[, "cancelled_count"] + demand[,"nocarsavailable_count"])
# demand$trip_hour <- as.numeric(demand$trip_hour)
# 
# str(demand)
# #..............gives analysis of demand and gap. Also categories of status and pickup point....................#
# summary(demand)
# 
# 
# 
# 
# 
# #find correlation matrix between diffrent demand variables
# cormat <- round(cor(demand),2)
# #convert cormat to tabular format of Var1, Var2 and correlation between them as value
# melted_cormat=melt(cormat)
# 
# 
# 
# 
# 
# #few plots to find some insight 
# 
# #plot to show the number of trips requested at airport and city
# ggplot(trips, aes(trips$Pickup.point, fill=trips$Pickup.point)) + geom_bar() + 
#   labs(x="Pickup Point", y="Number of Requests", title="Pickup Point vs Count of Request", fill="Pickup Point")
# #shows a difference of 500 request only between city and airport
# 
# 
# 
# #plot to show the number of trips requested at airport and city on different days
# ggplot(trips, aes(trips$Pickup.point, fill=trips$Pickup.point)) + geom_bar() + 
#   labs(x="Pickup Point", y="Number of Requests", title="Pickup Point vs Count of Request over each day", fill="Pickup Point") +
#   facet_wrap(~ trips$trip_weekday)
# #shows Monday and Friday almost same number of requests at airport and city
# #while on Tuesday and Wednesday requests are higher at airport and on Thurday
# #it is much higher in city
# 
# 
# #plot to show the number of trips requested at airport and city at different hours
# ggplot(demand, aes(demand$trip_hour, demand$airport_count)) + geom_line(col="blue") +
#   geom_line(aes(demand$trip_hour, demand$city_count), col="red") +
#   labs(x = "Trip Request Hour", y = "Number of Request", title="Request hour vs Number of Requests for Airport and City")
# 
# 
# #plot to show the number of trips that happened at airport and city with status, if they were completed, cancelled or no cars available
# ggplot(trips, aes(trips$Status, fill=trips$Pickup.point)) + geom_bar(position = position_dodge(width = 0.3), alpha=0.8) +
#   labs(x="Status", y="Number of Requests", title="Status vs Trip Request", fill="Pickup Point")
# 
# 
# 
# ggplot(trips_cancelled, aes(trips_cancelled$Pickup.point, fill=trips_cancelled$Pickup.point)) + geom_bar() +
#   labs(x="Pickup Point", y="Count of requests cancelled", 
#        title="Pickup Point Vs Count of Requests Cancelled", fill="Pickup Point")
# #Clearly evident most trips are getting cancelled at city
# 
# 
# ggplot(trips_NA, aes(trips_NA$Pickup.point, fill=trips_NA$Pickup.point)) + geom_bar() +
#   labs(x="Pickup Point", y="Count of Requests Not Attended", 
#        title="Pickup Point Vs Count of Requests with No Cars Available", fill="Pickup Point")
# # shows the maximum number of trips that are unavailable are at airport
# 
# #plot showing trips starting at different time in day and time taken by them to complete
# ggplot(trips_completed, aes(trips_completed$time_taken_in_min, col="red", fill=trips_completed$day_part)) + 
#   geom_histogram(binwidth = 10) +
#   labs(x="Time taken to Complete the trip(in min).", y="Num oftrips completed.", fill="Day Part", 
#        title="Time Taken to complete trip vs Num of trip completed")
# 
# #trips that originate from airport
# airport_completed_trip <- trips_completed[trips_completed$Pickup.point=="Airport",]
# 
# #plot showing trips starting from airport at different time in day and time taken by them to complete
# ggplot(airport_completed_trip, aes(airport_completed_trip$time_taken_in_min, col="red", fill=airport_completed_trip$day_part)) + 
#   geom_histogram(binwidth = 10) +
#   labs(x="Time taken to Complete the trip(in min).", y="Num oftrips completed.", fill="Day Part", 
#        title="Time Taken to complete trip vs Num of trip completed for City trips")
# 
# #trips that originate from city
# city_completed_trip <- trips_completed[trips_completed$Pickup.point=="City",]
# 
# #plot showing trips starting from City at different time in day and time taken by them to complete
# ggplot(city_completed_trip, aes(city_completed_trip$time_taken_in_min, col="red", fill=city_completed_trip$day_part)) + 
#   geom_histogram(binwidth = 10) +
#   labs(x="Time taken to Complete the trip(in min).", y="Num oftrips completed.", fill="Day Part", 
#       title="Time Taken to complete trip vs Num of trip completed for Airport trips")
# 
# #plot shows the number of trips originating at airport and city at different interval of day
# ggplot(trips, aes(trips$day_part, fill=trips$day_part, col=trips$Pickup.point)) + geom_bar() +
# labs(x="Day Part.", y="Num of trips completed.", fill="Day Part", color="Pickup point",
#      title="Number of trips completed for airport and city at different day parts.")
# 
# # make almost no difference as hours go up time required to complete the trip ETA hardly gets affected.
# cor(as.numeric(trips_completed$trip_start_hour), trips_completed$time_taken_in_min)
# 
# #plot showing at different hours of day how many trips are completed, cancelled 
# #and no cars available in % of total trip request in that hour
# ggplot(trips, aes(trips$trip_start_hour, fill=trips$Status)) + geom_bar(position = "fill") + labs(x="Request Hour" , y = "Count %")
# 
# #plot correlation heat map
# qplot(x=Var1, y=Var2, data=melted_cormat, fill=value, geom="tile") +
#   scale_fill_gradient2(limits=c(-1, 1), name="Pearson\nCorrelation") +
#   theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1)) + 
#   coord_fixed()
# 
# #Plot a step graph showing when the gap is increasing and decreasing.
# ggplot(demand, aes(as.numeric(demand$trip_hour), demand$gap)) + geom_step() + scale_x_continuous(breaks = c(1:24)) +
#   labs(x="Hours of Day", y="Number of Unfulfilled Requests.", title="Gap vs Hours", caption="Count(Y)=Demanded Trips-Fulfilled Trips")
# 
# 
# # time-taken study for travel from airport and city
# ggplot(trips_completed, aes(trips_completed$trip_start_hour, trips_completed$time_taken_in_min)) + 
#   geom_boxplot() + facet_wrap( ~ trips_completed$Pickup.point) + 
#   stat_summary(fun.y=mean, colour="darkred", geom="point", shape=18, size=3,show.legend = T) +
#   labs(x = "Trip Request Hoour", y = "Time Taken to complete the Trip", 
#        title="Study of Time Taken at different hours.", caption = "Red Dot represents mean values" )
# 
# 
# write.csv(trips,"trips.csv")
# write.csv(trips_NA, "trips_NA.csv")
# write.csv(trips_cancelled, "trips_cancelled.csv")
# write.csv(trips_completed, "trips_completed.csv")
