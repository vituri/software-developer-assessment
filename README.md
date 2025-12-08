The app can be accessed in the following link:

[Fisheries catch dashboard](https://gvituri.shinyapps.io/fisheries-dashboard/)

Installing:

```r
# install.packages("devtools")
devtools::install_github("vituri/software-developer-assessment@develop")
library(fisheriesdashboard)
run_app()
```

Requisites:
- R version >= 4.2.
- `devtools` package to install via `devtools::install_github`.

# Chosen Enhancements

This project implements **3 enhancements** from the provided task list:

| # | Enhancement Option | Implementation |
|---|-------------------|----------------|
| **2** | Improve performance | Caching with `bindCache()`, reactive reuse, `useBusyIndicators()` |
| **5** | Refactor with modules/code organization | Shiny modules for each card, R package structure, split files |
| **8** | Additional creative improvement of your choice | Change the visuals: custom `bs_theme()` inspired by the [Blue Ventures website](https://blueventures.org/) for brand consistency, `echarts4r` for interactive plots, `bslib` cards with fullscreen, new map tiles |

---

# Enhancements Details

## Performance (Option #2)

- **Caching**: Added `bindCache()` to all filters and plots using sidebar filters as cache keys. This avoids recomputation when the user switches back to previously selected filters.
- **Reactive reuse**: Avoid filtering the same data twice by reusing reactive expressions.
- **Busy indicators**: Added `useBusyIndicators()` so the user has visual feedback during computation.
- **Demo delay**: Added a 2-second artificial delay for country filtering with a notification, so the caching effect is visible during the demo.
- **Base pipe**: Use R base pipe `|>` instead of `magrittr` pipe `%>%` for slightly better performance and fewer dependencies.

## Modules & Code Organization (Option #5)

- **Package structure**: The app is now an R package, making it easy for anyone to install and run with just 3 lines of code.
- **Shiny modules**: Each card (map, seasonal plot, CPUE plot) is a separate module with its own namespace.
- **File organization**: Functions are split into logical files (`ui.R`, `server.R`, `modules.R`, `components.R`, `utils.R`, `dummy_data_generator.R`).

## Visual / Creative (Option #8)

- **Custom theme**: Created a `bs_theme()` with colors inspired by the Blue Ventures website for brand consistency.
- **Modern UI**: Used `bslib` instead of plain `shiny` for a cleaner, more modern interface.
- **`echarts4r`**: Replaced `ggplot2` with `echarts4r` for interactive, responsive plots with built-in tooltips, animations and zoom.
- **`bslib` cards**: Each visualization is wrapped in a `bslib` card with a fullscreen option for better data exploration.
- **Flexible layout**: The map has more horizontal space, and the sidebar provides aggregation options (day/week/month/year) for the CPUE plot.

---

# Trade-offs and Assumptions

| Decision | Trade-off | Rationale |
|----------|-----------|-----------|
| 2-second artificial delay | Slower UX in demo | Makes caching effect visible for interview demonstration; would be removed in production |
| `echarts4r` over `ggplot2` | Less customization for static exports | Better interactivity; tooltips and zoom out-of-the-box |
| Caching over async operations | Memory usage increases with cache size | Simpler implementation; suitable for dataset size (1200 records); async would add complexity |
| Package structure | More setup overhead | Much easier for end users to install and run; better for code organization and testing |

---

# How to use the app

The dashboard explores simulated fisheries data around the world.

The main features are:

- A general filter on the left sidebar, which control the country and species.
- An interactive map with each catch.
- An interactive plot with the amount of catch per season.
- An interactive plot with the UCPE for each amount of time (day, week, month or year).


# Previous README

## Dummy Datasets

### Dataset 1: Fisheries Catch Data
**Function:** `generate_fisheries_data()`

### Dataset 2: Vessel Information
**Function:** `generate_vessel_data()`

---

## Dataset 1: Fisheries Catch Data

### Columns (12 total)

| Column | Type | Description                          |
|--------|------|--------------------------------------|
| `date` | Date | Date of catch                        |
| `vessel_id` | Character | Vessel identifier (V-1001 to V-1030) |
| `species` | Character | Fish species name (10 types)         |
| `catch_kg` | Numeric | Catch weight in kilograms            |
| `latitude` | Numeric | Latitude coordinate                  |
| `longitude` | Numeric | Longitude coordinate                 |
| `water_temp` | Numeric | Water temperature (°C)               |
| `depth_m` | Numeric | Fishing depth (meters)               |
| `zone` | Character | Fishing zone identifier              |
| `region` | Character | Geographic region (4 regions)        |
| `country` | Character | Country name                         |

### Data Summary
- 1200 records
- 30 vessels
- 10 species (5 North Atlantic + 5 Australian)
- 11 fishing zones
- 4 regions (North Atlantic, Pacific Northwest, Australia, North Sea)
- 365 days of data

---

## Dataset 2: Vessel Information

### Columns (7 total)

| Column | Type | Description |
|--------|------|-------------|
| `vessel_id` | Character | Vessel identifier (V-1001 to V-1030) |
| `vessel_name` | Character | Vessel name |
| `capacity_kg` | Numeric | Vessel capacity in kilograms |
| `crew_size` | Numeric | Number of crew members |
| `registration_year` | Numeric | Year vessel was registered |
| `port` | Character | Home port |
| `vessel_type` | Character | Type of fishing vessel |

### Data Summary
- 30 vessels
- Capacity: 500-2500 kg
- Crew: 5-18 members
- Registered: 2000-2023
- 12 ports (Halifax, Boston, Portland, Sydney, Perth, Hobart, Cairns, Seattle, Vancouver, Aberdeen, Bergen, St. John's)
- 4 vessel types (Trawler, Longliner, Seiner, Pot/Trap)

---

## How to Use

### Generate Catch Data
```r
source("dummy_data_generator.R")
data <- generate_fisheries_data()
```

### Generate Vessel Data
```r
source("dummy_data_generator.R")
vessels <- generate_vessel_data()
```

### View Data
```r
View(data)
View(vessels)
head(data)
str(data)
```

### Extract Columns
```r
# From catch data
data$species
data$catch_kg
data[, c("date", "species", "catch_kg")]

# From vessel data
vessels$vessel_name
vessels$capacity_kg
```

### Save Data
```r
# Save catch data
write.csv(data, "fisheries_data.csv", row.names = FALSE)

# Save vessel data
write.csv(vessels, "vessel_data.csv", row.names = FALSE)

# Save both
saveRDS(data, "fisheries_data.rds")
saveRDS(vessels, "vessel_data.rds")
```
