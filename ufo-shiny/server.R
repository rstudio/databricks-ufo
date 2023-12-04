function(input, output, session) {

    reports <- shiny::reactiveVal(ufos_usa)

    featured_reports <- shiny::reactive({reports()})

    observeEvent(input$go, {
      filtered_reports <-
        ufos_usa |>
          filter(date_time > input$daterange[1],
                 date_time <= input$daterange[2])

      if (input$keyword != "") {
        filtered_reports <-
          filtered_reports |>
            filter(str_detect(text, input$keyword))
      }

      # if data exists that match the filters, update reports
      if (nrow(filtered_reports)) {
        reports(filtered_reports)

      # else open a dialog box
      } else {
        showModal(modalDialog(
          title = "No records found",
          "No records matched your search criteria. Please consider using a different combination of keywords and dates."
        ))
      }
    })

    featured_keyword_state_counts <-
      shiny::reactive({
        featured_reports() |>
          dplyr::count(state) |>
          dplyr::inner_join(state_abb, by = c("state" = "abb")) |>
          dplyr::inner_join(spData::us_states, by = c("state.y" = "NAME")) |>
          dplyr::rename(ufo_count = n, state_name = state.y) |>
          dplyr::mutate(state_rank = min_rank(ufo_count)) |>
          sf::st_as_sf()
      })

    pal <-
      shiny::reactive({
        leaflet::colorBin("YlOrRd",
                          domain = featured_keyword_state_counts()$state_rank,
                          bins = 5)
      })

    labels <-
      shiny::reactive({
        glue::glue(
          "<strong>{featured_keyword_state_counts()$state_name}</strong><br/>{featured_keyword_state_counts()$ufo_count} UFO sightings"
        ) |>
          lapply(htmltools::HTML)
      })



    ## 2 letter value of state clicked
    ## default to CA on app load, the  observeEvent below will modify on user click
    clicked_state <- shiny::reactiveVal("NM")

    ## user clicks map, use the coords from the click location to find and set state clicked
    observeEvent(input$map_shape_click, {
        user_clicked_point <- input$map_shape_click
        user_lat <- user_clicked_point$lat
        user_lon <- user_clicked_point$lng

        which_state_bool <-
          featured_keyword_state_counts() |>
            dplyr::pull(geometry) |>
            sf::st_intersects(st_point(c(user_lon, user_lat))) |>
            as.logical()

        clicked_st <-
          featured_keyword_state_counts() |>
            dplyr::filter(which_state_bool) |>
            dplyr::pull(state) |>
            as.character()

        # set the clicked_state reactiveVal
        clicked_state(clicked_st)
    })

    ## dataframe with the state geometry used for plotting the clicked state map
    state_geometry_df <-
      shiny::reactive({
        filtered_state_df <-
          featured_keyword_state_counts() |>
            filter(state == clicked_state())
      })

    ## the coordinates of the clicked state's center, used to center the state map
    state_center_coords <-
      shiny::reactive({

        state_center <-
          state_geometry_df() |>
            dplyr::pull(geometry) |>
            sf::st_centroid()

        state_center_x <- st_coordinates(state_center)[1, 1] |> as.numeric()
        state_center_y <- st_coordinates(state_center)[1, 2] |> as.numeric()

        list(
          x = state_center_x,
          y = state_center_y
        )
      })

    ## original data filtered by the selected state
    ## used to plot the points on the state map
    state_ufo_points_df <-
      shiny::reactive({
        featured_reports() |>
            dplyr::filter(state == clicked_state())
      })

    ## country cholopleth map
    output$map <-
      renderLeaflet({
        leaflet(featured_keyword_state_counts()) |>
            setView(-96, 37.8, 4) |>
            addTiles() |>
            addPolygons(
                fillColor = ~pal()(state_rank),
                weight = 2,
                opacity = 1,
                color = "white",
                dashArray = "3",
                fillOpacity = 0.7,

                highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),

                label = labels(),
                labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")

            )

      })

    ## state-level map with ufo sightings
    output$state <-
      renderLeaflet({
        leaflet(state_ufo_points_df()) |>
          setView(state_center_coords()$x, state_center_coords()$y, 6) |>
          addTiles() |>
          addCircleMarkers(
              lng = ~city_longitude,
              lat = ~city_latitude,
              popup = ~summary,
              label = ~summary,
              radius = 1,
              layerId = ~id
          )
    })

    observe({
      leafletProxy("state", data = featured_sighting()) |>
        leaflet::removeMarker(layerId = featured_sighting_previous()$id) |> # remove the precious marker
        addCircleMarkers(
          lng = featured_sighting_previous()$city_longitude,
          lat = featured_sighting_previous()$city_latitude,
          popup = featured_sighting_previous()$summary,
          label = featured_sighting_previous()$summary,
          radius = 1,
          layerId = featured_sighting_previous()$id
        ) |>
        addCircleMarkers(
          lng = ~city_longitude,
          lat = ~city_latitude,
          popup = ~summary,
          label = ~summary,
          radius = 5,
          layerId = ~id,
          color = "red"
        )
    })


    ## initial sighting to display
    featured_sighting <- reactiveVal({
      ufos_usa |> filter(id == "30")
    })

    featured_sighting_previous <- reactiveVal({
      ufos_usa |> filter(id == "30")
    })

    ## when the user clicks a sighting
    observeEvent(input$state_marker_click, {
      featured_sighting_previous(featured_sighting())
      featured_sighting(ufos_usa[as.numeric(input$state_marker_click$id), ])
    })

    ## when a new state is clicked
    observeEvent(state_ufo_points_df(), {
      featured_sighting(head(state_ufo_points_df(), 1))
    })


    output$description <-
      shiny::renderText({
        desc <- featured_sighting()$text[1]
        if (is.na(desc)) "No Description" else desc
      })

    output$shape <-
      shiny::renderText({
        na_check(featured_sighting()$shape[1])
      })

    output$duration <-
      shiny::renderText({
        na_check(clean_time(featured_sighting()$duration[1]))
      })

    output$date <-
      shiny::renderText({
        na_check(as.character(as.Date(featured_sighting()$date_time)))
      })

    output$aliens <-
      shiny::renderUI({
        report <- na_check(featured_sighting()$text[1])
        aliens <- any(str_detect(str_to_lower(report), alien_related_words))

        if (aliens) {
          value_box(
            title = "Aliens Reported", value = "Yes", theme = "success",
            showcase = bsicons::bs_icon("moon-stars", size = "0.75em"), showcase_layout = "top right",
            full_screen = FALSE, fill = TRUE, height = NULL, style = 'background-color: #17a98c!important;'
          )
        } else {
          value_box(
            title = "Aliens Reported", value = "No", theme = "primary",
            showcase = bsicons::bs_icon("moon-stars", size = "0.75em"), showcase_layout = "top right",
            full_screen = FALSE, fill = TRUE, height = NULL
          )
        }
      })
}
