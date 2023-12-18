# DataBricks UFO Quarto Dashboard and Shiny App

This repository houses is a
[Quarto Dashboard](https://quarto.org/docs/dashboards/)
and
[Shiny Application](https://shiny.posit.co/)
deployed on [Posit Connect](https://posit.co/products/enterprise/connect/)
that allows you to explore the [National UFO Reporting Center](http://www.nuforc.org/) database
hosted on a [Databricks](https://databricks.com/) cluster.

## Installation / Setup

There are 4 main parts to getting everything set up:

1. Databricks catalog: where the UFO data is stored
2. Databricks compute: Using Databricks runtime version 14.1 ML
3. R environment and package set up
4. Python environment and package set up

### Databricks catalog

In this example, the UFO data is stored in a Databricks catalog table.
Specifically under `demos` > `nuforc` > `nuforc_reports`.

### Databricks compute

When creating a Databricks compute cluster,
make sure to select the `ML Runtime` option and version `14.1`.
You can also get the `cluster_id` from the URL of the cluster or from the JSON view of the
compute cluster configuration.
The `cluster_id` will be saved and used to connect to the cluster,
and install all the relevant packages.

Note: later versions can be supposed,
but the matching python package needs to be published on PyPI first: <https://pypi.org/project/databricks-connect/>

### R environemnt set up

Create a project-level `.Renviorn` and define the following 3 variables:

```
DATABRICKS_CLUSTER_ID="databricks-cluster-id"
DATABRICKS_HOST=rstudio-partner-posit-default.cloud.databricks.com
DATABRICKS_TOKEN="Databricks-api-token"
```

The `DATABRICKS_HOST` and `DATABRICKS_TOKEN` are variables that can be implicitly used
by the `pysparklyr` package to connect to the Databricks cluster.

The `DATABRICKS_CLUSTER_ID` is useful if you have multiple collaborators on the code repository
where each person has their own Databricks cluster.
This makes version control easier as each person can have their own cluster and
the code will automatically connect to the correct cluster
without having to make modifications to the code.

### Package Setup

The Databricks Connect page: <https://spark.rstudio.com/deployment/databricks-connect.html>
has a good overview of how to set up the R and Python package environment.

## Deploy application to Connect

If you are trying to deploy these applications to Connect in the RStudio IDE,
you can use the `Publish` button to set up the Connect server.
But the deployment needs a few more parameters that need to be passed manually.

In order to deploy either the Shiny application or Quarto document,
you need use the `rsconnect::deployApp()` function and
pass the path to the python binary into the `python` parameter.
This makes sure that the correct Python environment is used when deploying the application,
and Connect can find the correct packages.

We also need to pass in the environment variables that are used to connect to the Databricks cluster.

When running the below commands,
make sure the current working directory is the root of this repository,
and not within any of the sub-directories.

```r
rsconnect::deployApp(
  appName = "ufo-shiny",
  appTitle = "UFO Report Explorer",
  appDir = here::here("ufo-shiny"),
  python = "~/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID")
)
```

```r
rsconnect::deployApp(
  appName = "ufo-dashboard",
  appTitle = "Reported UFO sightings",
  appDir = here::here("ufo-dashboard"),
  python = "~/.virtualenvs/r-sparklyr-databricks-14.1/bin/python",
  envVars = c("DATABRICKS_HOST", "DATABRICKS_TOKEN", "DATABRICKS_CLUSTER_ID")
)
```
