# =============================================================================
# Day 1 — Course intro & what is R?
# Monday, May 18, 2026
#
# This is the code from today's slides, for your reference.
# You DO NOT need to run any of this today — it's demonstration material.
# Most of it needs packages we won't install until HW 0 (due Wednesday).
#
# Save this file. Once you have R and RStudio set up, come back and try
# running each section to see what it does.
#
# RStudio tip: sections marked with #### create a navigable outline.
# You can jump between them using the menu at the bottom-left of the editor.
# =============================================================================


# 0. Packages used today ------------------------------------------------- ####
# Run this block ONCE after installing R, to install everything we'll need.
# (Don't run today.)
#
# install.packages(c(
#   "tidyverse",       # data manipulation + ggplot2
#   "sf",              # spatial / map data
#   "tigris",          # US census shapefiles
#   "maps",            # base world & state maps
#   "mapproj",         # map projections
#   "palmerpenguins",  # the penguins demo data
#   "leaflet",         # interactive maps (HTML)
#   "readxl",          # reading Excel files
#   "ggspatial",       # map tile basemaps (for the PDF version)
#   "patchwork"        # combining ggplots
# ))


# 1. Solon, Ohio map ----------------------------------------------------- ####
# Highlights Cuyahoga County and the city of Solon on a map of Ohio.

library(ggplot2)
library(sf)
library(tigris)
library(dplyr)

options(tigris_use_cache = TRUE)

# Fetch spatial data
ohio_counties <- counties(state = "OH", cb = TRUE, progress_bar = FALSE)
ohio_places   <- places(state = "OH", cb = TRUE, progress_bar = FALSE)

# Isolate areas of interest
cuyahoga_county <- ohio_counties %>% filter(NAME == "Cuyahoga")
solon_city      <- ohio_places   %>% filter(NAME == "Solon")

# Build the map
ggplot() +
  # All counties — light gray base
  geom_sf(data = ohio_counties,
          fill = "#f8f9fa", color = "grey", linewidth = 0.3) +
  # Cuyahoga County — light blue
  geom_sf(data = cuyahoga_county,
          fill = "#D6EAF8", color = "#2980B9", linewidth = 0.5) +
  # Solon city — dark blue
  geom_sf(data = solon_city,
          fill = "dodgerblue", color = "darkblue", linewidth = 0.5) +
  # Label
  geom_sf_text(data = solon_city, aes(label = NAME),
               size = 5, fontface = "bold", color = "dodgerblue",
               nudge_y = -0.05, nudge_x = 0.25) +
  theme_void()


# 2. Countries I've been to ---------------------------------------------- ####
# World map shading the countries I've visited.

library(ggplot2)
library(maps)
library(dplyr)

world_map <- map_data("world")

visited_countries <- c("Canada", "USA", "Argentina", "Uruguay",
                       "Switzerland", "Rwanda", "Spain", "France", "Turkey")

world_map <- world_map %>%
  mutate(visited = ifelse(region %in% visited_countries,
                          "Visited", "Not Visited"))

ggplot(world_map, aes(x = long, y = lat, group = group, fill = visited)) +
  geom_polygon(color = "white", linewidth = 0.2) +
  scale_fill_manual(values = c("Not Visited" = "#e0e0e0",
                               "Visited"     = "#FF7F50")) +
  theme_void() +
  theme(legend.position = "none")


# 3. US states I've lived in & visited ----------------------------------- ####
# US map shading states by status: Lived, Visited, or Not Visited.

library(ggplot2)
library(maps)
library(dplyr)
library(mapproj)

us_map <- map_data("state")

lived_in <- tolower(c("Ohio", "Pennsylvania", "Texas"))

# Note: map_data uses "district of columbia" rather than "washington dc"
visited <- tolower(c("Washington", "Oregon", "California", "Nevada", "Idaho",
                     "Montana", "Arizona", "New Mexico", "Colorado", "Wyoming",
                     "North Dakota", "South Dakota", "Kansas", "Iowa",
                     "Nebraska", "Minnesota", "Wisconsin", "Michigan", "Indiana",
                     "Illinois", "Kentucky", "Tennessee", "Louisiana", "Florida",
                     "Georgia", "North Carolina", "South Carolina", "Virginia",
                     "District of Columbia", "Maryland", "Delaware", "New Jersey",
                     "New York", "Missouri", "Utah", "West Virginia"))

us_map <- us_map %>%
  mutate(status = case_when(
    region %in% lived_in ~ "Lived",
    region %in% visited  ~ "Visited",
    TRUE                 ~ "Not Visited"
  )) %>%
  mutate(status = factor(status,
                         levels = c("Lived", "Visited", "Not Visited")))

ggplot(us_map, aes(x = long, y = lat, group = group, fill = status)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  scale_fill_manual(values = c("Lived"       = "#2C3E50",   # dark blue
                               "Visited"     = "#3498DB",   # light blue
                               "Not Visited" = "#E0E0E0")) + # gray
  coord_map("albers", lat0 = 39, lat1 = 45) +
  theme_void() +
  theme(legend.position = "bottom",
        legend.title    = element_blank(),
        legend.text     = element_text(size = 14))


# 4. PA voter table — tidied up ------------------------------------------ ####
# Loads a messy spreadsheet of PA party-change applications and reshapes
# it into a long, tidy table. Requires `data/currentvotestats.xlsx` in
# your working directory.

library(dplyr)
library(tidyr)
library(readxl)

# Load data with clean column names that handle the nested headers
raw_data <- readxl::read_excel(
  "data/currentvotestats.xlsx",
  sheet     = "Party-to-Party(2026)",
  skip      = 3,
  col_names = c("county",
                "week_dem_R", "week_dem_OTH",
                "week_rep_D", "week_rep_OTH",
                "year_dem_R", "year_dem_OTH",
                "year_rep_D", "year_rep_OTH")
)

# Clean and pivot to long format
tidy_voter_data <- raw_data %>%
  filter(!is.na(county), county != "Totals:") %>%
  pivot_longer(
    cols      = -county,
    names_to  = c("period", "target_party", "origin_party"),
    names_sep = "_",
    values_to = "count"
  )

# Look at one county
head(tidy_voter_data %>% filter(county == "CENTRE"))


# 5. Penguins demo ------------------------------------------------------- ####
# A quick taste of what's possible: summarize and plot the Palmer Penguins.

library(tidyverse)
library(palmerpenguins)

# Peek at the data
glimpse(penguins)

# Summary statistics by species
penguins |>
  group_by(species) |>
  summarize(
    n            = n(),
    mean_mass_g  = mean(body_mass_g,    na.rm = TRUE),
    mean_bill_mm = mean(bill_length_mm, na.rm = TRUE)
  )

# Bill length vs body mass, colored by species
penguins |>
  ggplot(aes(x = bill_length_mm, y = body_mass_g, color = species)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Bill length vs body mass, by species",
    x = "Bill length (mm)",
    y = "Body mass (g)"
  ) +
  theme_minimal()


# 6. Centre County map (interactive HTML version) ------------------------ ####
# An interactive Leaflet map of Centre County, PA, with a marker for our
# classroom building. Run this and a map should appear in the Viewer tab.

library(tidyverse)
library(sf)
library(tigris)
library(leaflet)

options(tigris_use_cache = TRUE)

centre_county <- counties(state = "PA", cb = TRUE, progress_bar = FALSE) |>
  filter(NAME == "Centre") |>
  st_transform(4326)   # Leaflet needs standard WGS84

huck_building <- tibble(
  lon  = -77.86146,
  lat  = 40.80100,
  name = "Huck Life Sciences Building"
) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

leaflet() |>
  addProviderTiles(providers$Esri.WorldImagery) |>
  addPolygons(
    data        = centre_county,
    fillColor   = "#041E42",   # PSU Dark Blue
    fillOpacity = 0.1,
    color       = "#FFFFFF",
    weight      = 3,
    dashArray   = "5, 5"
  ) |>
  addCircleMarkers(
    data         = huck_building,
    color        = "#FFFFFF",
    weight       = 1,
    fillColor    = "#0096FF",
    radius       = 8,
    fillOpacity  = 0.9,
    label        = ~name,
    labelOptions = labelOptions(
      style = list(
        "font-family" = "Arial, sans-serif",
        "font-weight" = "bold",
        "color"       = "#041E42",
        "padding"     = "4px 8px"
      ),
      direction = "auto"
    ),
    popup = "<b>Huck Life Sciences</b><br>Class meets in Room 007"
  )


# 7. Centre County map (static PDF version) ------------------------------ ####
# A two-panel static map: full county with classroom dot, plus a campus
# inset using an OpenStreetMap basemap.

library(tidyverse)
library(sf)
library(tigris)
library(ggspatial)
library(patchwork)

options(tigris_use_cache = TRUE)

centre_county <- counties(state = "PA", cb = TRUE, progress_bar = FALSE) |>
  filter(NAME == "Centre")

huck_building <- tibble(
  lon  = -77.86146,
  lat  = 40.80100,
  name = "Huck Life Sciences"
) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Main map: full county
map_main <- ggplot() +
  geom_sf(data = centre_county,
          fill = "gray90", color = "gray50", linewidth = 0.5) +
  geom_sf(data = huck_building, color = "red", size = 3) +
  theme_void() +
  labs(title = "Centre County, Pennsylvania")

# Inset map: zoomed to campus
map_inset <- ggplot() +
  annotation_map_tile(type = "osm", zoom = 15, progress = "none") +
  geom_sf(data = huck_building, color = "red", size = 4) +
  geom_sf_label(data = huck_building, aes(label = name), nudge_y = 0.0015) +
  coord_sf(
    xlim   = c(-77.870, -77.850),
    ylim   = c(40.795,  40.805),
    expand = FALSE,
    crs    = 4326
  ) +
  theme_void() +
  theme(panel.border = element_rect(color = "black", fill = NA,
                                    linewidth = 2))

# Combine main + inset
final_map <- map_main +
  inset_element(map_inset,
                left = 0.45, bottom = 0.05,
                right = 0.95, top = 0.45)

final_map
