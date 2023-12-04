library(bslib)
library(bsicons)
library(tidyverse)
library(fontawesome)
library(forcats)
library(ggplot2)
library(glue)
library(leaflet)
library(pysparklyr)
library(sf)
library(shiny)
library(sparklyr)
library(spData)

print(Sys.getenv("DATABRICKS_CLUSTER_ID"))

options(digits = 22)

## Read data from databricks -----

sc <- sparklyr::spark_connect(
  master = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token = Sys.getenv("DATABRICKS_TOKEN"),
  method = "databricks_connect"
)

print(reticulate::py_config())

ufos <-
  dplyr::tbl(sc, dbplyr::in_catalog("demos", "nuforc", "nuforc_reports")) |>
  dplyr::filter(!is.na(city_location)) |>
  dplyr::collect()

## Save data from data bricks locally (for local development) -----

#readr::write_rds(ufos, "data/ufos.rds")

## Read data from local -----

# ufos <- readr::read_csv("./data/ufos.csv")
# ufos <- readr::read_rds("./data/ufos.rds")

ufos

num_sightings <- nrow(ufos)
max_date <- max(as.Date(ufos$date_time), na.rm = TRUE)

# ----- USA only

ufos_usa <-
  ufos |>
  dplyr::filter(country == "USA") |>
  tibble::rownames_to_column(var = "id") |>
  dplyr::mutate(state = str_remove(state, "\n"))

us_state_counts <-
  ufos_usa |>
  dplyr::count(state)

state_abb <-
  tibble(state = state.name,
         abb = state.abb)

alien_related_words <- c("martian", "alien", "aliens", "extra-terrestrial", "creature", "intelligent", "being", "visitation", "abduction", "man", "figure", "abducted")

clean_time <- function(string) {
  if (is.na(string) || nchar(string) > 15) return("-")

  units <- c("sec" , "second", "min", "minute", "minute", "hour", "hours", "day", "week", "month")
  if (!any(stringr::str_detect(string, units))) return("-")

  stringr::str_to_lower(string) |>
    stringr::str_replace("seconds", "s") |>
    stringr::str_replace("second", "s") |>
    stringr::str_replace("secs", "s") |>
    stringr::str_replace("sec", "s") |>
    stringr::str_replace("minutes", "m") |>
    stringr::str_replace("minute", "m") |>
    stringr::str_replace("mins", "m") |>
    stringr::str_replace("min", "m") |>
    stringr::str_replace("hours", "h") |>
    stringr::str_replace("hour", "h")
}

na_check <- function(x) if (is.na(x)) "-" else x
