# =============================================================================
# Day 3 Activity: Your First Histogram
# Script name: day3-activity.R
# STAT 184 - Summer 2026
# =============================================================================
#
# Goal: Make a histogram of a real data set and tweak it.
#
# Work individually or with a neighbor. We'll regroup at the end of class.
#
# Save this file somewhere you'll remember (e.g., a "stat184" folder).
# You'll turn it in at the end of class.
#
# =============================================================================


# -----------------------------------------------------------------------------
# Step 1 - Load packages
# -----------------------------------------------------------------------------
# If palmerpenguins isn't installed yet, run this ONCE in the Console:
#   install.packages("palmerpenguins")
# (Do NOT put install.packages() in this script.)

library(tidyverse)
library(palmerpenguins)

# -----------------------------------------------------------------------------
# Step 2 - Look at the data
# -----------------------------------------------------------------------------
# Pick ONE of these to peek at the data:

# glimpse(penguins)
# View(penguins)
# ?penguins

# Questions to think about (you don't have to write answers):
#   - What variables are in this data set?
#   - What does each row represent?


# -----------------------------------------------------------------------------
# Step 3 - Make a default histogram
# -----------------------------------------------------------------------------
# Pick a numeric variable from `penguins`. Some options:
#   - flipper_length_mm
#   - bill_length_mm
#   - bill_depth_mm
#   - body_mass_g

# Create a histogram with your numeric variable of choice on the x-axis
# (Use the code below as a starting point; run ?aes if you get stuck)

ggplot(penguins, aes()) +
  geom_histogram()


# -----------------------------------------------------------------------------
# Step 4 - Tweak your histogram
# -----------------------------------------------------------------------------
# Make at least THREE changes to your histogram. For example:
#   - Try a different `binwidth` or `bins` value.
#   - Change the `fill` and `color` of the bars.
#   - Add a title and axis labels with `labs(...)`.
# A good resource for colors/fill: https://r-graph-gallery.com/ggplot2-color.html
#
# Write your tweaked histogram below. Here's the template:

ggplot(penguins, aes()) +
  geom_histogram(
    
  ) +
  labs(
    
  )

# -----------------------------------------------------------------------------
# Step 5 - Comment on what you see
# -----------------------------------------------------------------------------
# In the space below, write 2-3 sentences answering:
#   - What does the shape of your histogram tell you about the variable?
#   - Did changing the binwidth change the story?
#
# Write your answer as comments (lines starting with #):

# YOUR ANSWER HERE:
#
#
#


# -----------------------------------------------------------------------------
# Stuck?
# -----------------------------------------------------------------------------
# - Read the error message - it's usually a typo, missing `+`, or unmatched `(`.
# - Ask a neighbor.
# - Wave me down.
#
# Don't forget to SAVE your file (Cmd/Ctrl + S) before turning it in!