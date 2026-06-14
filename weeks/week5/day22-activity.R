# Day 22 In-Class Activity: Iteration with map() and walk()
# STAT 184 - Wednesday, June 17, 2026
# ============================================================
# Work through the parts in order. Part 3 is a challenge;
# skip to it only if you finish Parts 1 and 2 with time left.
#
# Big idea: map() does something to EACH element of a list/vector;
# walk() does the same when you only care about a side effect
# (like writing a file). map2()/walk2() vary TWO inputs together.
#
# Parts 2 and 3 write files. We write them to a temporary folder
# so nothing clutters your project. Run this line first:
out_dir <- tempdir()
# ============================================================

library(tidyverse)


# --- Part 1: map() basics -----------------------------------------------------

# 1a. Use map() to square each of the numbers 1, 2, 3. What TYPE of object comes
#     back? (Look at the result; it should be a list.)
# map(1:3, \(x) x^2)

# 1b. You usually want a plain vector, not a list. Redo 1a with map_dbl() so you
#     get a double vector instead.
# map_dbl(1:3, \(x) x^2)

# 1c. Use map_int() to get the length of each element of this list:
my_list <- list(a = 1:5, b = 1:10, c = letters)
# map_int(my_list, length)

# 1d. A data frame is a list of columns, so map walks over columns. Use map_dbl()
#     to compute the mean of each numeric column below. (na.rm = TRUE!)
nums <- tibble(x = c(1, 2, NA, 4), y = c(10, 20, 30, 40), z = c(5, 5, 5, 5))
# map_dbl(nums, \(col) mean(col, na.rm = TRUE))

# Q1. map_dbl(nums, median) and summarize(nums, across(everything(), median))
#     give the same numbers. In one sentence, what is the difference between
#     map() and across()?


# --- Part 2: walk2() to write one CSV per group -------------------------------
# Goal: save one CSV file for each diamond `cut`.

# 2a. Use group_nest() to split diamonds by cut. This makes a list-column named
#     `data`, one tibble per cut. Run it and look at the result.
# by_cut <- diamonds |> group_nest(cut)
# by_cut

# 2b. Add a `path` column with the output file name for each cut. Use str_glue()
#     and file.path() so the files land in out_dir.
# by_cut <- by_cut |>
#   mutate(path = file.path(out_dir, str_glue("diamonds-{cut}.csv")))
# by_cut

# 2c. There are TWO things that vary per row: the data and the path. Use walk2()
#     with write_csv() to save every file at once. (Why walk2 and not map2?)
# walk2(by_cut$data, by_cut$path, write_csv)

# 2d. Confirm the files were written:
# list.files(out_dir, pattern = "diamonds-.*\\.csv")

# Q2. Why do we use walk2() here instead of map2()? What would map2() return that
#     we don't need?


# --- Part 3 (challenge): save one plot per group ------------------------------

# 3a. Write a function price_histogram() that takes a data frame and returns a
#     histogram of `price` (try binwidth = 500).
# price_histogram <- function(df) {
#   ggplot(df, aes(x = price)) + geom_histogram(binwidth = 500)
# }
# price_histogram(by_cut$data[[1]])   # test on one group

# 3b. Use mutate() + map() to build a list-column of plots (one per cut), and add
#     a .png path column with str_glue() + file.path().
# by_cut <- by_cut |>
#   mutate(
#     plot     = map(data, price_histogram),
#     png_path = file.path(out_dir, str_glue("price-{cut}.png"))
#   )

# 3c. Save them all with walk2() + ggsave(). Because ggsave() takes the filename
#     first and the plot second, use an anonymous function to pass them in order.
# walk2(
#   by_cut$png_path,
#   by_cut$plot,
#   \(path, plot) ggsave(path, plot, width = 6, height = 4)
# )
# list.files(out_dir, pattern = "price-.*\\.png")

# Q3. The map/walk pattern is identical whether we read files, write CSVs, or
#     save plots. In your own words, what is that shared pattern?
