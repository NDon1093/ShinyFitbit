load("credentials.RData")
dates <- seq(as.Date("2017-01-01"), Sys.Date()-1, by="day")
progress <- 1
for(user in c("Niels")){
  if(user == "Niels") cookie <- login(email=email, password=pwd)
  ##else cookie <- login(email="greet_coppens93@gmail.com", password="pwd")
  
  incProgress(progress, detail = paste("Getting Steps for ", email))
  steps <- paste("../Data/steps", user, ".RData",sep = "")
  getSteps(user, steps, cookie)
  
  
  incProgress(progress, detail = paste("Getting HeartRate for ", email))
  hr <- paste("../Data/hr",user, ".RData",sep = "")
  getHR(user, hr, cookie)
  
  
  incProgress(progress, detail = paste("Getting Distance for ", email))
  distance <- paste("../Data/distance",user, ".RData",sep = "")
  getDist(user, distance, cookie)
  
  
  incProgress(progress, detail = paste("Getting Floors for ", email))
  floors <- paste("../Data/floors",user, ".RData",sep = "")
  getFloors(user, floors, cookie)
  
  
  incProgress(progress, detail = paste("Getting Active Minutes for ", email))
  actMin <- paste("../Data/actMin",user, ".RData",sep = "")
  getActMin(user, actMin, cookie)
  
  
  incProgress(progress, detail = paste("Getting Calories for ", email))
  cal <- paste("../Data/cal",user, ".RData",sep = "")
  getCal(user, cal, cookie)
}
rm(email,pwd)