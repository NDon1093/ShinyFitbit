## app.R ##
library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(ggvis)
library(googleVis)
library(dplyr)

ui <- dashboardPage(
  dashboardHeader(title="Fitbit Dashboard",
                  dropdownMenu(type = "messages",
                               messageItem(
                                 from = "Login",
                                 message = textInput("email","")
                               ),
                               messageItem(
                                 from = "Password",
                                 message = passwordInput("password","")
                                 
                               )
                  )),
  dashboardSidebar(
    sidebarMenu(
      # Dashboard icon
      menuItem("Lifetime dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Dashboard", tabName = "development"),
      
      # Get all data
      div(style="display:inline-block;width:48%;text-align: center;",
          actionButton("getData", label = "Get all data",width = "88%")
          ),
      # Render charts
      div(style="display:inline-block;width:48%;text-align: center;",
          actionButton("render", label = "Render",width = "88%")
          ),
      
      # Daterange input
      dateRangeInput('dateRange',
                     label = 'Date range input:',
                     start = Sys.Date() - 2, end = Sys.Date() + 2
      ),
      # next input
      div(style="display:inline-block;width:95%;text-align: center;padding-left:8px",
          actionButton("run","Run", width = "95%")
          )
    )
  ),
  dashboardBody(
    tabItems(
      # First tab dashboard
      tabItem(tabName = "dashboard",
              fluidRow(
                  infoBoxOutput("stepsNiels", width = 3),
                  infoBoxOutput("floorsNiels", width = 3),
                  infoBoxOutput("heartrateNiels", width = 3),
                  infoBoxOutput("caloriesNiels", width = 3)
              ),
              fluidRow(
                infoBoxOutput("stepsGreet"),
                infoBoxOutput("floorsGreet"),
                infoBoxOutput("heartrateGreet")
              ),
              
              ## werken met renderUI hiervoor....
              fluidRow(
                box(title="Steps", solidHeader = T, collapsible = T, status = "primary",
                  plotlyOutput("heatmap"), width = 6
                ),
                box(title="Floors", solidHeader = T, collapsible = T, status = "primary",
                  #htmlOutput("floorsBarChart")
                  plotlyOutput("floorsBarChart")
                  , width = 6
                )
              ),
              fluidRow(
                box(title="Heartrate", solidheader = T, collapsible = T, status = "primary",
                  htmlOutput("heartRateLineChart")
                  , width = 12
                )
              )
      ), # end of tab dashboard
      
      # Second tab content
      tabItem(tabName = "development",
              fluidRow(
                box(
                  
                )
              )
      ) # end of tab development
    )
  )
)

server <- function(input, output) { 
  #####################################################################
  ## Data
  #####################################################################
  observeEvent(input$getData, {
    withProgress(message = 'Getting the data',
                 detail = 'This may take a while...', min=0, max=13, {
      #install.packages("fitbitScraper")
      library(fitbitScraper)
      
      source("functions.R")
      
      email <- input$email
      pwd <- input$password
      save(email, pwd,file="credentials.RData")
      
      source("getData.R")
      
      source("processData.R")
      
      #data <- reactiveValues()
    })
  })
  
  data_heatmap <- reactive({
    ## Prep data for heatmap
    steps_ALL %>%
      mutate(date_hour = format(time,"%Y-%m-%d %H")) %>%
      group_by(date_hour) %>% summarise(sum=sum(steps)) %>%
      mutate(date = as.POSIXct(substr(date_hour,0,10))) %>%
      mutate(weekday = format(date,"%A")) %>%
      mutate(weekday = factor(weekday,levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))) %>%
      mutate(hour = substr(date_hour,12,13)) %>%
      group_by(weekday,hour) %>% summarise(avg=mean(sum))
  })
  
  data_barchart <- reactive({
    ## Prep data for bar chart
    floors_ALL %>%
      mutate(weekday = format(time, "%A")) %>%
      mutate(date = format(time, "%Y-%m-%d")) %>%
      group_by(date) %>% summarise(sum=sum(floors)) %>%
      mutate(date = as.POSIXct(date)) %>%
      mutate(weekday = format(date,"%A")) %>%
      group_by(weekday) %>% summarise(mean=mean(sum)) %>%
      mutate(weekday = factor(weekday, levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")))
  })
  
  data_infoBox_Calories <- reactive({
    caloriesBurned_ALL %>%
      mutate(date = format(time, "%Y-%m-%d")) %>%
      group_by(date) %>% summarise(calories=sum(`calories-burned`))
  })
  
  
  #####################################################################
  
  
  #####################################################################
  ## Charts
  #####################################################################
  observeEvent(input$run,{
    showNotification("Building charts", type = "message")
     ## Heatmap steps
     output$heatmap <- renderPlotly(
       plot_ly(
         data = data_heatmap(), 
         x=data_heatmap()$hour,
         y=data_heatmap()$weekday,
         z=data_heatmap()$avg, 
         type = "heatmap"
       )
     )
     
     ## Heartrate timeline
     output$heartRateLineChart <- renderGvis(
       gvisAnnotationChart(subset(heartRate_ALL,bpm != 0), "time", "bpm",
                           date.format = "%Y-%m-%d %h:%m:%s",
                           options=list(
                             displayAnnotations=TRUE, legendPosition='newRow', width="90%", height = "500px"
                           )
       )
     )
     
     ## Avg floors per weekday
     # output$floorsBarChart <- renderGvis(
     #   gvisBarChart(data_barchart(), "weekday","mean", options = list(width="90%", height = "500px"))
     # )
     output$floorsBarChart <- renderPlotly(
       plot_ly(
         data_barchart(),
         x=~weekday,
         y=~mean,
         type = "bar"
       )
     )
     
     
    }
  )
  
  #####################################################################
  
  observeEvent(input$render, {
    #####################################################################
    ## Infoboxes
    #####################################################################
    ## infobox steps
    output$stepsNiels <- renderInfoBox(
      infoBox(
        "Lifetime Steps", sum(subset(steps_ALL,user=="Niels",select=steps)), icon = icon("blind"),
        color = "blue"
      )
    )
    
    ## infobox floors
    output$floorsNiels <- renderInfoBox(
      infoBox(
        "Lifetime Floors", sum(subset(floors_ALL,user=="Niels",select=floors)), icon = icon("rocket"),
        color = "green"
      )
    )
    
    ## infobox heartrate
    output$heartrateNiels <- renderInfoBox(
      infoBox(
        "Average Heart Rate", round(mean(subset(heartRate_ALL,user=="Niels" & bpm > 0)$bpm, na.rm = T),2), icon = icon("heartbeat"),
        color = "red"
      )
    )
    
    ## infobox calories
    output$caloriesNiels <- renderInfoBox(
      infoBox(
        "Average Calories", round(mean(data_infoBox_Calories()$calories,na.rm=T),2), icon = icon("fire"),
        color = "orange"
      )
    )

  })
  
  
  output$currentSteps <- renderInfoBox(
    #input$run,
    infoBox(
      paste("Steps on " + input$date), sum(steps[steps$time == input$date,steps]), icon = icon("blind"),
      color = "blue"
    )
  )
  #####################################################################
}

shinyApp(ui, server)