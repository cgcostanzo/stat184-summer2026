# Day 21 In-Class Activity: Iteration with across()
# STAT 184 - Tuesday, June 16, 2026
# ============================================================
# Work through the parts in order. Part 3 is a challenge;
# skip to it only if you finish Parts 1 and 2 with time left.
#
# Big idea: across() repeats an action over many columns, so you
# never copy-and-paste the same summarize()/mutate() line again.
# ============================================================

library(tidyverse)
library(nycflights13)

set.seed(1014)
df <- tibble(a = rnorm(10), b = rnorm(10), c = rnorm(10), d = rnorm(10))


# --- Part 1: From copy-paste to across() --------------------------------------

# 1a. Here is the copy-pasted version that computes the median of every column.
#     Run it to see the result.
df |> summarize(
  n = n(),
  a = median(a),
  b = median(b),
  c = median(c),
  d = median(d)
)

# 1b. Rewrite 1a using across(). The first argument is the columns (a:d), the
#     second is the function NAME with NO parentheses. Keep n = n() too.
# df |> summarize(
#   n = n(),
#   across(...)
# )

# Q1. Why must you write `median` and not `median()` as the second argument?
#     (Try across(a:d, median()) and read the error.)

# 1c. Use across() with everything() to take the mean of every column of df.
# df |> summarize(across(everything(), mean))

# 1d. flights has many columns of different types. Use across() with
#     where(is.numeric) to count how many columns are numeric. (Hint: wrap a
#     function that returns TRUE, or just glimpse the result of taking a
#     summary across the numeric columns.)
# flights |> summarize(across(where(is.numeric), \(x) mean(x, na.rm = TRUE))) |> glimpse()

# Q2. In 1c, df had no grouping. If you first group_by() a column, does that
#     grouping column show up inside across(everything())? Try it and explain.


# --- Part 2: Missing values & multiple functions ------------------------------

df_miss <- tibble(
  a = c(1, 2, NA, 4, 5),
  b = c(NA, 2, 3, NA, 5),
  c = c(1, 2, 3, 4, 5)
)

# 2a. Take the median across a:c. What happens to columns with NA values?
# df_miss |> summarize(across(a:c, median))

# 2b. Fix it with an ANONYMOUS function so na.rm = TRUE is passed to median().
#     \(x) is shorthand for function(x).
# df_miss |> summarize(across(a:c, \(x) median(x, na.rm = TRUE)))

# 2c. Apply TWO functions at once with a named list: the median (NA-removed) and
#     the number of missing values. Fill in the blanks.
# df_miss |> summarize(
#   across(a:c, list(
#     median = \(x) median(x, na.rm = TRUE),
#     n_miss = ...
#   ))
# )

# Q3. The output columns came back named like a_median, a_n_miss, i.e.
#     {.col}_{.fn}. Add .names = "{.fn}_{.col}" to the across() call. How do the
#     column names change?


# --- Part 3 (challenge): across() in mutate(), and if_all()/if_any() ----------

# 3a. Write a small function clamp01() that caps a vector at 0 below and 1 above
#     (anything < 0 becomes 0, anything > 1 becomes 1). Use case_when() or
#     pmin()/pmax().
# clamp01 <- function(x) {
#   ...
# }

# 3b. Build a tibble and apply clamp01() to EVERY numeric column at once using
#     mutate() + across(). (Recall: pass the function name with no parentheses.)
demo <- tibble(x = c(-0.5, 0.2, 1.4), y = c(2, -1, 0.5), label = c("a", "b", "c"))
# demo |> mutate(across(where(is.numeric), clamp01))

# 3c. across() does not work in filter(); use if_all() / if_any() instead.
#     Keep only flights with NO missing value in ANY of these timing columns:
# flights |>
#   filter(if_all(c(dep_time, arr_time, dep_delay, arr_delay), \(x) !is.na(x)))

# 3d. Now use if_any() to keep flights that were delayed (> 0) on EITHER
#     departure or arrival. Compare how many rows each returns.
# flights |>
#   filter(if_any(c(dep_delay, arr_delay), \(x) x > 0))

# Q4. In your own words, what is the difference between if_all() and if_any()?
#     When would each be the right choice?
