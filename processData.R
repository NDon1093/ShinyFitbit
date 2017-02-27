# Load ../Data in memory
filenamesNiels <- c("../Data/stepsNiels.RData","../Data/floorsNiels.RData","../Data/hrNiels.RData","../Data/distanceNiels.RData","../Data/calNiels.RData")

# filenamesGreet <- c("../Data/stepsGreet.RData","../Data/floorsGreet.RData","../Data/hrGreet.RData","../Data/distanceGreet.RData","../Data/calGreet.RData")

lapply(filenamesNiels,load,.GlobalEnv)
caloriesBurned_ALL <- caloriesBurned
distance_ALL <- distance
floors_ALL <- floors
heartRate_ALL <- heartRate
steps_ALL <- steps

rm(caloriesBurned, distance, floors, heartRate, steps)

# lapply(filenamesGreet,load,.GlobalEnv)
# 
# caloriesBurned_ALL <- rbind(caloriesBurned_ALL, caloriesBurned)
# distance_ALL <- rbind(distance_ALL, distance)
# floors_ALL <- rbind(floors_ALL, floors)
# heartRate_ALL <- rbind(heartRate_ALL, heartRate)
# steps_ALL <- rbind(steps_ALL, steps)
# 
# rm(caloriesBurned, distance, floors, heartRate, steps)

caloriesBurned_ALL$user <- as.factor(caloriesBurned_ALL$user)
distance_ALL$user <- as.factor(distance_ALL$user)
floors_ALL$user <- as.factor(floors_ALL$user)
heartRate_ALL$user <- as.factor(heartRate_ALL$user)
steps_ALL$user <- as.factor(steps_ALL$user)
