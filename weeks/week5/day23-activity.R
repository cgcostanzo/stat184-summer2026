# Day 23 In-Class Activity: Regular Expressions
# STAT 184 - Thursday, June 18, 2026
# ============================================================
# Today's session also hosts oral check-in #1. Work on this
# activity when it isn't your turn.
#
# Reminder of R quantifiers (the textbook swaps + and *):
#   ?  zero or one     *  zero or more     +  one or more
#   {n}  exactly n     {n,m}  n to m       {n,}  n or more
# ============================================================

library(tidyverse)
library(dcData)
data(BabyNames)

# Total count of each name/sex, most popular first.
NameList <- BabyNames |>
  group_by(name, sex) |>
  summarise(total = sum(count), .groups = "drop") |>
  arrange(desc(total))


# --- Part 1: Detect patterns (grepl / str_detect + filter) --------------------

# 1a. Find names that contain "shine" (any case). Show the top few.

# 1b. Find names that contain "mn" (like Autumn). str_detect() is the stringr
#     equivalent of grepl().

# 1c. Find boys' names that end in a vowel. Anchor the end with $ and filter sex.
#     Show the 10 most popular.

# 1d. Find names that contain a space (like "Lee Ann"). A literal space in the
#     pattern matches a space. Show a few using head().

# Q1. Names ending in "joe" (like "BettyJoe"): write the regex and find the 10
#     most popular. Should you anchor it? With what?


# --- Part 2: Character classes, quantifiers, anchors --------------------------

# 2a. Three or more vowels in a row: [aeiou]{3,}. Find the top few names.

# 2b. Three or more consonants in a row. A consonant is [^aeiou]. Adapt 2a.

# 2c. Names whose 1st, 3rd, and 5th letters are consonants. Build the pattern
#     from ^, the consonant class, and . (any character):
#     ^ [^aeiou] . [^aeiou] . [^aeiou]   (no spaces in the real regex)

# Q2. Write a regex that matches names that sound like "Caitlin": a k or c,
#     then one or more vowels, then "tl", then one or more vowels, then ending
#     in n. Test it on a vector you make up, then run it on NameList.
#     Tip: names are Capitalized, so match case-insensitively with
#     regex(caitlin_re, ignore_case = TRUE).
# caitlin_re <- "..."
# c("Caitlin", "Kaitlin", "Carl") |> str_subset(regex(caitlin_re, ignore_case = TRUE))

# Q3. Here is a phone-number regex (US-style):
#     "([2-9][0-9]{2})[- .]([0-9]{3})[- .]([0-9]{4})"
#     In words, what does each of the three ( ) groups capture, and what does
#     [- .] match between them? (Hint: "Call me maybe.")


# --- Part 3 (challenge): Extract and clean ------------------------------------

# 3a. Extract the last vowel of each name and compare counts by sex.
#     The regex ".*([aeiou])$" captures the final vowel in group 1; gsub() with
#     replacement "\\1" keeps only that group.
# re <- ".*([aeiou])$"
# NameList |>
#   filter(grepl(re, name)) |>
#   mutate(vowel = gsub(re, "\\1", name)) |>
#   group_by(sex, vowel) |>
#   summarise(total = sum(total), .groups = "drop") |>
#   pivot_wider(names_from = sex, values_from = total)

# 3b. Clean these messy money strings into plain numbers. Remove $, commas, the
#     word "billion", and surrounding spaces, then convert with as.numeric().
debt <- c("$56,308 billion", "$17,607 billion", "$9,872 billion")
# debt |> gsub(pattern = "[$,]|billion", replacement = "") |> str_squish() |> as.numeric()

# 3c. Strip leading/trailing spaces from this string using a regex (^ +| +$),
#     then do the same with str_trim() and confirm they agree.
s <- "   My name is Julia     "
# gsub("^ +| +$", "", s)
# str_trim(s)

# Q4. (Optional, needs internet) Read the Bible names list and find which baby
#     names contain "bar", "dam", or "lory":
# BibleNames <- readr::read_csv("https://mdbeckman.github.io/dcSupplement/data/BibleNames.csv")
# BibleNames |> filter(grepl("bar|dam|lory", name, ignore.case = TRUE))
