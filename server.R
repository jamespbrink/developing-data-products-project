library(shiny)
library(datasets)

airData <- airquality

columns <- list("O Zone" = "Ozone", "Solar Radiation" = "Solar.R", "Wind" = "Wind", "Temperature" = "Temp")

# Define server logic
shinyServer(function(input, output, session) {
        output$predictor = renderUI({
                outc <- input$outcome
                selectInput("predict", "Predictor:", columns[-grep(outc,columns)])
        })
        
        output$slider = renderUI({
                slLabel = paste("Adjust to predict ", names(columns[grep(input$outcome,columns)]), "using this value for ", names(columns[grep(input$predict,columns)]), ":")
                slVal = round(mean(airData[,input$predict], na.rm=TRUE),0)
                slMin = round(min(airData[,input$predict], na.rm=TRUE),0)
                slMax = round(max(airData[,input$predict], na.rm=TRUE),0)
                sliderInput('slide', slLabel, value = slVal, min = slMin, max = slMax, step=1,)
        })
        
        formulaText <- reactive({
                paste(input$outcome, " ~ ", input$predict)
        })
        
        output$guess <- renderText({
                fit <- lm(as.formula(formulaText()), data=airData)
                slp <- fit$coeff[2]
                yint <- fit$coeff[1]
                predout <- round(yint + slp * input$slide,2)
                paste("Predicted outcome for ", names(columns[grep(input$outcome,columns)]), ": ", predout)
        })
        
        output$pred <- renderText({
                names(columns[grep(input$predict,columns)])
        })
        
        
        output$ioPlot <- renderPlot({
                fit <- lm(as.formula(formulaText()), data=airData)

                plot(as.formula(formulaText()), 
                        data = airData, xlab=names(columns[grep(input$predict,columns)]), ylab=names(columns[grep(input$outcome,columns)]))
                
                abline(fit, col="red")
                
                title(main= paste(names(columns[grep(input$outcome,columns)]), " vs. ", names(columns[grep(input$predict,columns)])))

        })
})