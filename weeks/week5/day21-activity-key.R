# Day 21 In-Class Activity KEY: Iteration with across()
# STAT 184 - Tuesday, June 16, 2026
# ============================================================
# Instructor solution key. One reasonable solution per part;
# students' working code may differ.
# ============================================================

library(tidyverse)
library(nycflights13)

set.seed(1014)
df <- tibble(a = rnorm(10), b = rnorm(10), c = rnorm(10), d = rnorm(10))


# --- Part 1: From copy-paste to across() --------------------------------------

# 1a.
df |> summarize(
  n = n(),
  a = median(a),
  b = median(b),
  c = median(c),
  d = median(d)
)

# 1b.
df |> summarize(
  n = n(),
  across(a:d, median)
)

# Q1. across() CALLS the function for you, once per column. You hand it the
#     function object (median). Writing median() calls it immediately with no
#     argument, which errors ("argument x is missing").

# 1c.
df |> summarize(across(everything(), mean))

# 1d.
flights |>
  summarize(across(where(is.numeric), \(x) mean(x, na.rm = TRUE))) |>
  glimpse()

# Q2. No. Grouping columns are excluded from across() automatically because
#     summarize()/mutate() already preserve them. Example:
df |>
  mutate(grp = rep(1:2, 5)) |>
  group_by(grp) |>
  summarize(across(everything(), mean))   # grp is not re-summarized


# --- Part 2: Missing values & multiple functions ------------------------------

df_miss <- tibble(
  a = c(1, 2, NA, 4, 5),
  b = c(NA, 2, 3, NA, 5),
  c = c(1, 2, 3, 4, 5)
)

# 2a. Columns a and b return NA, because median() propagates missing values.
df_miss |> summarize(across(a:c, median))

# 2b.
df_miss |> summarize(across(a:c, \(x) median(x, na.rm = TRUE)))

# 2c.
df_miss |> summarize(
  across(a:c, list(
    median = \(x) median(x, na.rm = TRUE),
    n_miss = \(x) sum(is.na(x))
  ))
)

# Q3. With .names = "{.fn}_{.col}" the names flip from a_median to median_a, etc.
df_miss |> summarize(
  across(a:c, list(
    median = \(x) median(x, na.rm = TRUE),
    n_miss = \(x) sum(is.na(x))
  ), .names = "{.fn}_{.col}")
)


# --- Part 3 (challenge): across() in mutate(), and if_all()/if_any() ----------

# 3a.
clamp01 <- function(x) {
  pmin(pmax(x, 0), 1)
}
clamp01(c(-0.5, 0.2, 1.4))   # 0.0 0.2 1.0

# 3b.
demo <- tibble(x = c(-0.5, 0.2, 1.4), y = c(2, -1, 0.5), label = c("a", "b", "c"))
demo |> mutate(across(where(is.numeric), clamp01))

# 3c.
flights |>
  filter(if_all(c(dep_time, arr_time, dep_delay, arr_delay), \(x) !is.na(x))) |>
  nrow()

# 3d.
flights |>
  filter(if_any(c(dep_delay, arr_delay), \(x) x > 0)) |>
  nrow()

# Q4. if_all() keeps a row only when the condition is TRUE for EVERY listed
#     column (logical AND). if_any() keeps a row when it is TRUE for AT LEAST ONE
#     listed column (logical OR). Use if_all() to require all conditions (e.g.,
#     complete cases); use if_any() to catch rows flagged by any condition.
