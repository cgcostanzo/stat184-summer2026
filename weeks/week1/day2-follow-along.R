# =============================================================================
# Day 2 — R, RStudio, and the console; vectors; types
# Tuesday, May 19, 2026
#
# This is a follow-along script. Type each line in the console as we get
# to it on the slides — don't just read it!
#
# A few RStudio tips before we start:
#   * To run the current line, place your cursor on it and press
#       Ctrl + Enter   (Windows / Linux)
#       Cmd  + Enter   (Mac)
#     The result will show up in the Console pane below.
#   * The sections marked with #### below are navigable. Look at the
#     bottom-left of the editor for a jump menu, or press Ctrl/Cmd + Shift + O
#     to open the document outline on the right.
#   * If you see a "+" instead of ">" in your console, R thinks you have
#     an unfinished command. Press Esc to cancel and start over.
# =============================================================================


# 1. R as a calculator --------------------------------------------------- ####
# R can do arithmetic just like a calculator. Try each of these.

184.101 * 9.35       # multiplication

(8 + 4) / 9          # parentheses work like you'd expect

sqrt(8)              # functions: sqrt(x) takes the square root

cos(2 * pi)          # pi is built in; cos() works in radians


# 2. YOUR TURN: type these yourself -------------------------------------- ####
# Don't just read these — type each line and hit Enter.
# Try to guess each answer BEFORE you run it.
# If you get an error, that's normal. Flag me down or ask your neighbor.

2 + 2

sqrt(16)

c(1, 2, 3) * 2       # what does multiplying a vector by 2 do?

10 %% 3              # %% is the "modulo" operator: remainder after division

x <- log(10^2, base = 10)   # log base 10 of 100
x                            # type just the name to see the value


# 3. Vector operations --------------------------------------------------- ####
# c() concatenates values into a single vector.
# Operations are applied element-by-element.

c(1, 8, 4) + c(9, 3, 5)     # 1+9, 8+3, 4+5  ->  10 11  9

c(1, 8, 4) * c(9, 3, 5)     # 1*9, 8*3, 4*5  ->   9 24 20


# 4. Built-in functions and constants ------------------------------------ ####
# R comes with a long list of math functions and constants.

exp(1)        # e^1, Euler's number (~ 2.718)

sqrt(pi)      # pi is built in (the constant ~ 3.14159...)

dnorm(0)      # standard normal density at x = 0 (~ 0.399)


# 5. Creating objects ---------------------------------------------------- ####
# Use the assignment operator  <-  to store a value in an object.
# In RStudio:   Alt + -   (Windows / Linux)
#               Option + -   (Mac)
# inserts <- automatically with proper spacing.

x <- 3 * 5

x             # type the name to print the value

# General form:
#   object_name <- value
# "object_name GETS value"
#
# Naming rules:
#   * start with a letter
#   * letters, numbers, _, and . are allowed
#   * NO spaces, NO special characters
#
# Style tip: use <- for assignment, not =. Both work, but mixing them
# leads to confusion later (= means something different inside functions).


# 6. Try a few of your own ----------------------------------------------- ####
# Make up an object name, assign something to it, then print it.
# Some ideas:

course_name <- "STAT 184"
course_name

my_fav_number <- 7
my_fav_number * 2

# What happens if you do this?
y <- 10
z <- y + 5
z

# Check your Environment pane (top-right) — you should see
# every object you've created listed there.


# =============================================================================
# That's it for today. Tomorrow: functions, packages, and the tidyverse.
#
# Reminders:
#   * HW 0 (setup confirmation) is due Wednesday 11:59 p.m.
#   * Quiz 1 is in class on Friday.
# =============================================================================
