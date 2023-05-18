library(shiny)
library(ggplot2)
library(DT)


# Define UI
ui <- 
  fluidPage(
    titlePanel("Dashboard"),
    sidebarLayout(
      sidebarPanel(
        downloadButton("table_download", "Download table"),
        br(),
        downloadButton("plot_download", "Download Plot"),
        br(),
        actionButton("doc_download", "Download Document Type")
        
      ),
      mainPanel(
        tabsetPanel(
          # tabPanel("photo",tags$img(src = "images.jpg",width = "980px",height = "600px")),
          tabPanel("Table", DTOutput("table")),
          tabPanel("Plot", plotOutput("plot")),
          tabPanel("Doc", textOutput("doc"))
        )
      )
      
    )
  )



# Define server
server <- function(input, output, session) {
  
  data <- read.csv("C://Users//FL_LPT-194//Documents//R//Download_button_Task//IPL_winners.csv")
  
  # Generate table
  output$table <- renderDT({
    datatable(data)
  })
  
  # Generate plot
  output$plot <- renderPlot({
    ggplot(data, aes(x = YEAR, y = WINNERS)) + geom_point()
  })
  
  # Display document in main panel
  output$doc <- renderText({
    doc <- readLines("C://Users//FL_LPT-194//Documents//R//Download_button_Task//Analysis_of_IPL.html")
    paste(doc, collapse = "\n")
  })
  
  # Download table
  output$table_download <- downloadHandler(
    filename = "table.csv",
    content = function(file) {
      write.csv(data, file)
    }
  )
  
  # Download plot
  output$plot_download <- downloadHandler(
    filename = "plot.png",
    content = function(file) {
      ggsave(file, ggplot(data, aes(x = YEAR, y = WINNERS)) + geom_point(),device = "png")
    }
  )
 
  
  
  # Download document
  output$doc_download <- downloadHandler(
    filename = "Analysis",
    content = function(file) {
      permanemt_report <- file.path(tempdir(), "Analysis_of_IPL.Rmd")
      file.copy("Analysis_of_IPL.Rmd", permanemt_report, overwrite = TRUE)
      rmarkdown::render( permanemt_report,output_file = file,output_format = "document"
      )
    }
  )
  
  observeEvent(input$doc_download, {
    showModal(modalDialog(
      title = "Download Modal",
      tags$div(
        downloadButton("download_html", "Download Html"),
        downloadButton("download_pdf", "Download Pdf"),
        downloadButton("download_word", "Download Word"),
      ),
      footer = modalButton("Close"),
      # easyClose = TRUE
    ))
  })
  
  output$download_html <- downloadHandler(
    filename = "Analysis.html",
    content = function(file) {
      rmarkdown::render("Analysis_of_IPL.Rmd",output_format = "html_document", output_file = file)
    }
  )
  
  
  
  output$download_pdf <- downloadHandler(
    filename = "Analysis.pdf",
    content = function(file) {
      rmarkdown::render("Analysis_of_IPL.Rmd", output_format = "pdf_document", output_file = file)
    }
  )
  
  
  
  
  output$download_word <- downloadHandler(
    filename = "Analysis.docx",
    content = function(file) {
      rmarkdown::render("Analysis_of_IPL.Rmd", output_format = "word_document", output_file = file)
    }
  )
  
}

shinyApp(ui,server)