server <- function(input, output, session) {
  # Load datasets ----
  catch <- generate_fisheries_data()
  countries <- catch$country |>
    unique() |>
    sort()
  vessels <- generate_vessel_data()

  catch_full <- generate_catch_full(catch, vessels)

  catch_by_season <- generate_catch_by_season(catch)
  cpue <- generate_cpue(catch_full)

  # update country filter ----
  observe({
    updateSelectInput(session = session, inputId = "country", choices = countries, selected = countries[1])
  })

  # filter catch by country ----
  rc.catch_country <- reactive({
    req(input$country)
    glue::glue("Filtering catch in {input$country}...") |> showNotification(duration = 1)

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

  # map module ----
  mod_map_Server(rc.catch_species = rc.catch_species)

  # output$total_catch_plot ----
  mod_catch_season_Server(input_main = input, catch_by_season = catch_by_season)

  # output$cpue_plot ----
  mod_cpue_Server(input_main = input, cpue = cpue)
}
