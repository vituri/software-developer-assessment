# devtools::install_github("vituri/software-developer-assessment")

options(repos = c(CRAN = "https://cran.rstudio.com/"))

rsconnect::deployApp(
  appDir = "deploy/",
  appSourceDoc = "deploy/app.R",
  forceUpdate = TRUE
)
