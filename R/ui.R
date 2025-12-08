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
  # base_font = font_google("Montserrat"),
  # heading_font = font_google("Open Sans"),
  # code_font = font_google("Roboto Mono"),
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

ui <- function() {
  page_sidebar(
    useBusyIndicators(),
    title = "Fisheries Catch Dashboard",
    theme = theme,
    sidebar = sidebar(
      selectInput("country", "Country:", choices = NULL),
      selectInput("species", "Species:", choices = NULL)
    ),
    layout_columns(
      col_widths = c(8, 4),
      mod_map_UI(),
      mod_catch_season_UI()
    ),
    mod_cpue_UI()
  )
}
