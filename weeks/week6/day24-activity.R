# Day 24 In-Class Activity: Clustering & Decision Trees
# STAT 184 - Monday, June 22, 2026
# ============================================================
# Today we are exploring unsupervised learning (k-means) and 
# supervised learning (decision trees) using the Palmer Penguins.
# ============================================================

library(tidyverse)
library(palmerpenguins)
library(rpart)

# Drop missing values to make modeling easier
peng <- penguins |>
  drop_na(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g)


# --- Part 1: Cluster (k = 2 and k = 4) ----------------------------------------

# Standardize the four numeric measurements
X <- peng |>
  select(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g) |>
  scale()

set.seed(184) # for reproducibility (keep this)

# 1a. Run kmeans with centers = 2 and print the confusion table
# km_2 <- kmeans(X, centers = 2, nstart = 25)
# table(cluster = km_2$cluster, species = peng$species)

# 1b. Run kmeans with centers = 4 and print the confusion table
# km_4 <- kmeans(X, centers = 4, nstart = 25)
# table(cluster = km_4$cluster, species = peng$species)

# Q1. How does the table(cluster, species) change compared to k = 3 from class?
#     Which species get grouped together (k=2) or split apart (k=4)?


# --- Part 2: The Elbow Plot (Two Features) ------------------------------------

# 2a. Scale a new matrix using only bill_length_mm and bill_depth_mm
# X_two <- peng |>
#   select(bill_length_mm, bill_depth_mm) |>
#   scale()

# 2b. Rebuild the elbow plot for these two features
# tibble(k = 1:8) |>
#   mutate(wss = map_dbl(k, ~ kmeans(X_two, centers = .x, nstart = 10)$tot.withinss)) |>
#   ggplot(aes(k, wss)) +
#   geom_line() + geom_point(size = 2) +
#   scale_x_continuous(breaks = 1:8) +
#   labs(x = "k (number of clusters)", y = "Error (WCSS)",
#        title = "Elbow Plot for Two Features")

# Q2. Look at your new plot. Does the elbow still clearly say k = 3? 


# --- Part 3: Decision Trees (Two Features) ------------------------------------

# 3a. Fit a tree predicting `species` from only `bill_length_mm` and `bill_depth_mm`
# fit_two <- rpart(
#   species ~ bill_length_mm + bill_depth_mm,
#   data = peng, method = "class"
# )

# 3b. Plot the tree
# plot(fit_two, margin = 0.1)
# text(fit_two, use.n = TRUE, cex = 0.9)

# 3c. Report the accuracy
# pred_two <- predict(fit_two, peng, type = "class")
# table(prediction = pred_two, actual = peng$species)
# mean(pred_two == peng$species) # overall accuracy

# Q3. Did dropping two features hurt the model's accuracy much compared to
#     the all-feature model from the slides?


# --- Part 4: Discussion -------------------------------------------------------

# Q4. Which method (clustering or decision trees) would you prefer if the 
#     dataset had no `species` column at all? Why?

# (Type your answer as a comment here)