install.packages("fitbitScraper")
library(fitbitScraper)

cookie <- login(email="ndonders93@gmail.com", password="Greet2606")
cookie2 <- login(email="greet_coppens93@gmail.com", password="Basket07")
dates <- seq(as.Date("2017-01-25"), as.Date("2017-02-13"), by="day")

## export from API
steps_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="steps", as.character(x)))
steps <- do.call(rbind, steps_day)

hr_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="heart-rate", as.character(x)))
heartRate <- do.call(rbind, hr_day)

distance_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="distance", as.character(x)))
distance <- do.call(rbind, distance_day)

floors_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="floors", as.character(x)))
floors <- do.call(rbind, floors_day)

activeMinutes_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="active-minutes", as.character(x)))
activeMinutes <- do.call(rbind, activeMinutes_day)

caloriesBurned_day <- lapply(dates, function(x)
  get_intraday_data(cookie=cookie, what="calories-burned", as.character(x)))
caloriesBurned <- do.call(rbind, caloriesBurned_day)


#get_premium_export(cookie, what="SLEEP",start_date = "2017-01-01", end_date="2017-01-10")
save(activeMinutes, caloriesBurned, distance, floors, heartRate, steps, file = "fitbit.RData")

## Export from fitbit site
library(xlsx)
body <- read.xlsx2("fitbit_export_20170101_20170125.xls",1)
activities <- read.xlsx2("fitbit_export_20170101_20170125.xls",2)
sleep <- read.xlsx2("fitbit_export_20170101_20170125.xls",3)
body_2 <- read.xlsx2("fitbit_export_20170125_20170213.xls",1)
activities_2 <- read.xlsx2("fitbit_export_20170125_20170213.xls",2)
sleep_2 <- read.xlsx2("fitbit_export_20170125_20170213.xls",3)
body<-rbind(body,body_2)
activities<-rbind(activities,activities_2)
sleep<-rbind(sleep,sleep_2)

library(ggplot2)
ggplot(steps) + geom_bar(aes(x=time, y=steps, fill=steps), stat="identity") + 
  xlab("") +ylab("steps") + 
  theme(axis.ticks.x=element_blank(), 
        panel.grid.major.x = element_blank(), 
        panel.grid.minor.x = element_blank(), 
        panel.grid.minor.y = element_blank(), 
        panel.background=element_blank(), 
        panel.grid.major.y=element_line(colour="gray", size=.1), 
        legend.position="none") 

ggplot(heartRate) + 
  geom_line(aes(x=time, y=`heart-rate`, fill=`heart-rate`), stat="identity") + 
  xlab("") +
  ylab("heart-rate") + 
  theme(axis.ticks.x=element_blank(), 
        panel.grid.major.x = element_blank(), 
        panel.grid.minor.x = element_blank(), 
        panel.grid.minor.y = element_blank(), 
        panel.background=element_blank(), 
        panel.grid.major.y=element_line(colour="gray", size=.1), 
        legend.position="none") 

library(googleVis)
plot(gvisAnnotationChart(heartRate, "time", "heart-rate",date.format = "%Y-%m-%d %h:%m:%s"))



floors$weekday <- format(floors$time, "%A")
floors$date <- format(floors$time, "%Y-%m-%d")
sums <- by(floors$floors, floors$date, sum)
sums <- data.frame(date=names(sums), floors=as.numeric(sums))
sums$date <- as.POSIXct(sums$date)
sums$weekday <- format(sums$date, "%A")
avgs <- by(sums$floors, sums$weekday, mean)
avgs <- data.frame(day=names(avgs), floors=as.numeric(avgs))
avgs$day <- factor(avgs$day, levels=avgs$day[c(3, 1, 5, 2, 4, 6, 7)])

ggplot(avgs) + 
  geom_bar(aes(x=day, y=floors), stat="identity") +
  xlab("") + 
  ylab("") + 
  ggtitle("Average Floors by Day") + 
  geom_text(aes(x=day,y=floors,label=round(floors, 1)),
            vjust=1.1, colour="white") + 
  theme(axis.text.y=element_blank(), axis.ticks.y=element_blank()) + 
  theme(plot.title=element_text(vjust=.5))

plot(gvisBarChart(avgs, "day","floors"))


library(plotly)
library(dplyr)
heatmap <- steps
heatmap$date_hour <- format(steps$time,"%Y-%m-%d %H")
steps_per_hour <- by(heatmap$steps, c(heatmap$date_hour),sum)
steps_per_hour <- data.frame(date_hour=names(steps_per_hour),steps=as.numeric(steps_per_hour))
steps_per_hour$date <- as.POSIXct(substr(steps_per_hour$date_hour,0,10))
steps_per_hour$weekday <- format(steps_per_hour$date,"%A")
steps_per_hour$weekday <- factor(steps_per_hour$weekday,levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))
steps_per_hour$hour <- substr(steps_per_hour$date_hour,12,13)

steps_avg_per_hour_weekday <- steps_per_hour %>% group_by(weekday,hour) %>% summarise(avg=mean(steps))

p <- plot_ly(
    data = steps_avg_per_hour_weekday, 
    x=steps_avg_per_hour_weekday$hour,y=steps_avg_per_hour_weekday$weekday,z=steps_avg_per_hour_weekday$avg, 
    type = "heatmap"
  )
p
