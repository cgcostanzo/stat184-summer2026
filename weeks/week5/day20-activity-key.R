# Day 20 In-Class Activity KEY: Writing Functions in R
# STAT 184 - Monday, June 15, 2026
# ============================================================
# Instructor solution key. One reasonable solution per part;
# students' working code may differ.
# ============================================================

library(tidyverse)
library(nycflights13)


# --- Part 1: Vector functions -------------------------------------------------

# 1a. The bug: column b divides by min(a, ...) instead of min(b, ...).
df <- tibble(a = 1:5, b = 6:10, c = c(2, 4, 6, 8, 10))
df |> mutate(
  a = (a - min(a, na.rm = TRUE)) / (max(a, na.rm = TRUE) - min(a, na.rm = TRUE)),
  b = (b - min(a, na.rm = TRUE)) / (max(b, na.rm = TRUE) - min(b, na.rm = TRUE)),  # bug
  c = (c - min(c, na.rm = TRUE)) / (max(c, na.rm = TRUE) - min(c, na.rm = TRUE))
)

# Q1. Replacing the column with a single argument x makes it impossible to refer
#     to the "wrong" column: there is only one thing being rescaled, named once.

# 1b.
rescale01 <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# 1c.
rescale01(c(-10, 0, 10))        # 0.0 0.5 1.0
rescale01(c(1, 2, 3, NA, 5))    # 0.00 0.25 0.50 NA 1.00

# 1d.
df |> mutate(a = rescale01(a), b = rescale01(b), c = rescale01(c))

# 1e.
z_score <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}
flights |> mutate(z_delay = z_score(dep_delay)) |> select(dep_delay, z_delay)

# 1f.
n_missing <- function(x) {
  sum(is.na(x))
}
flights |> summarize(missing_delays = n_missing(dep_delay))

# Q2. A mutate function returns a vector the SAME LENGTH as its input, so it goes
#     inside mutate()/filter(). A summary function returns a SINGLE value, so it
#     goes inside summarize().


# --- Part 2: Data frame functions ---------------------------------------------

# 2a. Fixed by embracing both column arguments with {{ }}.
grouped_mean <- function(df, group_var, mean_var) {
  df |>
    group_by({{ group_var }}) |>
    summarize(mean = mean({{ mean_var }}, na.rm = TRUE), .groups = "drop")
}
flights |> grouped_mean(origin, dep_delay)

# Q3. Without {{ }}, group_by() treats "group_var" literally — it looks for a
#     column actually named group_var, which doesn't exist. Embracing tells dplyr
#     to look INSIDE the argument for the column the caller supplied.

# 2b.
count_prop <- function(df, var, sort = FALSE) {
  df |>
    count({{ var }}, sort = sort) |>
    mutate(prop = n / sum(n))
}
flights |> count_prop(carrier, sort = TRUE)

# 2c.
summary6 <- function(data, var) {
  data |> summarize(
    min    = min({{ var }}, na.rm = TRUE),
    mean   = mean({{ var }}, na.rm = TRUE),
    median = median({{ var }}, na.rm = TRUE),
    max    = max({{ var }}, na.rm = TRUE),
    n      = n(),
    n_miss = sum(is.na({{ var }})),
    .groups = "drop"
  )
}
flights |> summary6(arr_delay)

# Q4. It works on grouped data with no changes because it just wraps summarize(),
#     which already respects existing groups. .groups = "drop" leaves the result
#     ungrouped afterward.
flights |> group_by(origin) |> summary6(arr_delay)


# --- Part 3 (challenge): Plot functions ---------------------------------------

# 3a.
histogram <- function(df, var, binwidth = NULL) {
  df |>
    ggplot(aes(x = {{ var }})) +
    geom_histogram(binwidth = binwidth)
}
flights |> histogram(dep_delay, binwidth = 10)

# 3b.
flights |>
  histogram(dep_delay, binwidth = 10) +
  labs(x = "Departure delay (minutes)", y = "Number of flights")

# 3c.
sorted_bars <- function(df, var) {
  df |>
    mutate({{ var }} := fct_rev(fct_infreq({{ var }}))) |>
    ggplot(aes(y = {{ var }})) +
    geom_bar()
}
flights |> sorted_bars(carrier)

# 3d.
histogram <- function(df, var, binwidth) {
  label <- rlang::englue("A histogram of {{var}} with binwidth {binwidth}")
  df |>
    ggplot(aes(x = {{ var }})) +
    geom_histogram(binwidth = binwidth) +
    labs(title = label)
}
flights |> histogram(dep_delay, binwidth = 10)

# Q5. R's syntax only allows a single literal name on the left of =. Because the
#     name comes from a user-supplied (embraced) variable, we use the walrus
#     operator := , which tidy evaluation treats exactly like = but permits
#     {{ }} on the left-hand side.
