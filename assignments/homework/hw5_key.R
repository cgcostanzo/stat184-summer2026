# STAT 184 - Homework 5 KEY: Functions, Iteration & Regular Expressions
# Week 5 (June 15-19, 2026)
# ============================================================
# Instructor solution key. One reasonable solution per part;
# students' working code may differ. Covers:
#   Q1 - writing functions (day 20)
#   Q2 - across() over many columns (day 21)
#   Q3 - map() / walk() over lists, files & groups (day 22)
#   Q4 - regular expressions: detect / extract / clean (day 23)
# ============================================================

library(tidyverse)
library(nycflights13)


# --- Question 1: Writing functions --------------------------------------------

# 1a. SUMMARY function: coefficient of variation (sd relative to the mean),
#     with an na.rm argument defaulting to FALSE.
cv <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}

# Test on a known input: c(2, 4, 4, 4, 5, 5, 7, 9) has mean 5, sd 2, so cv = 0.4.
cv(c(2, 4, 4, 4, 5, 5, 7, 9))   # 0.4

# Use it as a summary function (single value out -> goes in summarize()):
flights |> summarize(cv_dep_delay = cv(dep_delay, na.rm = TRUE))

# Q1a. cv() is a SUMMARY function: it collapses a vector to a single number, so
#      it belongs inside summarize(). A MUTATE function would return a vector the
#      same length as its input and belong inside mutate()/filter().

# 1b. DATA FRAME function: group by one variable, summarize another. Both column
#     arguments must be embraced with {{ }}.
grouped_stats <- function(df, group_var, num_var) {
  df |>
    group_by({{ group_var }}) |>
    summarize(
      n      = n(),
      mean   = mean({{ num_var }}, na.rm = TRUE),
      median = median({{ num_var }}, na.rm = TRUE),
      sd     = sd({{ num_var }}, na.rm = TRUE),
      .groups = "drop"
    )
}
flights |> grouped_stats(origin, dep_delay)

# Q1b. Without {{ }}, group_by(group_var) looks for a column literally named
#      "group_var", which does not exist -> error. Embracing tells dplyr to look
#      INSIDE the argument and use the column the caller actually supplied.

# 1c. PLOT function: a scatterplot of y vs x with a linear trend line. Each
#     variable passed to aes() must be embraced. englue() inserts the variable
#     names into an automatic title.
scatter <- function(df, x, y) {
  label <- rlang::englue("{{y}} vs. {{x}}")
  df |>
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_point(alpha = 0.3) +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
    labs(title = label)
}
diamonds |> scatter(carat, price)


# --- Question 2: across() over many columns -----------------------------------

# 2a. Average every numeric column of diamonds. An anonymous function \(x)
#     supplies na.rm = TRUE.
diamonds |>
  summarize(across(where(is.numeric), \(x) mean(x, na.rm = TRUE)))

# 2b. For the timing columns, report BOTH the mean and the count of missing
#     values, using a named list. .names = "{.fn}_{.col}" puts the function
#     name first.
flights |>
  summarize(
    across(
      c(dep_delay, arr_delay, air_time),
      list(
        mean   = \(x) mean(x, na.rm = TRUE),
        n_miss = \(x) sum(is.na(x))
      ),
      .names = "{.fn}_{.col}"
    )
  )

# 2c. Reuse a function with across() inside mutate(), then filter with if_all().
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# Rescale the four C's of diamonds quality measurements at once:
diamonds |>
  mutate(across(c(carat, depth, table, price), rescale01)) |>
  select(carat, depth, table, price)

# Keep only flights with NO missing value in any of these timing columns, and
# count how many remain.
flights |>
  filter(if_all(c(dep_time, arr_time, dep_delay, arr_delay), \(x) !is.na(x))) |>
  nrow()

# Q2. across() writes the copy-pasted version for you: across(a:b, f) is exactly
#     equivalent to a = f(a), b = f(b). It removes the copy-paste mistakes and
#     scales to any number of columns.


# --- Question 3: map() / walk() -----------------------------------------------

# 3a. The typed map variants return atomic vectors (and error if the result is
#     not that type). \(x) is the same anonymous-function shorthand.
map_dbl(1:10, \(x) x^2)                       # squares, as a double vector
map_int(list(1:5, 1:100, letters), length)    # lengths, as an integer vector
map_chr(c("ada", "grace"), \(x) str_to_title(x))

# 3b. A data frame is a list of columns, so map_dbl() walks over its columns.
nums <- diamonds |> select(carat, depth, price)
map_dbl(nums, median)

# Q3b. This reaches the same place as
#      diamonds |> summarize(across(c(carat, depth, price), median)).
#      across() iterates over columns inside a verb; map_dbl() iterates over the
#      columns as list elements. Same idea ("do this to each thing"), two tools.

# 3c. Save one CSV per cut. group_nest() builds a per-group list-column; str_glue()
#     builds the paths; walk2() writes each (data, path) pair.
out_dir <- tempdir()    # a safe temporary folder; nothing clutters your project

by_cut <- diamonds |>
  group_nest(cut) |>
  mutate(path = str_glue("{out_dir}/diamonds-{cut}.csv"))
by_cut

walk2(by_cut$data, by_cut$path, write_csv)

# Confirm the files were written:
list.files(out_dir, pattern = "^diamonds-.*\\.csv$")

# 3c (challenge). Build a list-column of plots with map(), then save them all
#     with walk2() + ggsave().
carat_histogram <- function(df) {
  ggplot(df, aes(x = carat)) + geom_histogram(binwidth = 0.1)
}

by_cut <- by_cut |>
  mutate(
    plot     = map(data, carat_histogram),
    plotpath = str_glue("{out_dir}/carat-{cut}.png")
  )

walk2(
  by_cut$plotpath,
  by_cut$plot,
  \(path, plot) ggsave(path, plot, width = 6, height = 4)
)
list.files(out_dir, pattern = "^carat-.*\\.png$")

# Q3c. walk() (not map()) because we only care about the SIDE EFFECT -- the files
#      landing on disk -- not about any return value.


# --- Question 4: Regular expressions ------------------------------------------
# Uses the built-in character vectors that come with stringr: `fruit`, `words`,
# and `sentences` (no extra packages needed).

# 4a. DETECT. str_detect() returns TRUE/FALSE; str_subset() keeps the matches.
str_subset(fruit, "berry")          # fruits containing "berry"
str_subset(fruit, "^a")             # fruits starting with "a"
sum(str_detect(words, "^.{3}$"))    # how many words are exactly 3 letters long

# 4b. Build patterns from character classes, quantifiers and anchors.

# "Caitlin"-style names: capital C, a vowel, then "tl" somewhere, on words that
# start with c. (Here we just demo the class/quantifier mechanics on `words`.)
str_subset(words, "^[bcd]")[1:5]              # words starting with b, c, or d
str_subset(words, "^[^aeiou]{3}")             # start with 3 consonants in a row
str_subset(words, "[aeiou]{3,}")              # 3+ vowels in a row

# A phone-number pattern: (123) 456-7890  OR  123-456-7890
phones <- c("(651) 696-6000", "123-456-7890", "555.123.4567", "not a phone")
phone_re <- "^\\(?\\d{3}\\)?[ -]?\\d{3}-\\d{4}$"
str_detect(phones, phone_re)                  # TRUE TRUE FALSE FALSE

# Q4b. \\d matches a digit; {3} means exactly three of them; \\(? and \\)? make
#      the literal parentheses optional (the ? quantifier = zero or one); the
#      anchors ^ and $ force the WHOLE string to be a phone number.

# 4c. EXTRACT with a capture group, then CLEAN messy strings.

# Extract the LAST vowel of each fruit name with a capture group:
tibble(fruit = fruit) |>
  mutate(last_vowel = str_extract(fruit, "[aeiou](?=[^aeiou]*$)")) |>
  head(6)

# Equivalent extraction with base R + a backreference \\1:
re <- ".*([aeiou]).*?$"
gsub(re, "\\1", head(fruit))

# Clean a messy tibble of scraped numbers: strip $, commas, %, and units.
debt <- tibble(
  country = c("World", "United States*", "Japan"),
  debt    = c("$56,308 billion", "$17,607 billion", "$9,872 billion"),
  percGDP = c("64%", "73.60%", "214.30%")
)
debt |>
  mutate(
    country = str_remove_all(country, "\\*"),       # drop the trailing asterisk
    debt    = parse_number(debt),                   # parse_number ignores $ , and "billion"
    percGDP = as.numeric(str_remove_all(percGDP, "[,%]"))
  )

# Q4c. The three regex jobs are DETECT (does the pattern occur? str_detect /
#      grepl), EXTRACT (pull the matched text out, with ( ) to capture pieces;
#      str_extract / \\1 in gsub), and REPLACE/clean (str_remove_all / gsub).
