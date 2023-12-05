# Databricks UFO Quarto Dashboard and Shiny App

This repository houses a
[Quarto Dashboard](https://quarto.org/docs/dashboards/)
and
[Shiny Application](https://shiny.posit.co/),
deployed on [Posit Connect](https://posit.co/products/enterprise/connect/),
that explore the [National UFO Reporting Center](http://www.nuforc.org/) database, which is
hosted on a [Databricks](https://databricks.com/) cluster. These artifacts demo how you can use Posit tools alongside Databricks to create an end-to-end workflow, from accessing data on Databricks, to analyzing it in Posit Workbench, to deploying the resulting data products to Posit Connect.

## Installation / Setup

To build these apps, you must set up four components:

1. Databricks catalog, where the UFO data is stored
2. Databricks compute to run commands on Databricks
3. An R environment with associated packages
4. A Python environment with associated packages

### Databricks catalog

In this example, the UFO data is stored in a Databricks catalog table.
Specifically under `demos` > `nuforc` > `nuforc_reports`.

### Databricks compute

When creating a Databricks compute cluster,
make sure to select the `ML Runtime` option and version `14.1`.
Be sure to [note the cluster ID](https://docs.databricks.com/en/workspace/workspace-details.html#cluster-url-and-id), which can be retrieved from the URL of the cluster or from the JSON view of the
compute cluster configuration.
The `cluster_id` will be saved and used to connect to the cluster,
and install all the relevant packages.

Note: later versions can be supposed,
but the matching python package needs to be published on PyPI first: <https://pypi.org/project/databricks-connect/>

### R environemnt set up

Create a project-level `.Renviron` and define the following 3 variables:

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

### R package set up

You can install all the necessary packages with the following commands:

```r
remotes::install_github("mlverse/pysparklyr")
pysparklyr::install_databricks(cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"))
```

#### Package Setup ARM Macs

If you are using an ARM mac,
you need to make sure Python `3.11.x` is installed on your system first.
At the time of writing, Python `3.11` is the only version that is compatiable with Python's `torch` package
on ARM Macs.

For example, you can install Python `3.11.5` via `pyenv`:

```bash
pyenv install 3.11.5
```

You can then install `pysparklyr` and specify the python version when installing the Databricks dependencies.

```r
remotes::install_github("mlverse/pysparklyr")

pysparklyr::install_databricks(
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  python_version = "3.11.5"
)
```

#### Confirming your install

During the installation process you should see the following output at the very top of the console:

```
Automatically naming the environment:'r-sparklyr-databricks-14.1'
```

This is the name of the virtual environment that will be created and used by `pysparklyr`.
The version appended to the end of the name should match the runtime version you selected in your
Databricks compute cluster.

If you are on an ARM Mac, you should also confirm that the installation is using the correct Python version.
Below is the snippet of output that shows Python 3.11.5 being used to create the virtual environment.

```
+ ~/.pyenv/versions/3.11.5/bin/python3.11 -m venv ~/.virtualenvs/r-sparklyr-databricks-14.1
```

If the wrong Python version is being used,
try restarting your R session and trying again,
as `{reticulate}` can only register 1 python version per R session,
and it cannot be changed.

The apps in this repository use the following code to make the connection to the Databricks catalog:

```r
sc <- sparklyr::spark_connect(
  master = Sys.getenv("DATABRICKS_HOST"),
  cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
  token = Sys.getenv("DATABRICKS_TOKEN"),
  method = "databricks_connect"
)
```

When this code is run in a new R session,
the `r-sparklyr-databricks-14.1` python virtual environment will be automatically used.
You can confirm the correct Python environment is loaded by running:

```r
reticulate::py_config()
```

## Deploy application to Connect

If you are trying to deploy these applications to Connect in the RStudio IDE,
use the IDE `Publish` button to set up the Connect server, but refrain from publishing the app with the `Publish` button. The deployment requires a few parameters that need to be passed manually with `rsconnect::deployApp()`.

In order to deploy either the Shiny application or Quarto document,
you need use the `rsconnect::deployApp()` function and
pass the path to the python binary into the `python` parameter.
This makes sure that the correct Python environment is used when deploying the application,
and Connect can find the correct packages.

We also need to pass in the environment variables that are used to connect to the Databricks cluster.

When running the below commands,
make sure the current working directory is the root of this repository,
and not within any of the subdirectories.

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
