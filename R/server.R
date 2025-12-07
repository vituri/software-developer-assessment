server <- function(input, output, session) {
  # Load datasets ----
  catch <- generate_fisheries_data()
  countries <- catch$country |>
    unique() |>
    sort()
  vessels <- generate_vessel_data()

  catch_full <- catch |>
    left_join(vessels, by = "vessel_id")

  catch_by_season <- catch |>
    summarize(total_catch = sum(catch_kg), .by = c(country, species, season))

  cpue <- catch_full |>
    mutate(cpue = catch_kg / crew_size) |>
    summarize(
      avg_cpue = mean(cpue), .by = c(country, species, date)
    ) |>
    tidyr::complete(country, species, date) |>
    # save week and year for possible aggregation
    mutate(year = year(date), week = paste0(year, "-", week(date)))

  # update country filter ----
  observe({
    updateSelectInput(session = session, inputId = "country", choices = countries, selected = countries[1])
  })

  # filter catch by country ----
  rc.catch_country <- reactive({
    req(input$country)
    paste("Filtering catch by country...") |> showNotification(duration = 1)

    Sys.sleep(2)
    catch_full |> filter(country == input$country)
  }) |>
    bindCache(input$country)

  # update species filter ----
  observe({
    species <- rc.catch_country()$species |>
      unique() |>
      sort()

    updateSelectInput(session, "species", choices = species, selected = species[1])
  })

  # filter catch by species ----
  rc.catch_species <- reactive({
    rc.catch_country() |>
      filter(species == input$species)
  }) |>
    bindCache(input$country, input$species)

  # output$map ----
  output$map <- renderLeaflet({
    dat <- rc.catch_species()

    leaflet(dat) |>
      addTiles() |>
      addCircleMarkers(
        ~longitude, ~latitude,
        radius = ~ sqrt(catch_kg) / 5,
        popup = ~ paste0(
          "<b>Species:</b> ", species,
          "<br><b>Catch (kg):</b> ", catch_kg,
          "<br><b>Vessel:</b> ", vessel_name,
          "<br><b>Port:</b> ", port
        ),
        fillOpacity = 0.7
      )
  })

  # output$total_catch_plot ----
  output$total_catch_plot <- renderPlot({
    catch_by_season |>
      filter(country %in% input$country, species %in% input$species) |>
      ggplot(aes(x = season, y = total_catch, fill = season)) +
      geom_col() +
      labs(
        title = paste("Total Catch per Season -", input$country),
        x = "Season",
        y = "Catch (kg)"
      ) +
      theme_minimal()
  }) |>
    bindCache(input$country, input$species)

  # output$cpue_plot ----
  output$cpue_plot <- renderPlot({
    cpue |>
      filter(country %in% input$country, species %in% input$species) |>
      ggplot(aes(x = date, y = avg_cpue)) +
      geom_line() +
      geom_point() +
      labs(
        title = paste("Catch per Unit Effort (CPUE) -", input$species),
        x = "Date",
        y = "CPUE (kg per crew member)"
      ) +
      theme_minimal()
  }) |>
    bindCache(input$country, input$species)
}
