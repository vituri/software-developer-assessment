library(shiny)
library(bslib)
library(dplyr)
library(lubridate)
library(leaflet)
library(ggplot2)

# Load datasets
source("dummy_data_generator.R")
catch <- generate_fisheries_data()
vessels <- generate_vessel_data()

catch_full <- catch %>%
  left_join(vessels, by = "vessel_id")

card2 <- function(title = "", ...) {
  card(
    card_header(title, class = "bg-info"),
    ...,
    full_screen = TRUE
  )
}


# Blue Ventures inspired theme
theme <- bs_theme(
  version = 5,
  primary = "#0098D8",
  secondary = "#00B4AA",
  bg = "#FFFFFF",
  fg = "#2C2C2C",
  success = "#00A878",
  info = "#003D5B",
  warning = "#FFA630",
  danger = "#E63946",
  base_font = font_google("Montserrat"),
  heading_font = font_google("Open Sans"),
  code_font = font_google("Roboto Mono"),
  "font-size-base" = "1rem",
  "headings-font-weight" = "700",
  "body-color" = "#2C2C2C",
  "link-color" = "#0098D8",
  "link-hover-color" = "#007AB8",
  "link-decoration" = "none",
  "spacer" = "1rem",
  "border-radius" = "0.375rem",
  "border-radius-lg" = "0.5rem",
  "border-radius-sm" = "0.25rem",
  "btn-font-weight" = "600",
  "btn-border-radius" = "0.375rem",
  # navbar
  "navbar-bg" = "#003D5B",
  "navbar-fg" = "#FFFFFF",
  "card-border-color" = "rgba(0, 0, 0, 0.125)",
  "card-border-radius" = "0.5rem"
)

# ui ----
ui <- page_sidebar(
  title = "Fisheries Catch Dashboard",
  theme = theme,
  sidebar = sidebar(
    selectInput("country", "Country:", choices = sort(unique(catch_full$country))),
    selectInput("species", "Species:", choices = NULL)
  ),
  layout_columns(
    col_widths = c(8, 4),
    card2(
      "Map",
      leafletOutput("map")
    ),
    card2(
      "Catch by season",
      plotOutput("total_catch_plot")
    )
  ),
  card2(
    "Total catch",
    plotOutput("cpue_plot")
  )
)

# server ----
server <- function(input, output, session) {
  observe({
    species <- catch_full %>%
      filter(country == input$country) %>%
      pull(species) %>%
      unique() %>%
      sort()

    updateSelectInput(session, "species", choices = species, selected = species[1])
  })

  country_data <- reactive({
    catch_full %>% filter(country == input$country)
  })

  filtered_data <- reactive({
    country_data() %>% filter(species == input$species)
  })

  output$map <- renderLeaflet({
    dat <- filtered_data()

    leaflet(dat) %>%
      addTiles() %>%
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

  output$total_catch_plot <- renderPlot({
    filtered_data() %>%
      group_by(season) %>%
      summarize(total_catch = sum(catch_kg), .groups = "drop") %>%
      ggplot(aes(x = season, y = total_catch, fill = season)) +
      geom_col() +
      labs(
        title = paste("Total Catch per Season -", input$country),
        x = "Season",
        y = "Catch (kg)"
      ) +
      theme_minimal()
  })

  output$cpue_plot <- renderPlot({
    filtered_data() %>%
      mutate(cpue = catch_kg / crew_size) %>%
      group_by(date) %>%
      summarize(avg_cpue = mean(cpue), .groups = "drop") %>%
      ggplot(aes(x = date, y = avg_cpue)) +
      geom_line() +
      geom_point() +
      labs(
        title = paste("Catch per Unit Effort (CPUE) -", input$species),
        x = "Date",
        y = "CPUE (kg per crew member)"
      ) +
      theme_minimal()
  })
}

shinyApp(ui, server)
