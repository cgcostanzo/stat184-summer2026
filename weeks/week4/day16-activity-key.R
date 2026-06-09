# Day 16 In-Class Activity: Importing & Cleaning Data
# STAT 184 - Tuesday, June 9, 2026
# ============================================================
# Work through the parts in order. Part 3 is a challenge;
# skip to it only if you finish Parts 1 and 2 with time left.
# ============================================================

library(tidyverse)
library(lubridate)


# --- Part 1: Students CSV -----------------------------------------------------
# Run each block, look at the output, then move to the next fix.

url_students <- "https://pos.it/r4ds-students-csv"

# 1a. Read the file as-is. What problems do you spot?
students_raw <- read_csv(url_students)
students_raw

# In favorite.food, there is a string "N/A" that should be treated as a missing
# NA value. AGE is clearly supposed to be a numeric column, but has a character
# string "five" in place of 5, which makes the entire column (incorrectly)
# character type. Also, the column names are not clean snake case, e.g., some
# include spaces, periods, the capitalization varies. Not all of these "issues"
# are as serious, but the names aren't as clean as they could be.

# 1b. Fix the NA values. "N/A" should be treated as missing, not a string.
#     Add na = c("N/A", "") to the read_csv() call.
students <- read_csv(url_students, na = c("N/A", ""))
students

# 1c. Clean up the column names with janitor::clean_names().
#     (Install janitor once if you haven't: install.packages("janitor"))
students <- students |> janitor::clean_names()
students

# 1d. Fix the column types:
#     - meal_plan should be a factor (categorical, not character)
#     - age should be numeric, but "five" is in there; fix it first
students <- students |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  )
students

# Q1. How many rows have NA for age? Use filter() and is.na() to find them.
students |>
  filter(is.na(age))

# Q2. What are the levels of the meal_plan factor? Use levels().
with(students, levels(meal_plan))

# Q3. Write the cleaned students data frame to a CSV, then read it back.
#     Does meal_plan stay a factor, or revert to character?
write_csv(students, "students-clean.csv")
read_csv("students-clean.csv")

# meal_plan reverts to character.

# Q4. Now write it as an RDS file and read it back. What happens to the types?
write_rds(students, "students-clean.rds")
read_rds("students-clean.rds")

# The types are preserved.

# --- Part 2: Houses for sale --------------------------------------------------
# Saratoga, NY houses data from DC Ch. 16. Several columns use integer codes
# instead of meaningful labels.

url_houses <- "https://mdbeckman.github.io/dcSupplement/data/houses-for-sale.csv"

houses <- read_csv(url_houses)
glimpse(houses)

# 2a. Here are the fuel type codes:
fuel_codes <- tribble(
  ~code, ~fuel_type,
  2, "gas",
  3, "electric",
  4, "oil"
)

# Use left_join() to add fuel_type to houses. What column in houses matches
# the code column in fuel_codes?
houses <- houses |>
  left_join(fuel_codes, join_by(fuel == code))
houses

# 2b. Do the same for heat type:
heat_codes <- tribble(
  ~code, ~heat_type,
  2, "hot air",
  3, "hot water",
  4, "electric"
)
houses <- houses |>
  left_join(heat_codes, join_by(heat == code))

# 2c. How many houses use each fuel type? Use count().
houses |>
  count(fuel_type)

# 2d. What's the median price by fuel type?
houses |>
  group_by(fuel_type) |>
  summarise(med_price = median(price))

# 2e. The construction column is coded 0/1 (0 = existing, 1 = new).
#     Create a new column new_construction that is TRUE when construction == 1.
houses <- houses |>
  mutate(new_construction = if_else(construction == 1, TRUE, FALSE))

# 2f. Using the columns you've decoded so far, make a boxplot of price by
#     fuel_type. Does fuel type seem to relate to price?
houses |>
  ggplot() +
  geom_boxplot(aes(x = fuel_type, y = price, fill = fuel_type)) +
  labs(fill = "Fuel Type", 
       x = "Fuel Type", 
       y = "Price",
       title = "Boxplots of Price by Fuel Type") +
  scale_fill_brewer()

# --- Part 3: Challenge: column types and dates --------------------------------

# 3a. Read the students CSV again, but this time force student_id to be
#     a character column (it's an ID number, so math on it is meaningless).
#     Use col_types = list(student_id = col_character()).
read_csv("students-clean.csv",
         col_types = list(student_id = col_character()))

# 3b. Here are some date strings in different formats. Use the appropriate
#     lubridate function to parse each one, then compute the number of days
#     between that date and today (Sys.Date()).

date1 <- "June 9, 2026"        # hint: mdy()
date2 <- "2026-06-26"          # hint: ymd()
date3 <- "26 June 2026"        # hint: dmy()

mdy(date1) - Sys.Date()
ymd(date2) - Sys.Date()
dmy(date3) - Sys.Date()

# 3c. The houses data has a price column. Suppose a dataset gave price as
#     "$132,500" instead of 132500. Use parse_number() to convert this:
price_strings <- c("$132,500", "$181,115", "$109,000")
parse_number(price_strings)

# 3d. read_csv() has a skip argument. What does it do? Try:
read_csv(
  "# This file was exported on 2026-06-09
   # Source: Penn State registrar
   student,gpa
   Alice,3.8
   Bob,3.2",
  skip = 2
)
# Now try comment = "#" instead of skip = 2. What's the difference?

read_csv(
  "# This file was exported on 2026-06-09
   # Source: Penn State registrar
   student,gpa
   Alice,3.8
   Bob,3.2",
  comment = "#"
)

# Both skip = 2 and comment = "#" will produce the exact same data frame here,
# but they go about it in fundamentally different ways.
# The skip argument tells read_csv() to literally ignore the first n lines of 
# the file before it even starts looking for column names or data.
# The comment argument tells read_csv() to ignore any text that comes after the 
# specified character, regardless of where it appears in the document.