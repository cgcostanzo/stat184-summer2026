# combine_hexes.R
# Combine R hex stickers into a honeycomb SVG.
#
# Key challenge: each sticker exported from Illustrator uses the same generic
# class names (.st0, .st1, ...) inside a global <style> block. SVG's <style>
# is global regardless of nesting, so naively concatenating files makes the
# stylesheets clobber each other. Fix: namespace every class with a per-file
# prefix before merging (e.g. .st0 -> .dplyr-st0 in both the <style> rule
# and every class="..." attribute).
#
# Layout: pointy-topped honeycomb tessellation
#   horizontal step = hex width
#   vertical   step = hex height * 3/4
#   offset every other row by half a hex width
# Plus a small gap so artwork overflowing one hex doesn't clip a neighbour.

suppressPackageStartupMessages(library(xml2))

# ---- Configuration -----------------------------------------------------------

input_dir  <- here::here("weeks", "week1", "images")
output_svg <- here::here("weeks", "week1", "images", "hexwall_r.svg")

# Reference hex dimensions (most files use this; bonsai is 1080x1250, same ratio)
hex_w <- 2521
hex_h <- 2911

gap        <- 80
col_step   <- hex_w + gap
row_step   <- hex_h * 3 / 4 + gap * 0.866
row_offset <- col_step / 2
pad        <- 60

layout <- list(
  c("tidyverse.svg", "ggplot2.svg",   "dplyr.svg",  "forcats.svg"),
  c("purrr.svg",     "reticulate.svg","bonsai.svg", "baguette.svg")
)

# ---- Namespace every CSS class so stickers don't clobber each other ---------

namespace_classes <- function(svg_text, prefix) {
  # Match every occurrence of `stN` (where N is one or more digits) that's a
  # whole token — i.e. not preceded by an alphanumeric or hyphen. That single
  # rule covers BOTH the `.stN` selectors inside <style> blocks AND the bare
  # `stN` tokens inside class="..." attributes (including multiple classes
  # like class="st0 st3"). gsub is global, so one pass replaces all matches.
  svg_text <- gsub("(?<![A-Za-z0-9-])st([0-9]+)",
                   paste0(prefix, "st\\1"),
                   svg_text, perl = TRUE)
  
  # Internal IDs like url(#SVGID_1_) also collide across files. Namespace them
  # the same way.
  svg_text <- gsub("(?<![A-Za-z0-9-])SVGID_",
                   paste0(prefix, "SVGID_"),
                   svg_text, perl = TRUE)
  
  svg_text
}

read_sticker <- function(path) {
  raw <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  
  # Per-file class prefix from the filename, e.g. "dplyr.svg" -> "dplyr-"
  prefix <- paste0(tools::file_path_sans_ext(basename(path)), "-")
  raw <- namespace_classes(raw, prefix)
  
  doc <- read_xml(raw)
  vb  <- xml_attr(doc, "viewBox")
  if (is.na(vb)) stop("No viewBox in ", path)
  
  xml_ns_strip(doc)
  list(viewBox = vb, children = xml_children(doc))
}

# ---- Compute placements ------------------------------------------------------

placements <- list()
for (row_idx in seq_along(layout)) {
  row <- layout[[row_idx]]
  y   <- (row_idx - 1) * row_step
  x_start <- if (row_idx %% 2 == 0) row_offset else 0
  for (col_idx in seq_along(row)) {
    placements[[length(placements) + 1]] <- list(
      file = row[col_idx],
      x    = x_start + (col_idx - 1) * col_step,
      y    = y
    )
  }
}

xs <- vapply(placements, `[[`, numeric(1), "x")
ys <- vapply(placements, `[[`, numeric(1), "y")
min_x <- min(xs); max_x <- max(xs) + hex_w
min_y <- min(ys); max_y <- max(ys) + hex_h

total_w <- max_x - min_x + 2 * pad
total_h <- max_y - min_y + 2 * pad

# ---- Build the combined SVG --------------------------------------------------

out <- read_xml(sprintf(
  '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 %.0f %.0f"/>',
  total_w, total_h
))

for (p in placements) {
  src <- read_sticker(file.path(input_dir, p$file))
  place_x <- p$x - min_x + pad
  place_y <- p$y - min_y + pad
  
  nested <- read_xml(sprintf(
    '<svg xmlns="http://www.w3.org/2000/svg" x="%.0f" y="%.0f" width="%d" height="%d" viewBox="%s" overflow="visible"/>',
    place_x, place_y, hex_w, hex_h, src$viewBox
  ))
  for (child in src$children) xml_add_child(nested, child)
  xml_add_child(out, nested)
}

write_xml(out, output_svg)
cat("Wrote:", output_svg, "\n")
cat("viewBox: 0 0", round(total_w), round(total_h), "\n")

