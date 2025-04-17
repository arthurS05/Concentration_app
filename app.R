# — Libraries & Data Loading — ----------------------------------------------
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)

data_dir <- "path_to_your_data_directory"

df_data_init <- read.csv(file.path(data_dir, "all_data.csv"), header = TRUE, sep = ";")
list_all     <- read.csv(file.path(data_dir, "list_all.csv"), header = TRUE, sep = ";")
list_df0      <- list_df0[list_df0$Type == 'Injection', ]
list_df       <- list_df0

# — Constants & Parameters — -------------------------------------------
# Flow and gas constants
flx                <- 4.66       # device flow (ml/s)
R                  <- 0.082      # ideal gas constant

# CH₄ parameters
multiplicateur_CH4 <- 1e9        # to convert from mol to ppb
Beta_henry_CH4     <- 1700       # beta Henry coeff. for CH4
K_henry_CH4        <- 0.0014     # k Henry coeff. for CH4

# CO₂ parameters
multiplicateur_CO2 <- 1e6        # to convert from mol to ppm
Beta_henry_CO2     <- 2400       # beta Henry coeff. for CO2
K_henry_CO2        <- 0.034      # k Henry coeff. for CO2

# Other physical constants
molar_volume       <- 23         # molar volume of ideal gas (L/mol)
molar_volume       <- 23         # molar volume of ideal gas at STP (L/mol)
T_ref_C            <- 25         # reference temperature (°C) for Henry’s law
C_TO_K             <- 273.15     # offset to convert °C to K
T_ref_K            <- C_TO_K + T_ref_C  # reference temperature in Kelvin (298.15 K)

nb_value_mean      <- 5 # number of value before the select time fore the baseline mean

ui <- dashboardPage(
  dashboardHeader(title = "LI‑COR Data Processor"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Process Samples", tabName = "proc", icon = icon("flask"))
    ),
    hr(),
    actionButton("nextButton", "Next Sample", icon = icon("arrow-right"), width = "100%")
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "proc",
              
              ## Current sample number and notebook date/time
              fluidRow(
                valueBoxOutput("currentSample", width = 6),
                valueBoxOutput("currentTime",   width = 6)
              ),
              
              ## Tabs for CH₄ and CO₂
              tabBox(width = 12,
                     
                     ### CH₄ Tab
                     tabPanel("CH₄",
                              
                              ## Around the injection start
                              fluidRow(
                                box(
                                  title = "Around Start", status = "primary", solidHeader = TRUE, width = 4,
                                  DTOutput("data_table1")
                                ),
                                box(
                                  title = "Start Plot", status = "primary", solidHeader = TRUE, width = 8,
                                  plotOutput("plot_begin", click = "plot_click_begin")
                                )
                              ),
                              
                              ## Display chosen start time
                              fluidRow(
                                box(
                                  title = "Chosen Start Time", status = "info", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info")
                                )
                              ),
                              
                              ## Seconds after start input
                              fluidRow(
                                column(width = 4,
                                       numericInput("x_max", "CH₄: seconds after start", 100, min = 1, width = "100%")
                                )
                              ),
                              
                              ## After Start and Global Injection plots
                              fluidRow(
                                box(
                                  title = "After Start", status = "info", solidHeader = TRUE, width = 4,
                                  DTOutput("data_table2")
                                ),
                                box(
                                  title = "Global Injection", status = "info", solidHeader = TRUE, width = 8,
                                  plotOutput("plot_end1", height = "300px")
                                )
                              ),
                              
                              ## Difference from mean plot
                              fluidRow(
                                box(
                                  title = "Diff from Mean", status = "info", solidHeader = TRUE, width = 12,
                                  plotOutput("plot_end2", click = "plot_click_end", height = "300px")
                                )
                              ),
                              
                              ## Display chosen end time
                              fluidRow(
                                box(
                                  title = "Chosen End Time", status = "info", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info2")
                                )
                              ),
                              
                              ## Final summary for CH₄
                              fluidRow(
                                box(
                                  title = "Summary", status = "warning", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info3")
                                )
                              )
                     ),
                     
                     ### CO₂ Tab
                     tabPanel("CO₂",
                              
                              ## Around the injection start for CO₂
                              fluidRow(
                                box(
                                  title = "Around Start", status = "primary", solidHeader = TRUE, width = 4,
                                  DTOutput("data_table_CO2")
                                ),
                                box(
                                  title = "Start Plot", status = "primary", solidHeader = TRUE, width = 8,
                                  plotOutput("plot_begin_CO2", click = "plot_click_begin_CO2")
                                )
                              ),
                              
                              ## Display chosen start time for CO₂
                              fluidRow(
                                box(
                                  title = "Chosen Start Time (CO₂)", status = "info", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info_CO2")
                                )
                              ),
                              
                              ## Seconds after start input for CO₂
                              fluidRow(
                                column(width = 4,
                                       numericInput("x_max_CO2", "CO₂: seconds after start", 100, min = 1, width = "100%")
                                )
                              ),
                              
                              ## After Start and Global Injection plots for CO₂
                              fluidRow(
                                box(
                                  title = "After Start", status = "info", solidHeader = TRUE, width = 4,
                                  DTOutput("data_table2_CO2")
                                ),
                                box(
                                  title = "Global Injection", status = "info", solidHeader = TRUE, width = 8,
                                  plotOutput("plot_end1_CO2", height = "300px")
                                )
                              ),
                              
                              ## Difference from mean plot for CO₂
                              fluidRow(
                                box(
                                  title = "Diff from Mean", status = "info", solidHeader = TRUE, width = 12,
                                  plotOutput("plot_end2_CO2", click = "plot_click_end_CO2", height = "300px")
                                )
                              ),
                              
                              ## Display chosen end time for CO₂
                              fluidRow(
                                box(
                                  title = "Chosen End Time (CO₂)", status = "info", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info2_CO2")
                                )
                              ),
                              
                              ## Final summary for CO₂
                              fluidRow(
                                box(
                                  title = "Summary", status = "warning", solidHeader = TRUE, width = 12,
                                  verbatimTextOutput("info3_CO2")
                                )
                              )
                     )
                     
              ), # /tabBox
              fluidRow(
                column(width = 8,
                       textInput("sample_comment", "Comment", value = "", placeholder = "Enter a comment for this sample…")
                )
              ),
              ## Save results button
              fluidRow(
                column(width = 4,
                       actionButton("button_save", "Save Results", icon = icon("floppy-disk"), width = "100%")
                )
              ),
              
              ## Final saved results table
              fluidRow(
                box(
                  title = "All Saved Results", status = "success", solidHeader = TRUE, width = 12,
                  DTOutput("data_tablefin")
                )
              )
              
      ) # /tabItem proc
    ) # /tabItems
  ) # /dashboardBody
) # /dashboardPage



# — Server — -------------------------------------------------
server <- function(input, output, session) {
  # Utility for bounded sequence
  safe_seq <- function(pos, before, after, maxn) {
    start <- max(1, pos - before)
    end   <- min(maxn, pos + after)
    seq(start, end)
  }
  
  # Reactive values & parameters
  text    <- reactiveValues(value = NULL)
  counter <- reactiveValues(value = 0)
  maxLine <- nrow(list_df)
  findf   <- reactiveValues(
    data1 = data.frame(
      Files = character(),
      Lake  = character(),
      Type  = character(),
      Name  = character(),
      remark    = character(),
      Name_LICOR= character(),
      date  = character(),
      H_list= character(),
      Temp  = character(),
      Vliq  = character(),
      Vgaz  = character(),
      Vinject = character(),
      Gaz   = character(),
      H_begin  = character(),
      H_end    = character(),
      Mean  = numeric(),
      Integ = numeric(),
      C_gaz = numeric(),
      Henry = numeric(),
      C_water = numeric(),
      Comment  = character(),
      stringsAsFactors = FALSE
    )
  )
  
  # Prepare CH4 & CO2 data
  df0_step1 <- df_data_init[-c(1:4,6), ]
  colnames(df0_step1) <- df0_step1[1, ]
  df0_step2 <- df0_step1[-1, ]
  gazname_CH4 <- "CH4"
  gazname_CO2 <- "CO2"
  
  df_data_CH4 <- df0_step2[, c("DATE","TIME", gazname_CH4)]
  df_data_CH4[[gazname_CH4]] <- as.numeric(df_data_CH4[[gazname_CH4]])
  n_CH4 <- nrow(df_data_CH4)
  col_CH4 <- which(colnames(df_data_CH4)==gazname_CH4)
  
  df_data_CO2 <- df0_step2[, c("DATE","TIME", gazname_CO2)]
  df_data_CO2[[gazname_CO2]] <- as.numeric(df_data_CO2[[gazname_CO2]])
  n_CO2 <- nrow(df_data_CO2)
  col_CO2 <- which(colnames(df_data_CO2)==gazname_CO2)
  
  start_time_CH4 <- reactiveValues(value = NULL)
  mean_CH4     <- reactiveValues(value = NULL)
  end_time_CH4   <- reactiveValues(value = NULL)
  vecfin_CH4      <- reactiveValues(value = NULL)
  
  start_time_CO2 <- reactiveValues(value = NULL)
  mean_CO2     <- reactiveValues(value = NULL)
  end_time_CO2   <- reactiveValues(value = NULL)
  vecfin_CO2      <- reactiveValues(value = NULL)
  
  # Current sample and time display
  output$currentSample <- renderValueBox({
    valueBox(counter$value,text$value[4], "Current Sample #", icon = icon("list"), color = "purple")
  })
  output$currentTime <- renderValueBox({
    req(text$value)
    valueBox(paste(text$value[7], text$value[8]), "Notebook Date & Time", icon = icon("clock"), color = "maroon")
  })
  
  # Advance to next sample
  observeEvent(input$nextButton, {
    if (counter$value < maxLine) {
      counter$value <- counter$value + 1
      text$value    <- as.character(list_df[counter$value, ])
      
      # reset all reactive values for CH4 & CO2
      start_time_CH4$value <- NULL
      mean_CH4$value       <- NULL
      end_time_CH4$value   <- NULL
      vecfin_CH4$value     <- NULL
      
      start_time_CO2$value <- NULL
      mean_CO2$value       <- NULL
      end_time_CO2$value   <- NULL
      vecfin_CO2$value     <- NULL
      
      # reset the comment input as well
      updateTextInput(session, "sample_comment", value = "")
    }
  })
  
  # ---------- CH4 First Selection Table ----------
  output$data_table1 <- renderDT({
    req(counter$value > 0)
    DAY  <- text$value[7]
    TIME <- text$value[8]
    pos1  <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == TIME)
    validate(need(length(pos1) == 1, "No matching row"))
    idx   <- safe_seq(pos1, 20, 20, n_CH4)
    df1   <- df_data_CH4[idx, ]
    
    # default value if not yet clicked
    sel <- if (!is.null(input$plot_click_begin$x)) {
      round(input$plot_click_begin$x)
    } else {
      1
    }
    
    datatable(
      df1,
      selection = list(mode = "single", target = "row", selected = sel),
      options   = list(pageLength = 10)
    )
  })
  
  # ---------- CH4 First Selection Plot ----------
  output$plot_begin <- renderPlot({
    req(counter$value > 0)
    DAY <- text$value[7]; TIME <- text$value[8]
    pos1 <- which(df_data_CH4$DATE==DAY & df_data_CH4$TIME==TIME)
    validate(need(length(pos1)==1, ""))
    idx  <- safe_seq(pos1,20,20,n_CH4)
    df1  <- df_data_CH4[idx, ]
    ggplot(df1, aes(x=TIME, y=df1[[col_CH4]])) +
      geom_point() +
      scale_x_discrete(guide=guide_axis(check.overlap=TRUE)) +
      labs(title=paste("First selection:", gazname_CH4)) +
      theme_light()
  })
  
  # ---------- CH4 Compute Baseline & Start Time ----------
  output$info <- renderText({
    req(counter$value > 0, !is.null(input$plot_click_begin$x))
    DAY <- text$value[7]; TIME <- text$value[8]
    pos1 <- which(df_data_CH4$DATE==DAY & df_data_CH4$TIME==TIME)
    idx  <- safe_seq(pos1,20,20,n_CH4)
    df1  <- df_data_CH4[idx, ]
    sel  <- round(input$plot_click_begin$x)
    tb   <- as.character(df1$TIME[sel])
    start_time_CH4$value <- tb
    
    pm            <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == tb)
    limlow_mean   <- pm - nb_value_mean
    limhigh_mean  <- pm - 1
    df_mean       <- df_data_CH4[limlow_mean:limhigh_mean, col_CH4]
    mv            <- mean(df_mean)
    mean_CH4$value <- mv
    
    paste("Start:", tb, "Baseline mean:", round(mv,3))
  })
  
  # ---------- CH4 After-Start Table ----------
  output$data_table2 <- renderDT({
    req(start_time_CH4$value, input$x_max)
    DAY  <- text$value[7]
    start <- start_time_CH4$value
    pd    <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == start)
    idx   <- safe_seq(pd, 0, input$x_max, n_CH4)
    dfr   <- df_data_CH4[idx, ]
    tail40<- tail(dfr, 40)
    tail40$vecdif <- tail40[[col_CH4]] - mean_CH4$value
    
    #  prevent crashes if plot_end2 hasn't been clicked yet
    sel <- if (!is.null(input$plot_click_end$x)) {
      round(input$plot_click_end$x)
    } else {
      1
    }
    
    datatable(
      tail40,
      selection = list(mode = "single", target = "row", selected = sel),
      options   = list(pageLength = 10)
    )
  })
  
  # ---------- CH4 Global Injection Plot ----------
  output$plot_end1 <- renderPlot({
    req(start_time_CH4$value, input$x_max)
    DAY   <- text$value[7]
    start <- start_time_CH4$value
    pd    <- which(df_data_CH4$DATE==DAY & df_data_CH4$TIME==start)
    df2   <- df_data_CH4[safe_seq(pd,0,input$x_max,n_CH4), ]
    df2$vecdif <- df2[[col_CH4]] - mean_CH4$value
    ggplot(df2, aes(x=TIME, y=df2[[col_CH4]])) +
      geom_point(col=ifelse(df2$vecdif>=0,"blue","red")) +
      labs(title=paste(gazname_CH4,"global injection")) +
      theme_light() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
  
  # ---------- CH4 Diff-from-Mean Plot ----------
  output$plot_end2 <- renderPlot({
    req(start_time_CH4$value, input$x_max)  # remove requirement on input$plot_click_end
    DAY  <- text$value[7]
    start <- start_time_CH4$value
    pd    <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == start)
    df2   <- df_data_CH4[safe_seq(pd, 0, input$x_max, n_CH4), ]
    tail40<- tail(df2, 40)
    tail40$vecdif <- tail40[[col_CH4]] - mean_CH4$value
    
    ggplot(tail40, aes(x = TIME, y = vecdif)) +
      geom_point(col = ifelse(tail40$vecdif >= 0, "blue", "red")) +
      labs(title = "Last 40 values diff from mean") +
      theme_light()
  })
  
  # ---------- CH4 Record End Time ----------
  output$info2 <- renderText({
    req(input$plot_click_end, start_time_CH4$value)
    DAY <- text$value[7]
    start<- start_time_CH4$value
    pd   <- which(df_data_CH4$DATE==DAY & df_data_CH4$TIME==start)
    tail40<- tail(df_data_CH4[safe_seq(pd,0,input$x_max,n_CH4), ], 40)
    tail40$vecdif<- tail40[[col_CH4]] - mean_CH4$value
    sel <- round(input$plot_click_end$x)
    te  <- as.character(tail40$TIME[sel])
    end_time_CH4$value <- te
    te
  })
  
  # ---------- CH4 Final Summary ----------
  output$info3 <- renderText({
    # as soon as either is NULL, show nothing
    if (is.null(start_time_CH4$value) || is.null(end_time_CH4$value)) {
      return("")  
    }
    
    DAY <- text$value[7]
    pd  <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == start_time_CH4$value)
    pe  <- which(df_data_CH4$DATE == DAY & df_data_CH4$TIME == end_time_CH4$value)
    df5 <- df_data_CH4[safe_seq(pd, 0, pe-pd, n_CH4), ]
    df5$vecdif <- df5[[col_CH4]] - mean_CH4$value
    
    integ   <- sum(df5$vecdif)
    Cg      <- ((integ*(flx/as.numeric(text$value[12]))) + mean_CH4$value) / 1000
    Cg_good <- (Cg/multiplicateur_CH4) / molar_volume
    Henry   <- 1 / (1.013 * R *
                      (as.numeric(text$value[9])+C_TO_K) * K_henry_CH4 *
                      exp(Beta_henry_CH4 * ((1/(as.numeric(text$value[9])+C_TO_K)) -
                                              (1/T_ref_K))))
    Cw      <- ((Cg_good * as.numeric(text$value[11])) +
                  ((Cg_good / Henry) * as.numeric(text$value[10]))) /
      as.numeric(text$value[10])
    
    # store for saving
    vecfin_CH4$value <- c(
      text$value, gazname_CH4,
      start_time_CH4$value, end_time_CH4$value,
      mean_CH4$value, integ, Cg_good, Henry, Cw
    )
    
    paste0(
      "Date: ", DAY, "\n",
      "Start: ", start_time_CH4$value, "\n",
      "End: ",   end_time_CH4$value,   "\n",
      "Integral: ", round(integ,3),    "\n",
      "Cg (mol/mL): ", signif(Cg_good,4), "\n",
      "Henry: ",      signif(Henry,4),   "\n",
      "Cw (mol/mL): ",signif(Cw,4)
    )
  })
  # ---------- CO₂ First Selection Table ----------
  output$data_table_CO2 <- renderDT({
    req(counter$value > 0)
    DAY  <- text$value[7]
    TIME <- text$value[8]
    pos1  <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == TIME)
    validate(need(length(pos1) == 1, "No matching row for CO₂"))
    idx   <- safe_seq(pos1, 20, 20, n_CO2)
    df1   <- df_data_CO2[idx, ]
    
    sel <- if (!is.null(input$plot_click_begin_CO2$x)) {
      round(input$plot_click_begin_CO2$x)
    } else {
      1
    }
    
    datatable(
      df1,
      selection = list(mode = "single", target = "row", selected = sel),
      options   = list(pageLength = 10)
    )
  })
  # ---------- CO₂ First Selection Plot ----------
  output$plot_begin_CO2 <- renderPlot({
    req(counter$value > 0)
    DAY  <- text$value[7]
    TIME <- text$value[8]
    pos1  <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == TIME)
    validate(need(length(pos1) == 1, ""))
    idx   <- safe_seq(pos1, 20, 20, n_CO2)
    df1   <- df_data_CO2[idx, ]
    ggplot(df1, aes(x = TIME, y = df1[[col_CO2]])) +
      geom_point() +
      scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
      labs(title = paste("First selection:", gazname_CO2)) +
      theme_light()
  })
  
  # ---------- CO₂ Compute Baseline & Start Time ----------
  output$info_CO2 <- renderText({
    req(counter$value > 0, !is.null(input$plot_click_begin_CO2$x))
    DAY <- text$value[7]
    TIME <- text$value[8]
    pos1 <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == TIME)
    idx  <- safe_seq(pos1, 20, 20, n_CO2)
    df1  <- df_data_CO2[idx, ]
    sel  <- round(input$plot_click_begin_CO2$x)
    tb   <- as.character(df1$TIME[sel])
    start_time_CO2$value <- tb

    pm            <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == tb)
    limlow_mean   <- pm - nb_value_mean
    limhigh_mean  <- pm - 1
    df_mean       <- df_data_CO2[limlow_mean:limhigh_mean, col_CO2]
    mv            <- mean(df_mean)
    mean_CO2$value <- mv
    
    paste("Start:", tb, "Baseline mean:", round(mv, 3))
  })
  
  # ---------- CO₂ After‑Start Table ----------
  output$data_table2_CO2 <- renderDT({
    req(start_time_CO2$value, input$x_max_CO2)
    DAY  <- text$value[7]
    start <- start_time_CO2$value
    pd    <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == start)
    idx   <- safe_seq(pd, 0, input$x_max_CO2, n_CO2)
    dfr   <- df_data_CO2[idx, ]
    tail40 <- tail(dfr, 40)
    tail40$vecdif <- tail40[[col_CO2]] - mean_CO2$value
    
    # default selection if the end plot hasn't been clicked yet
    sel <- if (!is.null(input$plot_click_end_CO2$x)) {
      round(input$plot_click_end_CO2$x)
    } else {
      1
    }
    
    datatable(
      tail40,
      selection = list(mode = "single", target = "row", selected = sel),
      options   = list(pageLength = 10)
    )
  })
  
  # ---------- CO₂ Global Injection Plot ----------
  output$plot_end1_CO2 <- renderPlot({
    req(start_time_CO2$value, input$x_max_CO2)
    DAY   <- text$value[7]
    start <- start_time_CO2$value
    pd    <- which(df_data_CO2$DATE==DAY & df_data_CO2$TIME==start)
    df2   <- df_data_CO2[safe_seq(pd,0,input$x_max_CO2,n_CO2), ]
    df2$vecdif <- df2[[col_CO2]] - mean_CO2$value
    ggplot(df2, aes(x=TIME, y=df2[[col_CO2]])) +
      geom_point(col=ifelse(df2$vecdif>=0,"blue","red")) +
      labs(title=paste(gazname_CO2,"global injection")) +
      theme_light() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
  
  # ---------- CO₂ Diff‑from‑Mean Plot ----------
  output$plot_end2_CO2 <- renderPlot({
    req(start_time_CO2$value, input$x_max_CO2)
    DAY  <- text$value[7]
    start <- start_time_CO2$value
    pd    <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == start)
    df2   <- df_data_CO2[safe_seq(pd, 0, input$x_max_CO2, n_CO2), ]
    tail40 <- tail(df2, 40)
    tail40$vecdif <- tail40[[col_CO2]] - mean_CO2$value
    
    ggplot(tail40, aes(x = TIME, y = vecdif)) +
      geom_point(col = ifelse(tail40$vecdif >= 0, "blue", "red")) +
      labs(title = "Last 40 values diff from mean (CO₂)") +
      theme_light()
  })
  
  # ---------- CO₂ Record End Time ----------
  output$info2_CO2 <- renderText({
    req(input$plot_click_end_CO2, start_time_CO2$value)
    DAY <- text$value[7]
    start <- start_time_CO2$value
    pd    <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == start)
    tail40 <- tail(df_data_CO2[safe_seq(pd, 0, input$x_max_CO2, n_CO2), ], 40)
    tail40$vecdif <- tail40[[col_CO2]] - mean_CO2$value
    sel <- round(input$plot_click_end_CO2$x)
    te  <- as.character(tail40$TIME[sel])
    end_time_CO2$value <- te
    te
  })
  
  # ---------- CO₂ Final Summary ----------
  output$info3_CO2 <- renderText({
    # as soon as either is NULL, show nothing
    if (is.null(start_time_CH4$value) || is.null(end_time_CH4$value)) {
      return("")  
    }
    DAY  <- text$value[7]
    start <- start_time_CO2$value
    end   <- end_time_CO2$value
    
    # Populate vecfin_CO2$value correctly
    pd <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == start)
    pe <- which(df_data_CO2$DATE == DAY & df_data_CO2$TIME == end)
    df5 <- df_data_CO2[safe_seq(pd, 0, pe - pd, n_CO2), ]
    df5$vecdif <- df5[[col_CO2]] - mean_CO2$value
    
    integ    <- sum(df5$vecdif)
    Cg       <- ((integ * (flx / as.numeric(text$value[12]))) + mean_CO2$value) / 1000
    Cg_good  <- (Cg / multiplicateur_CO2) / molar_volume
    Henry    <- 1 / (1.013 * R * (as.numeric(text$value[9]) + C_TO_K) * K_henry_CO2 *
                       exp(Beta_henry_CO2 * ((1 / (as.numeric(text$value[9]) + C_TO_K)) - (1 / T_ref_K))))
    Cw       <- ((Cg_good * as.numeric(text$value[11])) +
                   ((Cg_good / Henry) * as.numeric(text$value[10]))) /
      as.numeric(text$value[10])
    
    # Slice the CO₂ sequence
    vecfin_CO2$value <- c(
      text$value, gazname_CO2,
      start, end,
      mean_CO2$value,
      integ, Cg_good, Henry, Cw
    )
    
    paste0(
      "Date: ", DAY, "\n",
      "Start: ", start, "\n",
      "End: ", end, "\n",
      "Integral: ", round(integ, 3), "\n",
      "Cg (mol/mL): ", signif(Cg_good, 4), "\n",
      "Henry: ", signif(Henry, 4), "\n",
      "Cw (mol/mL): ", signif(Cw, 4)
    )
  })
  
  
  
  # Finally, save both CH4 & CO2 rows when pressing Save
  observeEvent(input$button_save, {
    # Vérifier que CH4 & CO2 ont été sélectionnés
    if (is.null(vecfin_CH4$value) || is.null(vecfin_CO2$value)) {
      showNotification(
        "Please select both CH₄ and CO₂ start & end times before saving.",
        type = "error", duration = 5
      )
      return()
    }
    
    # On récupère le commentaire
    user_comment <- input$sample_comment
    
    # --- préparer la ligne CH4 (20 valeurs + 1 commentaire) ---
    row_CH4 <- c(vecfin_CH4$value, user_comment)
    y1 <- as.data.frame(t(row_CH4), stringsAsFactors = FALSE)
    names(y1) <- names(findf$data1)   # 21 noms pour 21 colonnes
    
    # --- pareil pour CO2 ---
    row_CO2 <- c(vecfin_CO2$value, user_comment)
    y2 <- as.data.frame(t(row_CO2), stringsAsFactors = FALSE)
    names(y2) <- names(findf$data1)
    
    # Conversion des colonnes numériques
    num_cols <- c("Mean", "Integ", "C_gaz", "Henry", "C_water")
    y1[num_cols] <- lapply(y1[num_cols], as.numeric)
    y2[num_cols] <- lapply(y2[num_cols], as.numeric)
    
    # On ajoute à la table
    findf$data1 <- bind_rows(findf$data1, y1, y2)
    assign("df_concentration_final", findf$data1, envir = .GlobalEnv)
    
    # On réaffiche
    output$data_tablefin <- renderDT({
      datatable(findf$data1, options = list(pageLength = 10))
    })
  })

}
shinyApp(ui, server)

