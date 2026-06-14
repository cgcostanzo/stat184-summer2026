# Day 22 In-Class Activity KEY: Iteration with map() and walk()
# STAT 184 - Wednesday, June 17, 2026
# ============================================================
# Instructor solution key. One reasonable solution per part;
# students' working code may differ.
# ============================================================

library(tidyverse)

out_dir <- tempdir()


# --- Part 1: map() basics -----------------------------------------------------

# 1a. Returns a LIST (one element per input).
map(1:3, \(x) x^2)

# 1b.
map_dbl(1:3, \(x) x^2)        # 1 4 9

# 1c.
my_list <- list(a = 1:5, b = 1:10, c = letters)
map_int(my_list, length)      # 5 10 26

# 1d.
nums <- tibble(x = c(1, 2, NA, 4), y = c(10, 20, 30, 40), z = c(5, 5, 5, 5))
map_dbl(nums, \(col) mean(col, na.rm = TRUE))

# Q1. across() iterates specifically over the COLUMNS of a data frame inside a
#     dplyr verb; map() is the general tool that iterates over EVERY element of
#     any list or vector (and a data frame is a list of columns).


# --- Part 2: walk2() to write one CSV per group -------------------------------

# 2a.
by_cut <- diamonds |> group_nest(cut)
by_cut

# 2b.
by_cut <- by_cut |>
  mutate(path = file.path(out_dir, str_glue("diamonds-{cut}.csv")))
by_cut

# 2c.
walk2(by_cut$data, by_cut$path, write_csv)

# 2d.
list.files(out_dir, pattern = "diamonds-.*\\.csv")

# Q2. We call write_csv() only for its SIDE EFFECT (a file on disk); we don't
#     need its return value. map2() would build and return a list of those return
#     values, which we'd just throw away. walk2() returns its input invisibly.


# --- Part 3 (challenge): save one plot per group ------------------------------

# 3a.
price_histogram <- function(df) {
  ggplot(df, aes(x = price)) + geom_histogram(binwidth = 500)
}
price_histogram(by_cut$data[[1]])

# 3b.
by_cut <- by_cut |>
  mutate(
    plot     = map(data, price_histogram),
    png_path = file.path(out_dir, str_glue("price-{cut}.png"))
  )

# 3c.
walk2(
  by_cut$png_path,
  by_cut$plot,
  \(path, plot) ggsave(path, plot, width = 6, height = 4)
)
list.files(out_dir, pattern = "price-.*\\.png")

# Q3. Get one thing per item (a path, a data frame, a plot), apply the same
#     function to each item, and collect or discard the results. map() keeps the
#     results; walk() runs them for the side effect. map2()/walk2() do it when two
#     inputs vary together.
