mod_map_UI <- function(id = "map") {
  ns <- NS(id)
  card2(
    "Map",
    leafletOutput(ns("map"))
  )
}

mod_map_Server <- function(id = "map", rc.catch_species) {
  moduleServer(
    id,
    function(input, output, session) {
      output$map <- renderLeaflet({
        dat <- rc.catch_species()
        req(dat)

        leaflet(dat) |>
          addProviderTiles("Esri.WorldStreetMap") |>
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
    }
  )
}

mod_catch_season_UI <- function(id = "season") {
  ns <- NS(id)
  card2(
    "Catch by season",
    echarts4rOutput(ns("total_catch_plot"), height = "300px")
  )
}

mod_catch_season_Server <- function(id = "season", input_main, catch_by_season) {
  moduleServer(
    id,
    function(input, output, session) {
      output$total_catch_plot <- renderEcharts4r({
        req(input_main$species)

        df <- catch_by_season |>
          filter(country %in% input_main$country, species %in% input_main$species) |>
          mutate(color = season_colors[season])

        df |>
          e_charts(season) |>
          e_bar(total_catch, name = "Catch (kg)") |>
          e_add_nested("itemStyle", color) |>
          e_tooltip(
            trigger = "axis",
            axisPointer = list(type = "shadow"),
            formatter = htmlwidgets::JS("
              function(params) {
                var val = params[0].value[1];
                return '<strong>' + params[0].name + '</strong><br/>' +
                       'Catch: ' + val.toLocaleString() + ' kg';
              }
            ")
          ) |>
          e_x_axis(
            name = "Season",
            nameLocation = "middle",
            nameGap = 30,
            axisLabel = list(fontWeight = "bold")
          ) |>
          e_y_axis(
            name = "Catch (kg)",
            nameLocation = "middle",
            nameGap = 50
          ) |>
          e_grid(left = "15%", right = "5%", bottom = "15%", top = "10%") |>
          e_animation(duration = 1000) |>
          e_legend(show = FALSE)
      }) |>
        bindCache(input_main$country, input_main$species)
    }
  )
}

mod_cpue_UI <- function(id = "cpue") {
  ns <- NS(id)
  card2(
    "Catch per Unit Effort (CPUE)",
    layout_sidebar(
      sidebar = sidebar(
        selectInput(
          inputId = ns("date_aggregation"),
          label = "Aggregation",
          choices = c("day", "week", "month", "year"),
          selected = "day"
        )
      ),
      echarts4rOutput(ns("cpue_plot"), height = "350px")
    )
  )
}

mod_cpue_Server <- function(id = "cpue", input_main, cpue) {
  moduleServer(
    id,
    function(input, output, session) {
      output$cpue_plot <- renderEcharts4r({
        req(input_main$species)

        dat <- cpue |>
          filter(
            country %in% input_main$country, species %in% input_main$species
          ) |>
          arrange(date)

        shiny::validate(
          need(
            nrow(dat) > 0, "No data available."
          ),
          need(
            any(!is.na(dat$avg_cpue)), "No vessel has crew size registered."
          )
        )

        if (!input$date_aggregation %in% "day") {
          date_col <- input$date_aggregation
          dat <-
            dat |>
            summarise(avg_cpue = mean(avg_cpue, na.rm = TRUE), .by = date_col)
        } else {
          date_col <- "date"
        }


        dat |>
          e_charts_(date_col) |>
          e_bar(
            avg_cpue,
            name = "CPUE",
            itemStyle = list(
              color = list(
                type = "linear",
                x = 0, y = 0, x2 = 0, y2 = 1,
                colorStops = list(
                  list(offset = 0, color = "#0098D8"),
                  list(offset = 1, color = "#00B4AA")
                )
              ),
              borderRadius = c(4, 4, 0, 0)
            )
          ) |>
          e_tooltip(
            trigger = "axis",
            axisPointer = list(type = "cross")
          ) |>
          e_x_axis(
            type = "time",
            name = "Date",
            nameLocation = "middle",
            nameGap = 35
          ) |>
          e_y_axis(
            name = "CPUE (kg/crew)",
            nameLocation = "middle",
            nameGap = 50
          ) |>
          e_grid(left = "12%", right = "5%", bottom = "15%", top = "10%") |>
          e_datazoom(xAxisIndex = 0, type = "inside") |>
          e_animation(duration = 1500) |>
          e_legend(show = FALSE)
      }) |>
        bindCache(input_main$country, input_main$species, input$date_aggregation)
    }
  )
}
