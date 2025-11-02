# inst/shiny_app/app.R

library(shiny)
library(shinythemes)
library(ggplot2)
library(dplyr)

# Define the UI (User Interface)
ui <- fluidPage(
  # Apply a theme and link our custom CSS file
  theme = shinytheme("flatly"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),

  # App title
  titlePanel("Australian COVID-19 Quarantine Breach Explorer"),

  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for user inputs
    sidebarPanel(
      # (2 marks) Interactive input: A dropdown to select the state
      selectInput(
        inputId = "state_select",
        label = "Select a State/Territory:",
        choices = c(
          "All States",
          unique(quarantine::breaches_data$state)
        ),
        selected = "All States"
      ),
      hr(),

      # (2 marks) Description of what the fields mean
      h4("Field Descriptions"),
      p(strong("State:"), "The state or territory where the quarantine breach occurred."),
      p(strong("Date:"), "The date the breach was officially reported."),
      p(strong("Variant:"), "The COVID-19 variant associated with the breach."),
      p(strong("Onward Transmission:"), "Whether the breach led to known community transmission (TRUE/FALSE).")
    ),

    # Main panel for displaying outputs
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel(
          "Timeline Plot",
          # (2 marks) The output is changed by the interactivity
          plotOutput(outputId = "timeline_plot"),
          hr(),
          # (2 marks) Description of how to interpret the output
          h4("How to Interpret This Plot"),
          div(class = "explanation-text",
              p("This bar chart shows the number of quarantine breaches recorded each month. Use the dropdown on the left to filter the data for a specific state or view all states combined. This visualization helps to identify periods with a higher frequency of breaches.")
          )
        ),
        tabPanel(
          "Data Table",
          # The data table also changes based on the input
          DT::dataTableOutput(outputId = "breaches_table"),
          hr(),
          h4("How to Interpret This Table"),
          div(class = "explanation-text",
              p("This table displays the raw data for the selected state(s). You can use the search box to filter results further or sort columns by clicking on the headers.")
          )
        )
      )
    )
  )
)

# Define the server logic
server <- function(input, output) {

  # (1 mark) Use the dataset from your package, not read.csv
  # Create a reactive expression that filters the data based on user input
  filtered_data <- reactive({
    data <- quarantine::breaches_data

    # Do not filter if "All States" is selected
    if (input$state_select != "All States") {
      data <- data %>%
        filter(state == input$state_select)
    }
    return(data)
  })

  # (2 marks) Use interactivities to change the displayed output
  # Render the timeline plot
  output$timeline_plot <- renderPlot({

    plot_data <- filtered_data() %>%
      mutate(year_month = format(date, "%Y-%m")) %>%
      count(year_month)

    ggplot(plot_data, aes(x = year_month, y = n)) +
      geom_bar(stat = "identity", fill = "#007bff", alpha = 0.7) +
      labs(
        title = paste("Monthly Quarantine Breaches in", input$state_select),
        x = "Month",
        y = "Number of Breaches"
      ) +
      theme_minimal(base_size = 16) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  # Render the data table
  output$breaches_table <- DT::renderDataTable({
    filtered_data()
  }, options = list(pageLength = 10))
}

# Run the application
shinyApp(ui = ui, server = server)
