# Day 25 In-Class Activity: Using R with LLMs
# STAT 184 - Tuesday, June 23, 2026
# ============================================================
# Today we are exploring how to use Large Language Models (LLMs)
# to explain errors, generate code, and evaluate AI outputs.
# ============================================================

library(tidyverse)
library(palmerpenguins)

# --- Part 1: Explain an Error -------------------------------------------------

# 1a. Run the following code. You will notice the `avg` column has NA values.
# penguins |> 
#   group_by(species) |> 
#   summarize(avg = mean(bill_length_mm))

# 1b. Copy the code and the issue into an LLM (ChatGPT, Claude, Gemini, etc.).
#     Ask it to explain why this happens and how to fix it.

# Q1. Why does the original code return NA/NaN? What is the one-argument fix?
#
# (Type your answer as a comment here)

# 1c. Paste the LLM's fixed code below and run it to verify it works:
#


# --- Part 2: Generate a Function ----------------------------------------------

# 2a. Ask an LLM to write an R function that takes a numeric vector and 
#     returns its mean, median, and standard deviation as a named tibble.
#     Paste the generated function below:

# my_summary_stats <- function(x) {
#   # Paste LLM code here
# }

# 2b. Test the function to see if it breaks. Feed it a vector with NAs 
#     and a length-1 vector.
# my_summary_stats(c(1, 2, NA))
# my_summary_stats(5)

# Q2. Did the LLM handle the missing values (`NA`) and the length-1 vector 
#     gracefully? Describe what happened.
#
# (Type your answer as a comment here)


# --- Part 3: Debugging an LLM Mapping Script ----------------------------------

# 3a. Below is a real-world script an LLM (Claude Opus 4.8) generated to recreate
#     a Wikipedia map of the linguistic regions of Switzerland. 
#     Map link: https://en.wikipedia.org/wiki/Languages_of_Switzerland#/media/File:Karte_Schweizer_Sprachgebiete_2026.png
#     It has two notable issues:
#     1. It hallucinated a `date` argument for the canton and lake base maps.
#     2. It used a black background that clashes with the chosen color palette.
#
#     Run the code to see the errors. Feed the errors back into an LLM to find the 
#     fix, and ask it to switch the theme backgrounds to "white" and the legend text 
#     to "black".

install.packages(c("BFS", "bfsMaps", "sf"))
library(BFS)        # official ThemaKart base maps as sf
library(bfsMaps)    # ships d.bfsrg: municipality -> language region
library(sf)

map_date <- "20230101"
gde   <- bfs_get_base_maps(geom = "polg", date = map_date)  # municipalities
kant  <- bfs_get_base_maps(geom = "kant", date = map_date)  # cantons (Error!)
lakes <- bfs_get_base_maps(geom = "seen", date = map_date,  # main lakes (Error!)
                           category = "11")

data("d.bfsrg", package = "bfsMaps")
lang_lkp <- d.bfsrg |>
  transmute(
    id   = as.integer(gem_id),
    lang = factor(sprgeb_c, levels = 1:4,
                  labels = c("Deutsch", "Französisch",
                             "Italienisch", "Rätoromanisch"))
    )

gde <- gde |>
  mutate(id = as.integer(id)) |>
  left_join(lang_lkp, by = "id")

pal <- c(
  "Deutsch"       = "#F1C2B2",   
  "Französisch"   = "#BFBBCB",   
  "Italienisch"   = "#B5DCC7",   
  "Rätoromanisch" = "#FEFCC7"    
)
lake_col <- "#CFE3F2"

p <- ggplot() +
  geom_sf(data = gde,   aes(fill = lang), colour = "grey55", linewidth = 0.08) +
  geom_sf(data = kant,  fill = NA, colour = "grey10", linewidth = 0.5) +
  geom_sf(data = lakes, fill = lake_col, colour = "grey70", linewidth = 0.1) +
  scale_fill_manual(values = pal, breaks = names(pal), na.value = "grey30", name = NULL) +
  coord_sf(datum = NA, expand = FALSE) +
  guides(fill = guide_legend(override.aes = list(colour = NA))) +
  theme_void() +
  theme(
    plot.background        = element_rect(fill = "black", colour = NA),
    panel.background       = element_rect(fill = "black", colour = NA),
    legend.text            = element_text(colour = "grey85", size = 11),
    legend.key.size        = unit(15, "pt"),
    legend.position        = "inside",
    legend.position.inside = c(0.06, 0.88),
    legend.justification   = c(0, 1)
  )
print(p)

# 3b. Paste your final, corrected version of the mapping script below and 
#     verify that the plot renders cleanly:
#