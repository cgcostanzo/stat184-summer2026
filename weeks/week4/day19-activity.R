# Day 19 In-Class Activity: Web Scraping with rvest
# STAT 184 - Friday, June 12, 2026
# ============================================================
# Work through the parts in order. Part 3 is a challenge;
# skip to it only if you finish Parts 1 and 2 with time left.
#
# Only scrape public, non-personal, factual data, and don't hammer 
# a server with rapid-fire requests.
# ============================================================

library(tidyverse)
library(rvest)
library(lubridate)


# --- Part 1: HTML basics ------------------------------------------------------
# minimal_html() lets us hand-write HTML for practicing selectors locally.

page <- minimal_html("
  <h1>Course roster</h1>
  <p id='intro'>STAT 184 students and their majors.</p>
  <ul>
    <li><b>Avery</b> studies <i>Statistics</i>, class of <span class='year'>2027</span></li>
    <li><b>Blair</b> studies <i>Biology</i>, class of <span class='year'>2026</span></li>
    <li><b>Casey</b> studies <i>Economics</i></li>
    <li><b>Devin</b> studies <i>Statistics</i>, class of <span class='year'>2028</span></li>
  </ul>
")

# 1a. Select all the <li> elements. How many are there?
page |> html_elements("li")

# 1b. Select just the element with id="intro" using the "#" selector.

# 1c. Select all elements with class "year" using the "." selector.
#     Then pull out their text with html_text2(). How many values do you get?
page |> html_elements(".year") |> html_text2()

# Q1. You should have gotten only 3 years, but there are 4 students. Which
#     student is missing a year, and why is grabbing ".year" directly a problem?

# 1d. Do it the robust way. First grab one element per student:
students <- page |> html_elements("li")

# Now use html_element() (singular!) on each to pull one value per student.
# Build a tibble. Notice that the missing year becomes NA, keeping rows aligned.
roster <- tibble(
  name  = students |> html_element("b") |> html_text2(),
  major = students |> html_element("i") |> html_text2(),
  year  = students |> html_element(".year") |> html_text2()
)
roster

# Q2. Why does html_element() keep everything aligned but html_elements() does not?

# Q3. The "year" column is character ("2027"), not a number. Use mutate() and
#     parse_number() (or as.integer()) to convert it to a number.


# --- Part 2: Wikipedia table scrape -------------------------------------------
# Scraping men's mile-run world record progression from Wikipedia.
# If the live page won't load, that's the reality of scraping -- flag it and
# move on; the skills are what matter.

url <- "https://en.wikipedia.org/wiki/Mile_run_world_record_progression"

# 2a. Read the page and pull ALL tables into a list with html_table().
all_tables <- url |>
  read_html() |>
  html_elements("table") |>
  html_table()

# How many tables are on the page? (Use length().)
length(all_tables)

# 2b. The IAAF-era men's progression is one of these tables. Inspect a few
#     with all_tables[[3]], all_tables[[4]], all_tables[[5]], and remember to use
#     double brackets, because all_tables is a list. Pick the one whose columns
#     are Time / Athlete / Nationality / Date and assign it to `record`.
# record <- all_tables[[ ... ]]

# 2c. The Date column looks like "4 October 1931[6]", i.e., a footnote marker is
#     stuck on the end. Strip it with a regular expression, then parse the date.
#     "\\[.\\]$" matches a single character inside [ ] at the END of the string.
# record <- record |>
#   mutate(Date = str_remove(Date, "\\[.\\]$"),
#          Date = dmy(Date)) # dates are day-month-year here

# 2d. The Time column is like "4:14.4" (minutes:seconds). Convert it to a number
#     of seconds so we can plot it. as.duration(ms("4:14.4")) gives a duration;
#     wrap it in as.numeric() to get plain seconds.
# record <- record |>
#   mutate(seconds = as.numeric(as.duration(ms(Time))))

# Q4. Make a line-and-point plot of seconds (y) versus Date (x). Add the
#     athlete's name above each point with geom_text(aes(label = Athlete)).
#     Roughly how much faster is the modern record than the earliest one?

# Q5. Which nationality set the record the most times? Use count() and sort.


# --- Part 3: Scraping non-table content ----------------------------
# Not all data lives in a <table>. The rvest StarWars vignette page lists 7
# films, each inside a <section>. We'll turn it into a tidy tibble using the
# "rows then columns" pattern from Part 1.

sw_url <- "https://rvest.tidyverse.org/articles/starwars.html"
sw <- read_html(sw_url)

# 3a. Each film is one <section>. Select all of them. How many are there?
films <- sw |> html_elements("section")
length(films)

# 3b. For each film, the title is in an <h2>, the director is in a
#     <span class="director">, and there's a "Released: ..." line in a <p>.
#     Build a tibble with one row per film:
# tibble(
#   title = films |> html_element("h2") |> html_text2(),
#   director = films |> html_element(".director") |> html_text2(),
#   released = films |> html_element("p") |> html_text2()
# )

# 3c. The `released` strings look like "Released: 1999-05-19". Use
#     str_remove() to drop the "Released: " prefix, then parse_date() (or ymd())
#     to turn it into a real <date>.

# 3d. Each <h2> has a data-id attribute (the film's number in release order). 
#     Pull it out with html_attr("data-id").
#     Note: html_attr() always returns a STRING, so convert it to a number afterward.
films |> html_element("h2") |> html_attr("data-id")

# Q6. Sort your films tibble by release date. Does the data-id order match the
#     chronological release order? (The prequels were made out of story order!)
