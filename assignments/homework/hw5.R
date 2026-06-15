# STAT 184 - Homework 5: Functions, Iteration & Regular Expressions
# Week 5 (June 15-19, 2026)
# ============================================================
# Due: see Canvas.
#
# HOW TO WORK THIS HOMEWORK
#   - Fill in the blanks (lines that are commented out or marked ___).
#   - Run each chunk and check that the output looks right.
#   - Answer every question marked "Q" in a comment, in your own words.
#   - You may use AI tools per the course policy, but you must read and
#     understand everything you submit (add a one-line AI use note at the
#     bottom of this file).
#
# This homework follows the four lectures of the week:
#   Q1 - writing functions          (day 20)
#   Q2 - across() over many columns (day 21)
#   Q3 - map() / walk()             (day 22)
#   Q4 - regular expressions        (day 23)
# ============================================================

library(tidyverse)
library(nycflights13)


# --- Question 1: Writing functions --------------------------------------------
# Recall: a SUMMARY function returns a single value (use in summarize()); a
# MUTATE function returns a vector the same length as its input (use in mutate());
# a DATA FRAME function takes a data frame first and embraces column args with {{ }}.

# 1a. Write a SUMMARY function cv() that returns the coefficient of variation:
#     the standard deviation divided by the mean. Give it an na.rm argument that
#     defaults to FALSE and pass it through to both sd() and mean().
# cv <- function(x, na.rm = FALSE) {
#   ___
# }

# TEST it on c(2, 4, 4, 4, 5, 5, 7, 9). This vector has mean 5 and sd 2, so you
# should get exactly 0.4:
# cv(c(2, 4, 4, 4, 5, 5, 7, 9))

# Now use cv() to summarize the departure delays in flights (remember na.rm):
# flights |> summarize(cv_dep_delay = cv(dep_delay, na.rm = TRUE))

# Q1a. Is cv() a summary function or a mutate function? Which verb does it belong
#      inside, and why?


# 1b. Write a DATA FRAME function grouped_stats(df, group_var, num_var) that
#     groups by group_var and returns n, mean, median, and sd of num_var.
#     EMBRACE both column arguments with {{ }}. Use na.rm = TRUE and
#     .groups = "drop".
# grouped_stats <- function(df, group_var, num_var) {
#   df |>
#     group_by(___) |>
#     summarize(
#       n      = n(),
#       mean   = ___,
#       median = ___,
#       sd     = ___,
#       .groups = "drop"
#     )
# }
# flights |> grouped_stats(origin, dep_delay)

# Q1b. If you forgot the {{ }} and wrote group_by(group_var), what error would
#      you get, and why?


# 1c. Write a PLOT function scatter(df, x, y) that draws a scatterplot of y vs x
#     with a linear trend line (geom_smooth(method = "lm")). Embrace x and y
#     inside aes(). Test it with: diamonds |> scatter(carat, price)
# scatter <- function(df, x, y) {
#   df |>
#     ggplot(aes(x = ___, y = ___)) +
#     geom_point(alpha = 0.3) +
#     geom_smooth(method = "lm", formula = y ~ x, se = FALSE)
# }
# diamonds |> scatter(carat, price)

# 1c (optional). Add an automatic title using rlang::englue(), which understands
#     {{ }} and inserts the variable NAME into a string, e.g.:
#       label <- rlang::englue("{{y}} vs. {{x}}")
#     then add + labs(title = label).


# --- Question 2: across() over many columns -----------------------------------
# across(.cols, .fns, .names) repeats an action over a set of columns.
# Pass the function NAME with no (); use \(x) f(x, ...) to add arguments.

# 2a. Average EVERY numeric column of diamonds in one summarize(). Use
#     where(is.numeric) to pick the columns and an anonymous function to supply
#     na.rm = TRUE.
# diamonds |>
#   summarize(across(___, \(x) ___))

# 2b. For the columns dep_delay, arr_delay, and air_time in flights, report BOTH
#     the mean and the number of missing values. Pass a NAMED LIST to .fns, and
#     use .names = "{.fn}_{.col}" so the columns are named mean_dep_delay,
#     n_miss_dep_delay, and so on.
# flights |>
#   summarize(
#     across(
#       c(dep_delay, arr_delay, air_time),
#       list(
#         mean   = \(x) ___,
#         n_miss = \(x) ___
#       ),
#       .names = "___"
#     )
#   )

# 2c. Reuse this rescale01() function (from class) with across() inside mutate()
#     to rescale carat, depth, table, and price of diamonds to run 0 to 1:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
# diamonds |>
#   mutate(across(___, rescale01)) |>
#   select(carat, depth, table, price)

# Then use if_all() inside filter() to keep only flights with NO missing value
# in any of dep_time, arr_time, dep_delay, arr_delay, and count the rows:
# flights |>
#   filter(if_all(___, \(x) !is.na(x))) |>
#   nrow()

# Q2. across(a:b, f) is shorthand for what longer, copy-pasted code? Why is the
#     across() version less error-prone?


# --- Question 3: map() / walk() -----------------------------------------------
# map(x, f) applies f to each element of x and returns a LIST. The typed
# variants (map_dbl, map_int, map_chr, map_lgl) return atomic VECTORS.

# 3a. Use the typed map variants to produce:
#     - the squares of 1:10 as a double vector
#     - the length of each element of list(1:5, 1:100, letters) as an int vector
#     - str_to_title() of c("ada", "grace") as a character vector
# map_dbl(1:10, \(x) ___)
# map_int(list(1:5, 1:100, letters), ___)
# map_chr(c("ada", "grace"), \(x) ___)

# 3b. A data frame is a list of columns, so map_dbl() walks over its columns.
#     Compute the median of each column below:
nums <- diamonds |> select(carat, depth, price)
# map_dbl(nums, ___)

# Q3b. Write the across() expression that gives the same three medians. How are
#      across() and map_dbl() doing "the same idea" with different tools?


# 3c. Save ONE CSV per diamond cut. group_nest() packs each group's rows into a
#     list-column called data; str_glue() builds the file paths; walk2() writes
#     each (data, path) pair. We write into a temporary folder so nothing
#     clutters your project.
out_dir <- tempdir()

# by_cut <- diamonds |>
#   group_nest(___) |>
#   mutate(path = str_glue("{out_dir}/diamonds-{cut}.csv"))
# by_cut

# walk2(by_cut$data, by_cut$path, ___)

# Confirm the files were written:
# list.files(out_dir, pattern = "^diamonds-.*\\.csv$")

# Q3c. Why do we use walk2() here instead of map2()? (Hint: do we care about the
#      return value, or only about a side effect?)


# --- Question 4: Regular expressions ------------------------------------------
# stringr ships with three handy character vectors you can use directly:
#   fruit      - 80 fruit names
#   words      - ~1000 common English words
#   sentences  - 720 short sentences
# Regex does three jobs: DETECT, EXTRACT, REPLACE/clean.

# 4a. DETECT. str_subset(x, pattern) returns the elements that match.
#     - all fruits containing "berry"
#     - all fruits that start with the letter "a"  (anchor ^)
#     - how many `words` are exactly three letters long  (^.{3}$ with sum(str_detect(...)))
# str_subset(fruit, "___")
# str_subset(fruit, "___")
# sum(str_detect(words, "___"))

# 4b. Build patterns from character classes, quantifiers, and anchors.
#     - words that start with b, c, or d            (character class at the start)
#     - words that start with 3 consonants in a row ([^aeiou]{3})
#     - words with 3 or more vowels in a row        ([aeiou]{3,})
# str_subset(words, "___")
# str_subset(words, "___")
# str_subset(words, "___")

#     A phone-number pattern. Complete the regex so the first two strings match
#     and the last two do NOT. Phones look like (651) 696-6000 or 123-456-7890:
#       \\d = a digit, {3} = exactly three, \\(? and \\)? = optional parentheses,
#       ^ and $ = anchor the whole string.
phones <- c("(651) 696-6000", "123-456-7890", "555.123.4567", "not a phone")
# phone_re <- "^\\(?\\d{3}\\)?[ -]?\\d{3}-\\d{4}$"
# str_detect(phones, phone_re)   # should be TRUE TRUE FALSE FALSE

# Q4b. In your phone regex, what does the ? after \\( and \\) accomplish? What
#      would change if you removed the ^ and $ anchors?

# 4c. EXTRACT and CLEAN.
#     Extract the LAST vowel of each fruit name. One way uses a lookahead;
#     fill in the bracket so it captures a single vowel:
# tibble(fruit = fruit) |>
#   mutate(last_vowel = str_extract(fruit, "[___](?=[^aeiou]*$)")) |>
#   head(6)

#     Clean this messy tibble of scraped numbers into real numbers: drop the
#     trailing "*" from country, turn debt and percGDP into numerics. parse_number()
#     ignores $, commas and the word "billion" for you; use str_remove_all() with
#     a character class for the percent column.
debt <- tibble(
  country = c("World", "United States*", "Japan"),
  debt    = c("$56,308 billion", "$17,607 billion", "$9,872 billion"),
  percGDP = c("64%", "73.60%", "214.30%")
)
# debt |>
#   mutate(
#     country = str_remove_all(country, "___"),
#     debt    = parse_number(debt),
#     percGDP = as.numeric(str_remove_all(percGDP, "___"))
#   )

# Q4c. Name the three jobs regex does, and give the stringr function you would
#      reach for to do each one.


# ============================================================
# AI USE NOTE (required): one sentence on whether/how you used AI on this HW.
#   ___
# ============================================================
