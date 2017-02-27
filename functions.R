
getSteps <- function(user, filename, cookie){
  steps_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="steps", as.character(x)))
  steps <- do.call(rbind, steps_day)
  steps$user <- user
  save(steps, file = filename)
}

getHR <- function(user, filename, cookie){
  hr_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="heart-rate", as.character(x)))
  heartRate <- do.call(rbind, hr_day)
  heartRate$user <- user
  save(heartRate, file = filename)
}

getFloors <- function(user, filename, cookie){
  floors_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="floors", as.character(x)))
  floors <- do.call(rbind, floors_day)
  floors$user <- user
  save(floors, file = filename)
}

getActMin <- function(user, filename, cookie){
  activeMinutes_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="active-minutes", as.character(x)))
  activeMinutes <- do.call(rbind, activeMinutes_day)
  activeMinutes$user <- user
  save(activeMinutes, file = filename)
}

getDist <- function(user, filename, cookie){
  distance_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="distance", as.character(x)))
  distance <- do.call(rbind, distance_day)
  distance$user <- user
  save(distance, file = filename)
}


getCal <- function(user, filename, cookie){
  caloriesBurned_day <- lapply(dates, function(x)
    get_intraday_data(cookie=cookie, what="calories-burned", as.character(x)))
  caloriesBurned <- do.call(rbind, caloriesBurned_day)
  caloriesBurned$user <- user
  save(caloriesBurned, file = filename)
}

getMaxDate <- function(){
  load("stepsNiels.RData")
  return(max(steps$time))
}

