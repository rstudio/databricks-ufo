# make sure you run these commands from the root of the repo as the working directory

pysparklyr::deploy_databricks(
  appName = "ufo-shiny",
  appTitle = "UFO Report Explorer",
  appDir = here::here("ufo-shiny"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  server = "Connect Databricks",
  launch.browser = FALSE
)

pysparklyr::deploy_databricks(
  appName = "ufo-dashboard",
  appTitle = "Reported UFO Sightings",
  appDir = here::here("ufo-dashboard"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  server = "Connect Databricks",
  launch.browser = FALSE
)
