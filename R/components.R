card2 <- function(title = "", ...) {
  card(
    card_header(title, class = "bg-info"),
    ...,
    full_screen = TRUE
  )
}
