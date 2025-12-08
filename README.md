The app can be accessed in the following link:

[Fisheries catch dashboard](https://gvituri.shinyapps.io/fisheries-dashboard/)

Installing:

```r
# install.packages("devtools")
devtools::install_github("vituri/software-developer-assessment@develop")
library(fisheriesdashboard)
run_app()
```

# Enhancements

## Visual

- Use `bslib` instead of plain `shiny`.
- Create a `bs_theme()` inspired by [Blue Ventures website](https://blueventures.org/).
- Change in layout so the map has more space.
- Use cards with full screen option.
- Use `echarts4r` instead of `ggplot2` for interactive plots.

## Performance

- Add cache to all filters and plots.
- Add a waiting of 2 seconds for each country filtering and a corresponding notification, so we can see when the calculation is computed or just cached.
- Add `useBusyIndicators()` so the user has a visual clue of the computation.
- Avoid filtering the same data twice; reuse reactives.
- Use R base pipe `|>` instead of `magrittr` pipe `%>%`.

## Organization

- Use package structure.
- Split functions into different files.
- Isolate `generate_*` functions.
- Use modules for each card with plots/maps.
- Add sidebar in card with aggregation options for date.

# How to use the app

The dashboard explored simulated fisheries data around the world.

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
