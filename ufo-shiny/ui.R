page_sidebar(
  div(img(src = "ufo.png"), "UFO Report Explorer"),
  sidebar = sidebar(
    textInput("keyword", "Select a keyword:"),
    dateRangeInput(
      "daterange",
      "Choose a date range",
      start = "2010-01-01",
      end = max_date
    ),
    actionButton("go", "Search Records", class = "btn-primary"),
    open = "closed"
  ),
  layout_columns(
    layout_columns(
      card(
        card_header("Click a state"),
        leafletOutput("map")
      ),
      card(
        card_header("Click a sighting"),
        leafletOutput("state")
      ),
      card(
        textOutput("description")
      ),
      layout_columns(
        value_box(
          title = "Shape of Craft", value = textOutput("shape"), theme = "primary",
          showcase = bsicons::bs_icon("rocket-takeoff", size = "0.75em"),
          showcase_layout = "top right", full_screen = FALSE, fill = TRUE, height = NULL
        ),
        value_box(
          title = "Duration of Encounter", value = textOutput("duration"),
          theme = "primary", showcase = bsicons::bs_icon("stopwatch", size = "0.75em"),
          showcase_layout = "top right", full_screen = FALSE, fill = TRUE,
          height = NULL
        ),
        value_box(
          title = "Date of Encounter", value = textOutput("date"), theme = "primary",
          showcase = bsicons::bs_icon("calendar3", size = "0.75em"), showcase_layout = "top right",
          full_screen = FALSE, fill = TRUE, height = NULL
        ),
        uiOutput("aliens", fill = TRUE),
        col_widths = c(6, 6, 6, 6),
        row_heights = c(1, 1)
      ),
      col_widths = c(6, 6, 8, 4),
      row_heights = c(3, 2)
    )
  ),
  tags$head(tags$style(HTML('.bslib-value-box .value-box-value {font-size:20px;}',
                            '.bslib-value-box .value-box-title {font-size:15px;}',
                            '.bslib-value-box .value-box-showcase {opacity:0.2;}'))),
)
