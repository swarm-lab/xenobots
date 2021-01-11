### ENVIRONMENT CLEAN UP ###
rm(list = ls())


### LIBRARIES AND CUSTOM FUNCTION ###
library(readr)
library(dplyr)
library(readxl)
library(stringr)
library(lubridate)

if (!require(trackdf, quietly = TRUE)) {
  remotes::install_github("swarm-lab/trackdf")
} else if (packageVersion("trackdf") < "0.2.2") {
  remotes::install_github("swarm-lab/trackdf")
}

library(trackdf)

dist2segment <- function(x, y, ext1, ext2) {
  p_x <- ext2[1] - ext1[1]
  p_y <- ext2[2] - ext1[2]
  dd <- p_x ^ 2 + p_y ^ 2
  u <- ((x - ext1[1]) * p_x + (y - ext1[2]) * p_y) / dd

  u[u > 1] <- 1
  u[u < 0] <- 0

  x_p <- ext1[1] + u * p_x
  y_p <- ext1[2] + u * p_y
  d_x <- x_p - x
  d_y <- y_p - y
  sqrt(d_x ^ 2 + d_y ^ 2)
}

dist2poly <- function(x, y, poly_x, poly_y) {
  out <- matrix(NA, nrow = length(x), ncol = length(poly_x))

  for (i in 1:length(poly_x)) {
    if (i < length(poly_x)) {
      idx1 <- i
      idx2 <- i + 1
    } else {
      idx1 <- i
      idx2 <- 1
    }

    out[, i] <- dist2segment(x, y, c(poly_x[idx1], poly_y[idx1]), c(poly_x[idx2], poly_y[idx2]))
  }

  apply(out, 1, min)
}


### SCRIPT ###
rawdat <- tibble(file = list.files("rawdata", "*.csv.zip", full.names = TRUE)) %>%
  group_by(., file) %>%
  do(., read_csv(.$file, col_types = cols())) %>%
  ungroup(.) %>%
  mutate(., replicate = as.numeric(str_extract(file, "(?i)(?<=\\D)\\d+"))) %>%
  mutate(., unique_id = paste0(replicate, "_", track_fixed)) %>%
  group_by(., file, track_fixed, frame) %>%
  summarize(., x = mean(x),
            y = mean(y),
            replicate = replicate[1],
            unique_id = unique_id[1],
            ignore = all(ignore)) %>%
  ungroup(.)

infodat <- read_excel("rawdata/info.xlsx") %>%
  group_by(., replicate, condition, age, scale) %>%
  do(., poly_y = str_extract_all(c(.$top_left, .$top_right, .$bottom_right, .$bottom_left),
                                 "(\\d)+", simplify = TRUE)[, 1] %>%
       as.numeric(.) / .$scale,
     poly_x = str_extract_all(c(.$top_left, .$top_right, .$bottom_right, .$bottom_left),
                              "(\\d)+", simplify = TRUE)[, 2] %>%
       as.numeric(.) / .$scale) %>%
  ungroup(.)

full_dat <- full_join(rawdat, infodat, by = "replicate") %>%
  mutate(., x = x / scale, y = y / scale) %>%
  group_by(., replicate) %>%
  mutate(., arena_dist = dist2poly(x, y, poly_x[[1]], poly_y[[1]])) %>%
  ungroup(.)

tracks <- track_df(full_dat$x, full_dat$y, t = full_dat$frame,
                   id = full_dat$unique_id, period = "1second",
                   ignore = full_dat$ignore, file = full_dat$file,
                   condition = full_dat$condition, age = full_dat$age,
                   arena_dist = full_dat$arena_dist)

saveRDS(tracks, "data.rds")
