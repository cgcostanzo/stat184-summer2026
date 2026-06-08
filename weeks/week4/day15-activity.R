# Day 15 In-Class Activity: Joins
# STAT 184 - Monday, June 8, 2026
# ==============================================================================
# Work through Part 1 (Brickerly College) first, then move to
# Part 2 (nycflights13) if you finish early.
# ==============================================================================

library(tidyverse)
library(nycflights13)


# --- Part 1: Brickerly College ------------------------------------------------
# These are the same two tables from the LEGO activity.

students <- tribble(
  ~student, ~major,
  "A", "STAT",
  "B", "STAT",
  "C", "ECON",
  "D", "PSY",
  "E", NA,     # undeclared
  "F", "BIO"   # major not in departments
)

departments <- tribble(
  ~code,  ~dept,
  "STAT", "Statistics",
  "ECON", "Economics",
  "PSY",  "Psychology",
  "ENG",  "Engineering" # no students declared this
)

# Before running each join, predict: how many rows will you get?
# Which students or departments will be missing?

# 1a. Inner join: only rows with a match in BOTH tables
inner_join(students, departments, join_by(major == code))

# 1b. Left join: all students; attach department where available
left_join(students, departments, join_by(major == code))

# 1c. Right join: all departments; attach students where available
right_join(students, departments, join_by(major == code))

# 1d. Full join: every student and every department; NAs where no match
full_join(students, departments, join_by(major == code))

# Questions:
# Q1. How many rows does each join return? Were your predictions right?
# Q2. Which students have NA for dept in the left join, and why?
# Q3. Which department has NA for student in the right join, and why?
# Q4. The full join has the most rows. What does each row with an NA indicate
#     about the two datasets in terms of how they match up?


# --- Part 2: nycflights13 -----------------------------------------------------
# flights is the central table. The others each add detail about one piece
# of a flight: the airline, the airports, the plane, or the weather.

glimpse(flights)   # 336,776 rows: one per flight
glimpse(airlines)  # 16 rows: carrier code + full name
glimpse(airports)  # 1,458 rows: FAA code + location info
glimpse(planes)    # 3,322 rows: tailnum + plane details

# --- 2a. Add airline names ----------------------------------------------------
# flights has carrier (e.g., "UA"); airlines has carrier and name.
# Join flights and airlines so each flight row shows the full airline name.

# Which airlines had the most flights?

# --- 2b. Add destination airport names ----------------------------------------
# airports has column `faa`; flights has `dest`. They mean the same thing
# but have different names; use join_by(dest == faa).

# --- 2c. Flights with no plane record -----------------------------------------
# anti_join keeps rows in the left table with NO match in the right table.
# Find all flights whose tailnum doesn't appear in planes.

# Which carriers account for most of the missing records?

# --- 2d. Airports that appear as destinations (semi_join) ---------------------
# semi_join keeps rows in the left table that DO have a match in the right.
# How many airports in `airports` actually show up as a dest in `flights`?

# --- 2e. The year column pitfall ----------------------------------------------
# Join flights and planes using tailnum and year, then try again using just
# tailnum
#
# flights$year = year of the flight (always 2013)
# planes$year = year the plane was manufactured
# Both are named "year"; dplyr would join on both tailnum and year if you
# let it pick automatically. Always be explicit with join_by().

# WRONG: joins on tailnum and year- almost no matches
nrow(left_join(flights, planes))

# CORRECT: join only on tailnum. Select only the following columns for clarity:
# - flight, tailnum, year.x, year.y, manufacturer
# Note that year.x = 2013 (flight year); year.y = manufacture year

# --- 2f. Challenge: worst average arrival delay by destination ----------------
# Find the 10 destination airports with the worst average arrival delay
# (minimum 100 flights). Show the airport name alongside the code.
