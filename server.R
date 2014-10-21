library(shiny)
library(datasets)

#import dataset
airData <- airquality

#make list of columns for dropdowns
columns <- list("O Zone" = "Ozone", "Solar Radiation" = "Solar.R", "Wind" = "Wind", "Temperature" = "Temp")

# Define server logic
shinyServer(function(input, output, session) {
        
        #set dropdown so it only shows 3 remaining columns, won't compare a variable to itself
        output$predictor = renderUI({
                outc <- input$outcome
                selectInput("predict", "Predictor:", columns[-grep(outc,columns)])
        })
        
        #setup the slider for the current selections, default to mean, set max and min to the observed max and min
        output$slider = renderUI({
                slLabel = paste("Adjust to predict ", names(columns[grep(input$outcome,columns)]), "using this value for ", names(columns[grep(input$predict,columns)]), ":")
                slVal = round(mean(airData[,input$predict], na.rm=TRUE),0)
                slMin = round(min(airData[,input$predict], na.rm=TRUE),0)
                slMax = round(max(airData[,input$predict], na.rm=TRUE),0)
                sliderInput('slide', slLabel, value = slVal, min = slMin, max = slMax, step=1,)
        })
        
        #create formula for plot
        formulaText <- reactive({
                paste(input$outcome, " ~ ", input$predict)
        })
        
        #create text for prediction
        output$guess <- renderText({
                fit <- lm(as.formula(formulaText()), data=airData)
                slp <- fit$coeff[2]
                yint <- fit$coeff[1]
                predout <- round(yint + slp * input$slide,2)
                paste("Predicted outcome for ", names(columns[grep(input$outcome,columns)]), ": ", predout)
        })
        
        #create plot and fitted line
        output$ioPlot <- renderPlot({
                fit <- lm(as.formula(formulaText()), data=airData)
                plot(as.formula(formulaText()), 
                        data = airData, xlab=names(columns[grep(input$predict,columns)]), ylab=names(columns[grep(input$outcome,columns)]))
                abline(fit, col="red")
                title(main= paste(names(columns[grep(input$outcome,columns)]), " vs. ", names(columns[grep(input$predict,columns)])))
        })
})