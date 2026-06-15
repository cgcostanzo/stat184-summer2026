# Day 20 In-Class Activity: Writing Functions in R
# STAT 184 - Monday, June 15, 2026
# ============================================================

library(tidyverse)
library(nycflights13)


# --- Part 1: Vector functions -------------------------------------------------
# A vector function takes one or more vectors and returns a vector.

# 1a. Here is a block of repeated code. It rescales each column to run 0 to 1,
#     but there is a copy-paste bug. 
df <- tibble(a = 1:5, b = 6:10, c = c(2, 4, 6, 8, 10))
df |> mutate(
  a = (a - min(a, na.rm = TRUE)) / (max(a, na.rm = TRUE) - min(a, na.rm = TRUE)),
  b = (b - min(a, na.rm = TRUE)) / (max(b, na.rm = TRUE) - min(b, na.rm = TRUE)),
  c = (c - min(c, na.rm = TRUE)) / (max(c, na.rm = TRUE) - min(c, na.rm = TRUE))
)

# Q1. What is the bug, and how would a function have prevented it?

# 1b. Turn the repeated line into a function called rescale01() with one
#     argument, x. The body is the part that repeats (with the column replaced
#     by x). Fill in the body:
# rescale01 <- function(x) {
#   ...
# }

# 1c. Test your function on inputs where you know the answer. These should give
#     c(0, 0.5, 1) and c(0, 0.25, 0.5, NA, 1):
# rescale01(c(-10, 0, 10))
# rescale01(c(1, 2, 3, NA, 5))

# 1d. Now rewrite the mutate() from 1a using your function. No more bug possible:
# df |> mutate(a = rescale01(a), b = rescale01(b), c = rescale01(c))

# 1e. Write a mutate function z_score() that returns (x - mean) / sd, removing
#     NAs. (Same length out as in.) Test it on flights$dep_delay inside mutate().
# z_score <- function(x) {
#   ...
# }

# 1f. Write a summary function n_missing() that returns the number of NA values
#     in a vector (a single number out). Use it to count missing dep_delay:
# n_missing <- function(x) {
#   ...
# }
# flights |> summarize(missing_delays = n_missing(dep_delay))

# Q2. In your own words: what is the difference between a "mutate" function and
#     a "summary" function, and which verb does each one belong inside?


# --- Part 2: Data frame functions ---------------------------------------------
# A data frame function takes a data frame as its first argument and returns a
# data frame. Inside, you must embrace column arguments using {{ }}.

# 2a. This function is supposed to group by one variable and average another,
#     but it ERRORS. Run it to see the error, then fix it by embracing the two
#     column arguments with {{ }}.
grouped_mean <- function(df, group_var, mean_var) {
  df |>
    group_by(group_var) |>
    summarize(mean = mean(mean_var, na.rm = TRUE), .groups = "drop")
}
# flights |> grouped_mean(origin, dep_delay)   # errors until you fix it

# Q3. Why does the un-embraced version fail? (Hint: what does group_by() think
#     "group_var" is the name of?)

# 2b. Write count_prop(): it counts a variable and adds a proportion column.
#     Only ONE argument needs embracing. Give `sort` a default of FALSE.
# count_prop <- function(df, var, sort = FALSE) {
#   df |>
#     count(...) |>
#     mutate(prop = n / sum(n))
# }
# flights |> count_prop(carrier, sort = TRUE)

# 2c. Write summary6(): for a user-supplied variable, return min, mean, median,
#     max, n, and number missing. Remember na.rm = TRUE and .groups = "drop".
# summary6 <- function(data, var) {
#   data |> summarize(
#     min    = min({{ var }}, na.rm = TRUE),
#     ...
#     .groups = "drop"
#   )
# }
# flights |> summary6(arr_delay)

# Q4. Your summary6() wraps summarize(), so it should also work on GROUPED data
#     for free. Try: flights |> group_by(origin) |> summary6(arr_delay)
#     Does it work without changing the function? Why?


# --- Part 3 (challenge): Plot functions ---------------------------------------
# aes() is also a data-masking function, so the same {{ }} trick builds plots.

# 3a. Write histogram(): given a data frame, a variable, and a binwidth, draw a
#     histogram of that variable. Remember to embrace var inside aes().
# histogram <- function(df, var, binwidth = NULL) {
#   df |>
#     ggplot(aes(x = {{ var }})) +
#     geom_histogram(binwidth = binwidth)
# }
# flights |> histogram(dep_delay, binwidth = 10)

# 3b. A plot function returns a ggplot object, so you can keep adding layers
#     with +. Add axis labels to your histogram from 3a.

# 3c. Write sorted_bars(): a bar chart with bars ordered by frequency, highest
#     on top. This needs the walrus operator := because the new column name
#     comes from a user-supplied variable. Fill in the blanks:
# sorted_bars <- function(df, var) {
#   df |>
#     mutate({{ var }} := fct_rev(fct_infreq({{ var }}))) |>
#     ggplot(aes(y = {{ var }})) +
#     geom_bar()
# }
# flights |> sorted_bars(carrier)

# 3d. Add an automatic title to histogram() using rlang::englue(), which
#     understands {{ }} and inserts the variable's NAME into the string:
#     label <- rlang::englue("A histogram of {{var}} with binwidth {binwidth}")
#     ... then pass label to labs(title = label).

# Q5. Why do we need := in sorted_bars() instead of just =?
