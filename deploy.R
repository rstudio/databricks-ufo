# make sure you run these commands from the root of the repo as the working directory

rsconnect::deployApp(
  appDir = here::here("ufo-shiny"),
  # set the python path (you need to change this value yourself
  python = "/Users/danielchen/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID"),
  lint = FALSE
)

rsconnect::deployApp(
  appDir = here::here("ufo-dashboard"),
  # set the python path (you need to change this value yourself
  python = "/Users/danielchen/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID"),
  lint = FALSE
)
