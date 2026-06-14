# Day 23 In-Class Activity KEY: Regular Expressions
# STAT 184 - Thursday, June 18, 2026
# ============================================================
# Instructor solution key. One reasonable solution per part;
# students' working code may differ.
# ============================================================

library(tidyverse)
library(dcData)
data(BabyNames)

NameList <- BabyNames |>
  group_by(name, sex) |>
  summarise(total = sum(count), .groups = "drop") |>
  arrange(desc(total))


# --- Part 1: Detect patterns --------------------------------------------------

# 1a.
NameList |>
  filter(grepl("shine", name, ignore.case = TRUE)) |>
  head()

# 1b.
NameList |>
  filter(str_detect(name, "mn")) |>
  head()

# 1c.
NameList |>
  filter(sex == "M", grepl("[aeiou]$", name)) |>
  head(10)

# 1d.
NameList |>
  filter(grepl(" ", name)) |>
  head()

# Q1. Anchor the end with $ so the name ENDS in "joe". (ignore.case catches Joe.)
NameList |>
  filter(grepl("joe$", name, ignore.case = TRUE)) |>
  head(10)


# --- Part 2: Character classes, quantifiers, anchors --------------------------

# 2a.
NameList |>
  filter(grepl("[aeiou]{3,}", name, ignore.case = TRUE)) |>
  head()

# 2b.
NameList |>
  filter(grepl("[^aeiou]{3,}", name, ignore.case = TRUE)) |>
  head()

# 2c.
NameList |>
  filter(grepl("^[^aeiou].[^aeiou].[^aeiou]", name, ignore.case = TRUE)) |>
  head()

# Q2. k or c, one+ vowels, "tl", one+ vowels, ending in n. Use ignore_case so
#     the capitalized names match (the [kc] class is lowercase only).
caitlin_re <- "^[kc][aeiou]+tl[aeiou]+n$"
c("Caitlin", "Kaitlin", "Katelyn", "Carl", "Catalan") |>
  str_subset(regex(caitlin_re, ignore_case = TRUE))
# -> "Caitlin" "Kaitlin"
# (Discussion: "Katelyn" has "te", not "tl", and its 'y' isn't in [aeiou];
#  "Catalan" has "ta", not "tl". Both fail -- good chances to talk through why.)

# Q3. Group 1 ([2-9][0-9]{2}) = 3-digit area code (first digit 2-9).
#     Group 2 ([0-9]{3})      = 3-digit exchange/prefix.
#     Group 3 ([0-9]{4})      = 4-digit line number.
#     [- .] between groups matches a single dash, space, OR period -- so it
#     accepts 651-696-6000, 651.696.6000, or 651 696 6000.


# --- Part 3 (challenge): Extract and clean ------------------------------------

# 3a.
re <- ".*([aeiou])$"
NameList |>
  filter(grepl(re, name)) |>
  mutate(vowel = gsub(re, "\\1", name)) |>
  group_by(sex, vowel) |>
  summarise(total = sum(total), .groups = "drop") |>
  pivot_wider(names_from = sex, values_from = total)

# 3b.
debt <- c("$56,308 billion", "$17,607 billion", "$9,872 billion")
debt |> gsub(pattern = "[$,]|billion", replacement = "") |> str_squish() |> as.numeric()

# 3c.
s <- "   My name is Julia     "
gsub("^ +| +$", "", s)   # "My name is Julia"
str_trim(s)              # "My name is Julia"  (agree)

# Q4. (needs internet)
# BibleNames <- readr::read_csv("https://mdbeckman.github.io/dcSupplement/data/BibleNames.csv")
# BibleNames |> filter(grepl("bar|dam|lory", name, ignore.case = TRUE))
# Ending with those words instead: grepl("(bar|dam|lory)$", name, ignore.case = TRUE)
