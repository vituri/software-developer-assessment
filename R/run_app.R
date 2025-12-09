#' Run the app
#' @export
run_app <- function() {
  shinyApp(ui(), server)
}
