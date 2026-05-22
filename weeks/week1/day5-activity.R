# =============================================================================
# Day 5 Activity: Pipe Practice
# STAT 184 - Summer 2026
# =============================================================================
#
# Goal: Translate between nested and piped code, then write your own.
#
# Work individually or with a neighbor. We'll regroup at the end of class.
#
# Save this file somewhere you'll remember (e.g., a "stat184" folder).
# You'll turn it in at the end of class.
#
# =============================================================================


# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------
# If palmerpenguins isn't installed yet, run this only once in the Console:
#   install.packages("palmerpenguins")

library(tidyverse)
library(palmerpenguins)


# -----------------------------------------------------------------------------
# Part 1 - Translate to piped
# -----------------------------------------------------------------------------
# Rewrite each of these using the pipe `|>`.
# Then run both the original and your piped version - they should match.

# 1.
sqrt(64)

# Your piped version:



# 2.
mean(c(2, 4, 6, 8, 10))

# Your piped version:



# 3.
round(sqrt(50), digits = 2)

# Your piped version:



# 4.
head(arrange(penguins, body_mass_g), 3)

# Your piped version:


# -----------------------------------------------------------------------------
# Part 2 - Translate to nested
# -----------------------------------------------------------------------------
# Rewrite each of these WITHOUT the pipe. Then run both versions.

# 5.
c(1, 2, 3, 4, 5) |> sum()

# Your nested version:



# 6.
penguins |> head(2)

# Your nested version:



# 7.
9 |> sqrt() |> round(1)

# Your nested version:


# -----------------------------------------------------------------------------
# Part 3 - `%>%` vs. `|>`
# -----------------------------------------------------------------------------

# The magrittr package's pipe (`%>%`), which `library(tidyverse)` loads, allows 
# the use of the . placeholder to pass objects into argumentsother than the 
# first one (e.g., x %>% f(1, .)). Run the code below.
penguins %>%
  filter(., species == "Adelie")

# The built-in base R pipe (`|>`) evaluates slightly faster because it runs 
# natively without needing to load the magrittr package. It's great if you only 
# need to pass the left-hand side to the first argument of the right-hand side 
# function.
# But, it's more limited. `|>` does NOT allow the use of the . placeholder.
# Instead, it throws an error (object '.' not found). 
# The `|>` operator uses '_' as a placeholder instead, but the usage is a bit
# different than that of '.'. Run the code below.
penguins %>%
  dplyr::filter(species == "Adelie")

# -----------------------------------------------------------------------------
# Part 4 - Write your own
# -----------------------------------------------------------------------------
# Write a single piped expression that:
#   1. Takes `penguins`,
#   2. Keeps only the rows where `species` is "Adelie",
#   3. Picks just the first 5 rows.
#
# Hint: You'll need filter() and head(). Chain them with %>%.

# Your code:





# -----------------------------------------------------------------------------
# Stuck?
# -----------------------------------------------------------------------------
# - Remember: x %>% f() is the same as f(x).
# - The pipe always fills the first argument of the function on the right.
# - Don't forget the parentheses: `f()`, not `f`.
# - Read the error message: it's usually a typo or unmatched `(`.
# - Ask a neighbor.
# - Wave me down.
#
# Don't forget to save your file (Cmd/Ctrl + S) before turning it in.