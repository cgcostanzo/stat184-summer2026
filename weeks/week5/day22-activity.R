# Day 22 In-Class Activity: Iteration with map() and walk()
# STAT 184 - Wednesday, June 17, 2026
# ============================================================
# Parts 2 and 3 write files. We write them to a temporary folder
# so nothing clutters your project. Run this line first:
out_dir <- tempdir()
# ============================================================

library(tidyverse)

# --- Part 1: map() basics -----------------------------------------------------

# 1a. Use map() to square each of the following numbers: 1, 2, 3. 
#     What type of object is returned?

# 1b. You usually want a plain vector instead of alist. 
#     Redo 1a with map_dbl() so you get a vector of type numeric (double) instead.

# 1c. Use map_int() to get the length of each element of this list:
my_list <- list(a = 1:5, b = 1:10, c = letters)

# 1d. A data frame is a list of columns, so map walks over columns. Use map_dbl()
#     to compute the mean of each numeric column below. (na.rm = TRUE!)
nums <- tibble(x = c(1, 2, NA, 4), y = c(10, 20, 30, 40), z = c(5, 5, 5, 5))

# Q1. map_dbl(nums, median) and summarize(nums, across(everything(), median))
#     give the same numbers. What is the difference between map() and across()?


# --- Part 2: walk2() to write one CSV per group -------------------------------
# Goal: save one CSV file for each diamond `cut`.

# 2a. Use group_nest() to split diamonds by cut. This makes a list-column named
#     `data`, one tibble per cut.

# 2b. Add a `path` column with the output file name for each cut. Use str_glue()
#     and file.path() so the files are outputted to out_dir.

# 2c. There are two things that vary per row: the data and the path. Use walk2()
#     with write_csv() to save every file at once.

# 2d. Confirm the files were written by running the following code:
# list.files(out_dir, pattern = "diamonds-.*\\.csv")

# Q2. Why do we use walk2() here instead of map2()? What would map2() return that
#     we don't need?


# --- Part 3 (challenge): save one plot per group ------------------------------

# 3a. Write a function price_histogram() that takes a data frame and returns a
#     histogram of `price` (try binwidth = 500).
# price_histogram <- function(df) {
#   ...
# }
# price_histogram(by_cut$data[[1]]) # test on one group

# 3b. Use mutate() + map() to build a list-column of plots (one per cut), and add
#     a .png path column with str_glue() + file.path().
# by_cut <- by_cut |>
#   mutate(
#     plot = ...
#     png_path = ...
#   )

# 3c. Save them all with walk2() + ggsave(). Because ggsave() takes the filename
#     first and the plot second, use an anonymous function to pass them in order.

# Q3. The map/walk pattern is identical whether we read files, write CSVs, or
#     save plots. What is that shared pattern?
